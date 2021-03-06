require 'spec_helper'
require 'treehugger'

describe TreeHugger::Hive::Distiller do
  HIVE_TEST_CASES.each do |test_case|

    context ".populate_columns_and_tables" do
      let!(:subject)  { TreeHugger::Hive::Distiller.new(test_case[:ast_string]) }
      before(:each) {
        subject.populate_columns_and_tables
      }
      
      it "populates column references" do
        subject.column_references.should_not be_nil
        subject.column_references.should_not be_empty
      end
      it "populates table references" do
        subject.table_references.should_not be_nil
        subject.table_references.should_not be_empty
      end
    end

    context ".get_column_table_intersection" do
      #### todo - use the column_table intersection from the 
      #
      let!(:subject)  { TreeHugger::Hive::Distiller.new(test_case[:ast_string]) }

      it "grabs columns correctly" do
        puts "testing columns for query: #{test_case[:raw_query][0..50]}...." unless test_case[:raw_query].nil?
        diff = ( (subject.get_column_table_intersection.sort_by { |x| [ x[:table],x[:col_name]] }.uniq - test_case[:columns].sort_by { |x| [ x[:table],x[:col_name]] }.uniq) + \
                (test_case[:columns].sort_by { |x| [ x[:table],x[:col_name]] }.uniq - subject.get_column_table_intersection.sort_by { |x| [ x[:table],x[:col_name]] }.uniq))
        diff.should be_empty
      end
    end

    after(:all) do
      subject = nil
      diff = nil
      test_case = nil
    end
  end
end
