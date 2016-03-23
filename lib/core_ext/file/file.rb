module ColorTree
  module CoreExt
    module File
      def check_file arg, which
        help = " Try color_tree --help for help."

        abort_if arg.nil?,
                 "You must provide a #{which} file.#{help}"

        abort_unless Object::File.exists?(arg),
                     "The file #{arg} doesn't exist.#{help}"

        arg
      end

      def parse_name_map fname
        check_file fname, :name_map

        name_map = {}
        Object::File.open(fname).each_line do |line|
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
                 "Names in column 2 of name map file must be unique"

        name_map
      end
    end
  end
end
