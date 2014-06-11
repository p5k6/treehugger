require 'spec_helper'
require 'treehugger'

describe Treehugger::Hive::Planter do
  context ".parse_tree" do
    let(:ast_string) { 
      <<-EOL
              (TOK_QUERY (TOK_FROM (TOK_JOIN (TOK_TABREF (TOK_TABNAME josh test_cities) a) (TOK_TABREF (TOK_TABNAME cities) b))) (TOK_INSERT (TOK_DESTINATION (TOK_DIR TOK_TMP_FILE)) (TOK_SELECT (TOK_SELEXPR (. (TOK_TABLE_OR_COL a) id)) (TOK_SELEXPR (. (TOK_TABLE_OR_COL b) id)))))
      EOL
    }

    subject { TreeHugger::Hive::Planter.parse_tree(ast_string) }

    it "returns a Treehugger::Tree object " do
      subject.class.should be(TreeHugger::Tree)
    end

    its "root node should have children and no parents" do
      subject.parent.should be(nil)
      subject.children.should_not be_empty
    end

    it "parens should be used to parse only, and thus should not be in any token" do
      parens_found = 0
      subject.each { |node|
        parens_found += 1 if /[()]/ =~ node.token
      }
      parens_found.should eql(0)
    end

  end

end
