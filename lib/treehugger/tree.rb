### Inspiration via sepp2k, http://www.dreamincode.net/forums/topic/316392-walking-a-nested-hash-that-acts-as-a-tree-manipulate-elements/

module TreeHugger

  ALL_COLUMNS = "ALL_COLUMNS"

  Tree = Struct.new(:token, :children, :parent) do
    # This adds enumerable methods like map, select, reject etc to the Tree class
    include Enumerable

    def each(depth = 0, &blk)
      yield self, depth
      children.each do |node|
        node.each(depth + 1, &blk)
      end
    end
  end

end
