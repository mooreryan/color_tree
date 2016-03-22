module ColorTree
  module Utils

    def hex? str
      str.match(/^#[0-9A-Fa-f]{6}$/)
    end

    def check_file arg, which
      help = "\nTry color_tree --help for help."
      if arg.nil?
        abort("Argument error: You must provide a #{which} file.#{help}")
      elsif !File.exists?(arg)
        abort("Argument error: The file #{arg} doesn't exist.#{help}")
      else
        arg
      end
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

        if oldname.nil? || oldname.empty?
          abort "ERROR: Column 1 missing for line: #{line.inspect}"
        end

        if newname.nil? || newname.empty?
          abort "ERROR: Column 2 missing for line: #{line.inspect}"
        end

        oldname = clean oldname
        newname = clean newname

        if name_map.has_key? oldname
          abort("Name map error: #{oldname} is repeated in column 1")
        else
          name_map[oldname] = newname
        end
      end

      if duplicate_values? name_map
        p name_map.values
        p name_map.values.count
        p name_map.values.uniq.count
        abort("Name map error: Names in column 2 must be unique")
      end

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

      if exact # treat patterns as string matching
        patterns.each do |pattern, this_color|
          if node.to_s == pattern
            num_matches += 1
            color = this_color
          end
        end
      else
        patterns.each do |pattern, this_color|
          if node.to_s.match(/#{pattern}/i)
            num_matches += 1
            color = this_color
          end
        end
      end

      if num_matches.zero?
        nil
      elsif num_matches == 1
        color
      else
        abort("Error: non-specific pattern")
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
      # check if it needs color, if so set the color
      color = add_color_to_leaf_branch patterns, node, exact

      # clean the name no matter what
      node.name = clean_name node.name

      # if its a leaf that hasnt been checked & needs color
      if leaf?(tree, node) && !already_checked?(node.name) && color
        # add color to the name
        node.name = node.name + color
      # if it isn't a leaf
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
