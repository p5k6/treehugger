require 'spec_helper'
require 'treehugger'

describe TreeHugger::Hive::Distiller do
 let(:ast_string) { 
    <<-EOL
                          (TOK_QUERY (TOK_FROM (TOK_JOIN (TOK_TABREF (TOK_TABNAME josh test_cities) a) (TOK_TABREF (TOK_TABNAME cities) b))) (TOK_INSERT (TOK_DESTINATION (TOK_DIR TOK_TMP_FILE)) (TOK_SELECT (TOK_SELEXPR (. (TOK_TABLE_OR_COL a) id)) (TOK_SELEXPR (. (TOK_TABLE_OR_COL b) id)))))
    EOL
  } 

  subject { TreeHugger::Hive::Distiller.new(ast_string) }

  context ".populate_columns_and_tables" do
    before(:all) { subject.populate_columns_and_tables}
    it "populates column references" do
      subject.column_references.should_not be_nil
      subject.column_references.should_not be_empty
    end
    it "populates table references" do
      subject.table_references.should_not be_nil
      subject.table_references.should_not be_empty
    end
  end
end
