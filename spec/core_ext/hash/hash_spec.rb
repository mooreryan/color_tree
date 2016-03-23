require "spec_helper"

describe ColorTree::CoreExt::Hash do
  let(:klass) { Class.new { extend ColorTree::CoreExt::Hash } }

  describe "#duplicate_values?" do
    it "is true when the hash has duplicate values" do
      h = { a: 1, b: 1 }
      expect(klass.duplicate_values? h).to be true
    end

    it "is false when the hash has no duplicate values" do
      h = { a: 1, b: 2 }
      expect(klass.duplicate_values? h).to be false
    end
  end
end
