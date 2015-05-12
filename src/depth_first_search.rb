module Graph
  class DepthFirstSearch
    attr_reader :graph

    class DFSEdge
      attr_accessor :u, :v
      attr_accessor :pi
      attr_accessor :biconnected_component

      def initialize(u, v)
        @u = u
        @v = v
        @pi = false
        @biconnected_component = nil
      end
    end

    class DFSNode
      attr_accessor :name
      attr_accessor :color
      attr_accessor :depth, :low
      attr_accessor :pi, :pi_edge
      attr_accessor :articulation_point
      attr_accessor :edges, :next

      def initialize(name)
        @name = name

        @color   = :white
        @depth   = Float::INFINITY
        @low     = Float::INFINITY
        @pi      = nil
        @pi_edge = nil
        @edges   = []
        @articulation_point = false
      end
    end

    class DFSGraph
      attr_accessor :nodes
      attr_accessor :edges
      attr_accessor :discovery_order
      attr_accessor :biconnected_components

      def initialize(source_graph)
        @nodes = {}
        @edges = []
        @discovery_order = []
        @biconnected_components = []

        seen_nodes = Set.new
        source_edges = []
        source_graph.nodes.each do |u|
          seen_nodes.add(u.name)
          u.connected_nodes.each do |v|
            if !seen_nodes.include?(v.name)
              source_edges.push([u.name, v.name])
            end
          end
        end

        source_edges.each do |node_pair|
          edge = DFSEdge.new(node_pair[0], node_pair[1])
          @edges.push edge

          @nodes[node_pair[0]] = DFSNode.new(node_pair[0]) unless @nodes[node_pair[0]]
          @nodes[node_pair[1]] = DFSNode.new(node_pair[1]) unless @nodes[node_pair[1]]

          @nodes[node_pair[0]].edges.push(edge)
          @nodes[node_pair[1]].edges.push(edge)
        end
      end

      def other(e,u)
        nodes[e.u.equal?(u.name) ? e.v : e.u]
      end

      def depth_first_search
        time = 1
        stack = []

        u = root = nodes.values.first
        u.low = u.depth = 0

        # This stack is used to implement recursion call stack behavior, that's why
        # it's called simply "stack"
        stack.push u
        until stack.empty?
          u = stack.pop

          if u.color == :white
            discovery_order.push(u)

            u.color = :gray
            u.next = Array.new(u.edges)
            u.low = u.depth

            time += 1
          else
            e = u.next.shift
            v = other(e, u)

            if u.depth <= v.low && !u.articulation_point && !u.equal?(root)
              u.articulation_point = true
            end

            u.low = [u.low, v.low].min
          end

          if u.next.empty?
            time += 1
            u.color = :black
          end

          until u.next.empty?
            e = u.next.first
            v = other(e, u)

            if v.color != :white
              if !u.pi.equal?(v)
                u.low = [u.low, v.depth].min
              end
              u.next.shift

              if u.next.empty?
                time += 1
                u.color = :black
              end
            else
              e = u.next.first
              v = other(e, u)

              stack.push(u) # push u so that it is visited a second time on the way up
              stack.push(v)
              v.pi = u
              v.pi_edge = e
              e.pi = true
              v.depth = u.depth + 1
              break
            end
          end
        end

        root.articulation_point = root.edges.count { |e| e.pi } >= 2

        self
      end

      # http://en.wikipedia.org/wiki/Bridge_(graph_theory)#Bridge-Finding_with_Chain_Decompositions
      def compute_biconnected_components
        nodes.values.each { |u| u.color = :white }

        bcc = 0
        bc_counter = 0

        # walk the graph in discovery order
        discovery_order.each do |u|
          u.color = :gray

          cycles = 0
          # for each edge not in pi (not in the predecessor subgraph)
          u.edges.each do |e|
            next if e.pi || !e.biconnected_component.nil?

            v = other(e, u)

            next if nodes.first[1].equal?(v)

            cycles += 1

            v_low = v.low

            stack = [e]
            while v.pi_edge && v.color == :white
              stack.push(v.pi_edge)
              v.color = :gray
              v = v.pi
            end

            if v.color != :white
              bcc = v.pi_edge ? v.pi_edge.biconnected_component : nil
              if bcc.nil? || (v.articulation_point && v.low < v_low)
                biconnected_components.push(Set.new)
                bcc = bc_counter
                bc_counter += 1
              end
            end

            until stack.empty?
              e = stack.pop
              e.biconnected_component = bcc

              biconnected_components[bcc].tap do |component|
                component.add(e.u)
                component.add(e.v)
              end
            end
          end
        end

        self
      end
    end

    def initialize(graph)
      @graph = graph
      @dfs_graph = DFSGraph.new(graph)
    end

    def find_all_biconnected_components
      @dfs_graph.
        depth_first_search.
        compute_biconnected_components.
        biconnected_components
    end
  end
end
