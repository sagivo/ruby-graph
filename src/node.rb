module Graph
  class Node

    attr_reader :name, :connected_nodes

    def initialize(name)
      @name = name
      @connected_nodes = Set.new
    end

    def connect_node(other_node)
      connected_nodes.add(other_node)
    end
  end
end
