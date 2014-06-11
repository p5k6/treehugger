module TreeHugger
  module Hive
    module Planter

      ### planting the hive AST 

      ## parse_tree takes ast_string as input, returns TreeHugger::Tree object
      def self.parse_tree(ast_string, options = {})
        # Not being used at the moment
        hive_version = options[:hive_version] || "0.10"
        distribution_version = options[:distribution_version] || "cdh42"

        parser_positions = []
        master_tree = TreeHugger::Tree.new
        master_tree.children = []
        last_branch = nil

        ### get the location of nesting depths
        ast_string.scan(/[()]/) { |y| parser_positions << Regexp.last_match.offset(0)[0] }

        parser_positions.each_with_index { |y,idx| 
          if ast_string[y] == "("
            last_branch = master_tree if last_branch.nil?
            token = ast_string[y..-1].match( /^\((.*?)[\(\)]/ ).captures.first.strip
            if master_tree.token.nil?
              last_branch = master_tree
              master_tree.token = token
            else
              last_branch.children << TreeHugger::Tree.new(token,[])
              last_branch.children[-1].parent = last_branch
            end
          elsif ast_string[y] == ")"
            pre_token = ast_string[y..-1].match( /^\)(.*?)[\(\)]/ )
            if !pre_token.nil?
              x = pre_token.captures.first.strip
              last_branch.children << TreeHugger::Tree.new(x, []) unless x.empty?
              last_branch.children[-1].parent = last_branch
            end
            last_branch = last_branch.parent unless last_branch.parent.nil?
          else
            puts y
            raise "could not parse the tree"
          end

          if (idx+1) < parser_positions.length and '(' == ast_string[parser_positions[idx+1]]
            last_branch = last_branch.children[-1]
          end
        }
        master_tree
      end
    end
  end
end
