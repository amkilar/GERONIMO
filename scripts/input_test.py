import unittest
import yaml
import os

class TestConfig(unittest.TestCase):
    def setUp(self):
        with open("config.yaml", 'r') as stream:
            try:
                self.config = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                self.fail(f"Error loading YAML file: {exc}")

    def test_config_file_exists(self):
        self.assertTrue(os.path.exists("config.yaml"), "Config file not found. Please make sure there is a config.yaml file in the same directory as the script.")

    def test_config_has_required_keys(self):
        required_keys = ["CPU_for_model_building", "database", "models", "extract_genomic_region-length"]
        for key in required_keys:
            self.assertIn(key, self.config, f"Missing key in config file: {key}. Please add it and try again.")

    def test_cpu_for_model_building_is_number(self):
        self.assertTrue(isinstance(self.config.get("CPU_for_model_building"), int), 
                        "CPU_for_model_building should be a whole number (integer). Please check your config file and make sure the value for CPU_for_model_building is a whole number.")

    def test_database_is_string(self):
        self.assertIsInstance(self.config.get("database"), str, "The value for 'database' in the config file should be a string. Please check your config file.")

    def test_models_are_unique_and_alphanumeric(self):
        models = self.config.get("models", [])
        # Check if models are unique
        self.assertEqual(len(models), len(set(models)), "The models in the config file should not contain duplicates. Please remove any duplicate models.")
        # Check if models contain only alphanumeric characters
        for model in models:
            self.assertTrue(model.isalnum(), "The models in the config file should only contain alphanumeric characters. Please check your config file.")

    def test_extract_genomic_region_length_is_number(self):
        self.assertIsInstance(self.config.get("extract_genomic_region-length"), int, "The value for 'extract_genomic_region-length' in the config file should be a number. Please check your config file.")

if __name__ == '__main__':
    unittest.main()