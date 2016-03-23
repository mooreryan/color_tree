include AbortIf

module ColorTree
  module Utils

    def hex? str
      str.match(/^#[0-9A-Fa-f]{6}$/)
    end

    def check_file arg, which
      help = " Try color_tree --help for help."

      abort_if arg.nil?,
               "You must provide a #{which} file.#{help}"

      abort_unless File.exists?(arg),
                   "The file #{arg} doesn't exist.#{help}"

      arg
    end

    def clean str
      str.gsub(/[^\p{Alnum}_]+/, "_").gsub(/_+/, "_")
    end

    def duplicate_values? hash
      values = hash.values
      values.count != 1 && values.count != values.uniq.count
    end

    def parse_name_map fname
      check_file fname, :name_map

      name_map = {}
      File.open(fname).each_line do |line|
        oldname, newname = line.chomp.split "\t"


        abort_if oldname.nil? || oldname.empty?,
                 "Column 1 missing for line: #{line.inspect}"

        abort_if newname.nil? || newname.empty?,
                 "Column 2 missing for line: #{line.inspect}"

        oldname = clean oldname
        newname = clean newname

        abort_if name_map.has_key?(oldname),
                 "#{oldname} is repeated in column 1"

        name_map[oldname] = newname
      end

      abort_if duplicate_values?(name_map),
               "Names in column 2 of name nap file must be unique"

      name_map
    end

    def has_color name
      name.match(/(.*)(\[&!color="#[0-9A-Fa-f]{6}"\])/)
    end

    def clean_name name
      if name.nil?
        nil
      else
        match = has_color name
        if match
          name = match[1]
          color = match[2]

          clean(name) + color
        else
          clean(name)
        end
      end
    end

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

    def already_checked? name
      name.match(/\[&!color="#[0-9A-Fa-f]{6}"\]/)
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
