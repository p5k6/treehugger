require 'securerandom'

module TreeHugger
  module Hive 
    class Distiller
      attr_reader :column_references, :table_references

      def initialize(ast_string)
        #### TODO - allow a TreeHugger::Tree object to initialize
        @master_tree = TreeHugger::Hive::Planter.parse_tree(ast_string)
      end

      def populate_columns_and_tables
        @master_references = get_main_references
        @column_references = @master_references[:column_references]
        @table_references = @master_references[:table_references]
      end

      def get_column_table_intersection
        populate_columns_and_tables if @table_references.nil? || @column_references.nil?
        @table_references.map { |a|
          @column_references.map { |b|
            {:column_name => b[:col_name], :table => a[:table], :db => a[:db] } if a[:alias] == b[:alias] && a[:query_uuid] == b[:query_uuid]
          }
        }.flatten.compact.sort_by { |x| [ x[:table],x[:col_name]] }.uniq
      end

      private

      def get_main_references
        table_refs = []
        column_refs = []
        subquery_refs = []
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

          ### currently using this only to figure out if missing alias refs (i.e. in subquery with only 1 table referenced) should be applied to all 
          ### columns at a particular depth
          if node.token == "TOK_SUBQUERY"
            #### TODO - fix up for potential 3 length (ie josh.table_name)
            _alias = node.children[1].token
            subquery_refs << { :alias => _alias, :query_uuid => query_uuid_stack[-1][:uuid] }
          end
        }

        #ridiculously convoluted way of getting subqueries with all columns where there's no alias
        singleton_uuids = table_refs.inject(Hash.new(0)) { |h,e| h[e[:query_uuid]] +=1; h }.select { |k,v| v==1 }.keys.select { |x| ! (subquery_refs.map { |y| y[:query_uuid] }.include? x) }
        #
        column_refs = column_refs.concat(singleton_uuids.collect { |uuid|
            tbl = table_refs.select { |i| i[:query_uuid] == uuid }.first
            allcol_refs = temp_splat_storage.select { |i| i[:query_uuid] == uuid }

            allcol_refs.map { |y| 
              { :col_name => TreeHugger::ALL_COLUMNS, :alias => tbl[:alias], :query_uuid => uuid } if uuid == y[:query_uuid]
            }.compact
          }.flatten
        )

        ### now fix up missing references for single table subquery without alias in column_refs
        column_refs.select { |col| col[:alias].nil? }.each { |col| 
          tbl_ref = table_refs.select { |tbl| singleton_uuids.include? tbl[:query_uuid] }.find { |tbl| tbl[:query_uuid] == col[:query_uuid] }
          col[:alias] = tbl_ref[:alias] if tbl_ref
        }

        { :column_references => column_refs, :table_references => table_refs}
      end
    end
  end
end
