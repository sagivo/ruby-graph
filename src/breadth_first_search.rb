module Graph
  class BreadthFirstSearch

    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    def find_connected_component(node_name)
      visited_node_names = Set.new([node_name])
      node_name_queue = [node_name]

      while node_name_queue.present?
        current_node_name = node_name_queue.pop
        graph[current_node_name].connected_nodes.each do |connected_node|
          connected_node_name = connected_node.name
          if visited_node_names.exclude?(connected_node_name)
            visited_node_names.add(connected_node_name)
            node_name_queue.unshift(connected_node_name)
          end
        end
      end

      visited_node_names
    end

    def find_all_connected_components
      first_node_name = graph.nodes.first
      visited_node_names = Set.new([first_node_name])
      connected_components = []

      graph.nodes.each do |node|
        node_name = node.name
        next if visited_node_names.include?(node_name)
        connected_component = find_connected_component(node_name)
        visited_node_names.merge(connected_component)
        connected_components << connected_component
      end

      connected_components
    end
  end
end
