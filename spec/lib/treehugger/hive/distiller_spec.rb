require 'spec_helper'
require 'treehugger'

describe TreeHugger::Hive::Distiller do
  HIVE_TEST_CASES.each do |test_case|

    before(:each) { 
      @subject =  TreeHugger::Hive::Distiller.new(test_case[:ast_string])
      @subject.populate_columns_and_tables
    }

    context ".populate_columns_and_tables" do
      
      it "populates column references" do
        @subject.column_references.should_not be_nil
        @subject.column_references.should_not be_empty
      end
      it "populates table references" do
        @subject.table_references.should_not be_nil
        @subject.table_references.should_not be_empty
      end
    end

    context ".get_column_table_intersection" do
      #### todo - use the column_table intersection from the 
      #
      it "grabs columns correctly" do
        diff = ( (@subject.get_column_table_intersection.sort_by { |x| [ x[:table],x[:col_name]] }.uniq - test_case[:columns].sort_by { |x| [ x[:table],x[:col_name]] }.uniq) + \
                (test_case[:columns].sort_by { |x| [ x[:table],x[:col_name]] }.uniq - @subject.get_column_table_intersection.sort_by { |x| [ x[:table],x[:col_name]] }.uniq))
        diff.should be_empty
      end
    end
  end
end
