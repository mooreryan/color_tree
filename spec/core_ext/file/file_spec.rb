require "spec_helper"

describe ColorTree::CoreExt::File do
  let(:klass) { Class.new { extend ColorTree::CoreExt::File } }

  let(:this_dir) { File.dirname __FILE__ }
  let(:test_files) { File.join this_dir, "..", "..", "test_files" }
  let(:good_name_map) { File.join test_files, "name_map.good.test" }


  describe "#check_file" do
    it "aborts if file is nil" do
      fname = nil
      expect{klass.check_file fname, :apple}.to raise_error SystemExit
    end

    it "aborts if file doesn't exist" do
      fname = "hehe.txt"
      expect{klass.check_file fname, :apple}.to raise_error SystemExit
    end

    it "returns fname if file exists" do
      fname = __FILE__
      expect(klass.check_file fname, :apple).to eq fname
    end
  end

  describe "#parse_name_map" do
    context "with good input" do
      it "returns a hash with clean old name => clean new name" do
        fname = File.join test_files, "name_map.good.txt"
        name_map = { "app_le" => "pie",
                     "is" => "g_o_o_d" }

        expect(klass.parse_name_map fname).to eq name_map
      end
    end

    context "with bad input" do
      context "when col 1 is empty" do
        it "raises SystemExit" do
          fname = File.join test_files, "name_map.col1_empty.txt"

          expect{klass.parse_name_map fname}.to raise_error SystemExit
        end
      end

      context "when col 2 is empty" do
        it "raises SystemExit" do
          fname = File.join test_files, "name_map.col2_empty.txt"

          expect{klass.parse_name_map fname}.to raise_error SystemExit
        end
      end

      context "when col 2 is missing" do
        it "raises SystemExit" do
          fname = File.join test_files, "name_map.col2_missing.txt"

          expect{klass.parse_name_map fname}.to raise_error SystemExit
        end
      end

      context "when col 2 has duplicate values" do
        it "raises SystemExit" do
          fname = File.join test_files, "name_map.duplicate_vals.txt"

          expect{klass.parse_name_map fname}.to raise_error SystemExit
        end
      end

      context "with line ending issues" do
        it "raises SystemExit"
      end
    end
  end
end
