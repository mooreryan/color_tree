module ColorTree
  module CoreExt
    module Hash
      def duplicate_values? hash
        values = hash.values
        values.count != 1 && values.count != values.uniq.count
      end
    end
  end
end
