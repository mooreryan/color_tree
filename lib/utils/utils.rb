module ColorTree
  module Utils
    include AbortIf
    include ColorTree::CoreExt::String

    def leaf? tree, node
      tree.children(node).empty?
    end

    def add_color_to_leaf_branch patterns, node, exact
      num_matches = 0
      color = nil
      already_matched = false

      if exact # treat patterns as string matching
        node_s = node.to_s
        if patterns.has_key? node_s
          color = patterns[node_s]

          return color
        else
          return nil
        end
      else
        node_s = node.to_s

        patterns.each do |pattern, this_color|
          if node_s =~ pattern
            abort_if already_matched,
                     "Non specific matching for #{node_s}"

            color = this_color
            already_matched = true
          end
        end

        return color
      end
    end

    def get_color node
      begin
        node.name.match(/\[&!color="#[0-9A-Fa-f]{6}"\]/)[0]
      rescue NoMethodError => e
        nil
      end
    end

    def color_nodes patterns, tree, node, exact
      # # check if it needs color, if so set the color
      # color = add_color_to_leaf_branch patterns, node, exact

      # clean the name no matter what
      node.name = clean_name node.name

      # if its a leaf that hasnt been checked & needs color
      if leaf?(tree, node) && !already_checked?(node.name) # && color
        # check if it needs color, if so set the color

        # NOTE: this was originally before cleaning the node name a
        # couple lines up, does it matter that it is after?
        color = add_color_to_leaf_branch patterns, node, exact

        # add color to the name
        node.name = node.name + color if color
      elsif !leaf?(tree, node)
        children = tree.children(node) # get the children
        children_colors = []
        children.each do |child|
          # recurse to color the child if needed
          color_nodes patterns, tree, child, exact
          children_colors << get_color(child) # add color of the child
        end

        # if all the children have the same color
        if children_colors.uniq.count == 1
          # set the branch node to only the color name
          node.name = children_colors[0]
        end
      end

      return node
    end
  end
end
