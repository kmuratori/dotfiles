import unittest
from unittest.mock import patch

import configure


class ConfigureTests(unittest.TestCase):

    def test_manager_specific_packages_are_included(self):
        packages = configure.read_packages("xbps")
        self.assertIn("git", packages)
        self.assertIn("i3status-rust", packages)

    def test_duplicate_packages_are_removed(self):
        packages = configure.read_packages("apt")
        self.assertEqual(len(packages), len(set(packages)))

    def test_generated_installer_is_manager_specific(self):
        script = configure.generate("xbps", ["git", "htop"])
        self.assertIn("xbps-install", script)
        self.assertNotIn("pacman", script)
        self.assertNotIn("apt-get", script)
        self.assertIn("cp -a", script)
        self.assertNotIn("ln -s", script)

    def test_dry_run_is_supported_and_wrapped(self):
        script = configure.generate("apt", ["git"])
        self.assertIn("DRY_RUN=1", script)
        self.assertIn("run sudo apt-get update", script)
        self.assertIn("run sudo apt-get install", script)

    def test_empty_packages_no_package_commands(self):
        script = configure.generate("apk", [])
        self.assertIn("No packages selected.", script)
        self.assertNotIn("sudo apk add", script)

    def test_file_mappings_are_generated(self):
        files = {
            "home/.bashrc": "~/.bashrc",
            "home/.profile": "~/.profile",
        }

        with patch.dict(configure.FILES, files, clear=True):
            script = configure.generate("xbps", [])

        self.assertIn('run cp -a "$REPO/home/.bashrc" "$HOME/.bashrc"', script)
        self.assertIn('run cp -a "$REPO/home/.profile" "$HOME/.profile"', script)
        self.assertIn('run mkdir -p "$HOME"', script)

    def test_file_mapping_does_not_copy_home_directory(self):
        script = configure.generate("xbps", [])

        self.assertNotIn('cp -a "$REPO/home/."', script)

    def test_missing_source_file_stops_installation(self):
        script = configure.generate("xbps", [])

        self.assertIn('if [[ -f "$REPO/home/.bashrc" ]]; then', script)
        self.assertIn("missing source file", script)
        self.assertIn("exit 1", script)


if __name__ == "__main__":
    unittest.main()
