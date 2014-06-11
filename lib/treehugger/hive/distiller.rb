require 'securerandom'

module TreeHugger
  module Hive 
    class Distiller
      attr_reader :column_references, :table_references

      def initialize(ast_string)
        @master_tree = TreeHugger::Hive::Planter.parse_tree(ast_string)
      end

      def populate_columns_and_tables
        ## put into initializer???
        @master_references = get_main_references
        @column_references = @master_references[:column_references]
        @table_references = @master_references[:table_references]
      end

      def get_column_table_intersection
        populate_columns_and_tables if @table_references.nil? || @column_references.nil?
        @table_references.map { |a|
          @column_references.map { |b|
            {:col_name => b[:col_name], :table => a[:table], :db => a[:db] } if a[:alias] == b[:alias] && a[:query_uuid] == b[:query_uuid]
          } 
        }.flatten.compact
      end

      def get_main_references
        table_refs = []
        column_refs = []
        query_uuid_stack = [] 
        temp_splat_storage = []

        @master_tree.each { |node,depth| 
          if node.token == "TOK_QUERY"
            query_uuid_stack.push({ :uuid => SecureRandom.uuid, :depth => depth } )
          end

          if !query_uuid_stack.empty? && depth < query_uuid_stack[-1][:depth]
            query_uuid_stack.pop
          end

          if node.token == "TOK_TABREF"
            db_name = "default"
            refs = node.children[0].token.gsub(/\s/, " ").split(" ")

            # default alias to tablename, override if provided
            _alias = refs[-1]
            _alias = node.children[1].token if (!node.children.empty? && !node.children[1].nil?)

            if refs.length == 3
              db_name = refs[1]
            end

            table_refs << { :table => refs[-1], :db => db_name, :alias => _alias, :query_uuid => query_uuid_stack[-1][:uuid]}
          end

          if node.token =~ /^TOK_TABLE_OR_COL/
            alias_ref = nil
            col_name = nil

            if node.parent.token == "."
              col_name = node.parent.children[1].token
              alias_ref = node.parent.children[0].token.gsub(/\s/, " ").split(" ")[-1]
            else
              col_name = node.token.gsub(/\s/, " ").split(" ")[-1]
            end
            column_refs << { :col_name => col_name, :alias => alias_ref, :query_uuid => query_uuid_stack[-1][:uuid] }
          end

          if node.token == "TOK_ALLCOLREF" && !node.children.empty?
            col_name = TreeHugger::ALL_COLUMNS
            alias_ref = node.children[-1].token.gsub(/\s/, " ").split(" ")[-1]
            column_refs << { :col_name => col_name, :alias => alias_ref, :query_uuid => query_uuid_stack[-1][:uuid] }
          end

          ### thinking - collect in temp storage, if count of tables grouped by uuid = 1, then that table has dependency on *
          if node.token == "TOK_SELEXPR TOK_ALLCOLREF"
            temp_splat_storage << { :query_uuid => query_uuid_stack[-1][:uuid], :col_name => TreeHugger::ALL_COLUMNS }
          end

        }

       #ridiculously convoluted way of getting subqueries with all columns where there's no alias
       column_refs = column_refs.concat(
         table_refs.inject(Hash.new(0)) { |h,e| h[e[:query_uuid]] +=1; h } \
         .select { |k,v| v==1 }.keys.collect \
         { |uuid|
           tbl = table_refs.select { |i| i[:query_uuid] == uuid }.first
           allcol_refs = temp_splat_storage.select { |i| i[:query_uuid] == uuid }

           allcol_refs.map { |y| 
             { :col_name => TreeHugger::ALL_COLUMNS, :alias => tbl[:alias], :query_uuid => uuid } if uuid == y[:query_uuid]
           }.compact
         }.flatten
       )


        { :column_references => column_refs, :table_references => table_refs}

      end








      #### pretty sure this could be moved into main_references, and avoid a second traversal of the tree. But works for now
      def get_singleton_subquery_refs
        query_leafs = []
        leafs = []

        ###find our leaf nodes
        @master_tree.each { |n| 
          leafs << n if n.children == []
        }

        # traverse in reverse, find the LCA for TOK_QUERY
        leafs.each { |n|
          last_node = n
          until last_node.token == "TOK_QUERY"
            last_node = last_node.parent
          end
          query_leafs << last_node
        }

        # Uniqueify them
        query_leafs.uniq! ; nil
        column_refs = []
        table_refs = []

        ## now we go through, find those that only have one table ref, and associate the columns to that one table ref
        query_leafs.each { |n| 
          temp_column_refs = []
          temp_tables = []

          n.each { |nn| 
            if nn.token == "TOK_TABREF" 
              db_name = "default"
              refs = nn.children[0].token.gsub(/\s/, " ").split(" ")

              if refs.length == 3
                db_name = refs[1]
              end

              ### no alias, so we're copying table name as alias
              temp_tables << { :table => refs[-1], :db => db_name, :alias => refs[-1]}
            end

            if nn.token =~ /^TOK_TABLE_OR_COL/
              ## wer're only looking for column to table refs where there is no alias specified
              temp_column_refs << nn.token.gsub(/\s/, " ").split(" ")[-1]
            end

            if nn.token = "TOK_SELEXPR TOK_ALLCOLREF"
              temp_column_refs << TreeHugger::ALL_COLUMNS
            end
          }

          if temp_tables.length == 1
            table_refs << temp_tables.first
            temp_column_refs.each { |col|
              column_refs << { :col_name => col, :alias => temp_tables.first[:table]}
            }
          end
        } 

        { :column_references => column_refs, :table_references => table_refs }
      end
    end
  end
end
