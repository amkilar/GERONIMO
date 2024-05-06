import unittest
import yaml
import os

class TestConfig(unittest.TestCase):
    def setUp(self):
        with open("config.yaml", 'r') as stream:
            try:
                self.config = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print(exc)

    def test_config_file_exists(self):
        try:
            self.assertTrue(os.path.exists("config.yaml"), "Config file not found. Please make sure there is a config.yaml file in the same directory as GERONIMO.stk script.")
        except AssertionError as e:
            print(e)

    def test_config_has_required_keys(self):
        required_keys = ["CPU_for_model_building", "database", "models", "extract_genomic_region-length"]
        for key in required_keys:
            try:
                self.assertTrue(key in self.config, f"Missing key in config file: {key}. Please add it and try again.")
            except AssertionError as e:
                print(e)

    def test_cpu_for_model_building_is_number(self):
        try:
            self.assertTrue("CPU_for_model_building" in self.config and isinstance(self.config["CPU_for_model_building"], int), 
                            "CPU_for_model_building should be a whole number (integer). Please check your config file and make sure the value for CPU_for_model_building is a whole number.")
        except AssertionError as e:
            print(e)

    def test_database_is_string(self):
        try:
            self.assertIsInstance(self.config["database"], str, "The value for 'database' in the config file should be a string. Please check your config file.")
        except AssertionError as e:
            print(e)

    def test_models_is_string(self):
        try:
            self.assertIsInstance(self.config["models"], str, "The value for 'models' in the config file should be a string. Please check your config file.")
        except AssertionError as e:
            print(e)
        
def test_models_are_unique_and_alphanumeric(self):
    try:
        models = self.config["models"]
        # Check if models are unique
        self.assertNotEqual(len(models), len(set(models)), "The models in the config file should not be the same. Please remove any duplicate models.")
        # Check if models contain only alphanumeric characters
        for model in models:
            self.assertTrue(model.isalnum(), "The models in the config file should only contain alphanumeric characters. Please check your config file.")
    except AssertionError as e:
        print(e)

    def test_extract_genomic_region_length_is_number(self):
        try:
            self.assertIsInstance(self.config["extract_genomic_region-length"], int, "The value for 'extract_genomic_region-length' in the config file should be a number. Please check your config file.")
        except AssertionError as e:
            print(e)

if __name__ == '__main__':
    unittest.main()