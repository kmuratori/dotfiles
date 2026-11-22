import unittest

import configure


class ConfigureTests(unittest.TestCase):
    def test_manager_specific_packages_are_included(self):
        packages = configure.read_packages("xbps")
        self.assertIn("git", packages)
        self.assertIn("i3status-rust", packages)

    def test_duplicate_packages_are_removed(self):
        self.assertEqual(len(configure.read_packages("apt")), len(set(configure.read_packages("apt"))))

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


if __name__ == "__main__":
    unittest.main()
