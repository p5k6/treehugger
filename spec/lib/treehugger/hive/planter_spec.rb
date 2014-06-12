require 'spec_helper'
require 'treehugger'

describe TreeHugger::Hive::Planter do
  HIVE_TEST_CASES.each do |test_case|
    context ".parse_tree" do
      let!(:subject) { TreeHugger::Hive::Planter.parse_tree(test_case[:ast_string]) }
  
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
        tokens = test_case[:ast_string].gsub(/[()]/, "\x01").gsub(/[\s]+/, " ").strip.split("\x01").map { |x| x.strip }.select { |x| !x.empty? }
  
        ast_tokens = subject.collect { |node| node.token }
  
        ### both should contain all tokens above - everything within a set of parens.
        ast_tokens.should_not be_empty
        tokens.should_not be_empty
        token_diff = ((ast_tokens - tokens) + (tokens - ast_tokens))
        token_diff.should be_empty
      end
    end
  end
end
