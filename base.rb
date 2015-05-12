module Graph
  class Base

    attr_reader :node_map

    def initialize
      @node_map = {}
    end

    def add_nodes(*node_names)
      node_names.each do |node_name|
        node_map[node_name] ||= Node.new(node_name)
      end
    end

    def connect_nodes(node_name, other_node_name)
      raise NotImplementedError
    end

    def [](name)
      node_map[name]
    end

    def nodes
      node_map.values
    end
  end
end
