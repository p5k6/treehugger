require "treehugger/version"
require "treehugger/hive/planter"
require "treehugger/hive/distiller"
require "treehugger/tree"

module TreeHugger
#   # Your code goes here...
#   ALL_COLUMNS = "ALL_COLUMNS"
# 
#   class Data
# 
#     def self.get_tree(query_ast)
#       parser_positions = []
# 
#       ### get the location of nesting depths
#       query_ast.scan(/[()]/) { |y| parser_positions << Regexp.last_match.offset(0)[0] }
# 
#       master_tree = TreeHugger::Tree.new
#       master_tree.children = []
# 
#       last_branch = nil
# 
#       parser_positions.each_with_index { |y,idx| 
#         if q[y] == "("
#           last_branch = master_tree if last_branch.nil?
#           token = q[y..-1].match( /^\((.*?)[\(\)]/ ).captures.first.strip
#           if master_tree.token.nil?
#             last_branch = master_tree
#             master_tree.token = token
#           else
#             last_branch.children << Tree.new(token,[])
#             last_branch.children[-1].parent = last_branch
#           end
#         elsif q[y] == ")"
#           pre_token = q[y..-1].match( /^\)(.*?)[\(\)]/ )
#           if !pre_token.nil?
#             x = pre_token.captures.first.strip
#             last_branch.children << Tree.new(x, []) unless x.empty?
#             last_branch.children[-1].parent = last_branch
#           end
#           last_branch = last_branch.parent unless last_branch.parent.nil?
#         else
#           puts y
#           raise "something went wrong"
#         end
# 
#         if (idx+1) < parser_positions.length and '(' == q[parser_positions[idx+1]]
#           last_branch = last_branch.children[-1]
#         end
#       }
# 
#       # I know you don't need this. But I like an explicit reminder 
#       return master_tree
#     end
# 
#     ### master_tree should be of the TreeHugger::Tree class
#     def self.get_columns_and_tables(master_tree)
#       table_refs = []
#       column_refs = []
#       query_uuid_stack = [] 
#       last_stack_depth = nil
# 
#       master_tree.each { |node,depth| 
#         if node.token == "TOK_QUERY"
#           query_uuid_stack.push({ :uuid => SecureRandom.uuid, :depth => depth } )
#         end
# 
#         if !query_uuid_stack.empty? && depth < query_uuid_stack[-1][:depth]
#           query_uuid_stack.pop
#         end
# 
#         current_uuid = query_uuid_stack[-1][:uuid] unless query_uuid_stack[-1].nil?
# 
#         node.query_depth_uuid = current_uuid
# 
#         if node.token == "TOK_TABREF"
#           db_name = "default"
# 
#           _alias = node.children[1].token if (!node.children.empty? && !node.children[1].nil?)
#           refs = node.children[0].token.gsub(/\s/, " ").split(" ")
#           if refs.length == 3
#             db_name = refs[1]
#           end
# 
#           table_refs << { :table => refs[-1], :db => db_name, :alias => _alias, :query_uuid => node.query_depth_uuid}
#         end
# 
#         if node.token =~ /^TOK_TABLE_OR_COL/
#           alias_ref = nil
#           col_name = ""
# 
#           if node.parent.token == "."
#             col_name = node.parent.children[1].token
#             alias_ref = node.parent.children[0].token.gsub(/\s/, " ").split(" ")[-1]
#           else
#             col_name = node.token.gsub(/\s/, " ").split(" ")[-1]
#           end
#           column_refs << { :col_name => col_name, :alias => alias_ref, :query_uuid => node.query_depth_uuid }
#         end
# 
#         if node.token == "TOK_ALLCOLREF" && !node.children.empty?
#           col_name = ALL_COLUMNS
#           alias_ref = node.children[-1].token.gsub(/\s/, " ").split(" ")[-1]
#           column_refs << { :col_name => col_name, :alias => alias_ref, :query_uuid => node.query_depth_uuid }
#         end
#       }
#     end
# 
#     def self.get_single_sub_query_references(master_tree)
#       query_leafs = []
#       leafs = []
# 
#       ###find our leaf nodes
#       master_tree.each { |node| 
#         leafs << n if node.children == []
#       } 
# 
#       # traverse in reverse, find the LCA for TOK_QUERY
#       leafs.each { |n|
#         last_node = n
#         until last_node.token == "TOK_QUERY"
#           last_node = last_node.parent
#         end
#         query_leafs << last_node
#       } ; nil
# 
#       # Uniqueify them
#       query_leafs.uniq! ; nil
#       column_refs_2 = []
#       table_refs_2 = []
# 
#       ## now we go through, find those that only have one table ref, and associate the columns to that one table ref
#       query_leafs.each { |leaf| 
#         temp_column_refs = []
#         temp_tables = []
# 
#         leaf.each { |node| 
#           if node.token == "TOK_TABREF" 
#             db_name = nil
#             refs = node.children[0].token.gsub(/\s/, " ").split(" ")
# 
#             if refs.length == 3
#               db_name = refs[1]
#             end
# 
#             ### no alias, so we're copying table name as alias
#             temp_tables << { :table => refs[-1], :db => db_name, :alias => refs[-1]}
#           end
# 
#           if node.token =~ /^TOK_TABLE_OR_COL/
#             ## wer're only looking for column to table refs where there is no alias
#             temp_column_refs << node.token.gsub(/\s/, " ").split(" ")[-1]
#           end
# 
#           if node.token =~ /^TOK_SELEXPR/
#             temp_column_refs << ALL_COLUMNS
#           end
#         }
# 
#         if temp_tables.length == 1
#           table_refs_2 << temp_tables.first
#           temp_column_refs.each { |col|
#             column_refs_2 << { :col_name => col, :alias => temp_tables.first[:table]}
#           }
#         end
# 
#       }
# 
#       return { :col_refs => column_refs_2, :table_refs => table_refs_2 }
#     end
#   end
end
