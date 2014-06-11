require 'spec_helper'
require 'treehugger'

describe TreeHugger::Hive::Planter do
  context ".parse_tree" do
    let(:ast_string) { 
      <<-EOL
              (TOK_QUERY (TOK_FROM (TOK_JOIN (TOK_TABREF (TOK_TABNAME josh test_cities) a) (TOK_TABREF (TOK_TABNAME cities) b))) (TOK_INSERT (TOK_DESTINATION (TOK_DIR TOK_TMP_FILE)) (TOK_SELECT (TOK_SELEXPR (. (TOK_TABLE_OR_COL a) id)) (TOK_SELEXPR (. (TOK_TABLE_OR_COL b) id)))))
      EOL
    }

    subject { TreeHugger::Hive::Planter.parse_tree(ast_string) }

    it "returns a TreeHugger::Tree object " do
      subject.class.should be(TreeHugger::Tree)
    end

    it "root node should have children and no parents" do
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

    it "should contain all tokens from ast_string" do
      ### find all our tokens using a different method than the Planter
      tokens = ast_string.gsub(/[()]/, "\x01").gsub(/[\s]+/, " ").strip.split("\x01").map { |x| x.strip }.select { |x| !x.empty? }

      ast_tokens = subject.collect { |node| node.token }

      ### both should contain all tokens above - everything within a set of parens.
      ast_tokens.should_not be_empty
      tokens.should_not be_empty
      ((ast_tokens - tokens) + (tokens - ast_tokens)).should be_empty
    end

  end

end
