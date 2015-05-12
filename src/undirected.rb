module Graph
  class Undirected < Base

    def connect_nodes(node_name, other_node_name)
      node_map[node_name].connect_node(node_map[other_node_name])
      node_map[other_node_name].connect_node(node_map[node_name])
    end
  end
end