require 'treehugger'
require 'yaml'

HIVE_TEST_CASES = YAML.load_file(File.join(File.expand_path('..',__FILE__),'support',"hive_test_data.yml"))
