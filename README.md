# Treehugger

Treehugger: a gem for parsing a text-based tree into an internal data structure, and outputting some "distilled" data about the tree. 

Currently, the gem is only used for parsing abstract syntax trees as provided from the hive explain plan, and distilling the list of columns referenced within the hive query.

## Installation

Add this line to your application's Gemfile:

    gem 'treehugger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install treehugger

## Data Types
TreeHugger::Tree is defined within this gem. It is an n-ary tree containing a token, and a pointer to both the array of children, and the (single) parent object. It includes Enumerable, and overrides the default each method to include a 'depth' counter.

## Usage
There are main functions that are intended for end user use (at this point in time)

#### TreeHugger::Hive::Planter.parse_tree(hive_ast_string)
This is a class level function that takes a hive AST string input, and returns a TreeHugger::Tree object. Use this if you want access to the core tree object

#### TreeHugger::Hive::Distiller.new(hive_ast_string)
Instantiates the distiller object. attr_reader on column_references and table_references. Note that these two instance variables are not (as of now) set up to auto-initialize.

#### TreeHugger::Hive::Distiller#populate_columns_and_tables
Instance method for the disiller object created. Populates the columns/table references mentioned previously.

#### TreeHugger::Hive::Distiller#get_column_table_intersection
Primary instance method intended to by used after creation of distiller object. Runs the populate_columns_and_tables method, populates the instance variables column_references and table_references, and returns the intersection as an array of hashes.

#### bin/treehugger
Binary included with the gem. Accepts input from either stdin or a file, which should be a Hive AST. Behind the scenes, creates a new distiller object and runs get_column_table_intersection. Returns the array of hashes, but in this case as json.


## A note on testing
For this test, I decided the best way to approach was to create a list of inputs and expected outputs in a separate file. The spec/support/hive_test_data.yml contains an array of hashes, this time with input data (:ast_string), and expected output data (:columns - which should probably be renamed). :columns is the array of hashes that's expected to be returned by get_column_table_intersection. The query is also stored here for posterity's sake.

## Current Limitations
If you have a Hive query which selects a column without using an alias from multiple (joined) tables, the column will not be returned

#### Example (where 'name' is unique to table b):
    select a.id, name from cities a join deals b on a.id=b.id

This is not something that would be easy to solve with the current implementation, as the TreeHugger gem does not have access to the underlying schemas. I'm considering allowing a schema to be passed into the distiller object, which could then be used to determine the owner of the non-alias'd column

## Contributing

1. Fork it ( http://github.com/<my-github-username>/treehugger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
