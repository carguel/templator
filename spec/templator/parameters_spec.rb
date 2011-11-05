require 'templator/parameters'

module Templator

  describe Parameters do


    describe "#load_files" do

      def data_path
        File.join(File.dirname(__FILE__), '/data')
      end

      def file1_path
        File.join(data_path, "file1")
      end

      def file2_path
        File.join(data_path, "file2")
      end

      def directory3_path
        File.join(data_path, "directory3")
      end

      context "parameter files that contain only simple parameter definitions" do

        it "should load the given file and return a Parameters instance" do
          path = "my/path"
          File.should_receive(:read).with(path).once.and_return("var1='value1'")

          parameters = Parameters.load_files(path)

          parameters.should be_kind_of Parameters

          parameters.get(:var1).should == 'value1'
        end

        it "should load all the given files and return a Parameters instance" do

          path1 = "my/path1"
          path2 = "my/path2"
          File.should_receive(:read).with(path1).once.and_return("var1='value1'")
          File.should_receive(:read).with(path2).once.and_return("var2='value2'")

          parameters = Parameters.load_files(path1, path2)

          parameters.should be_kind_of Parameters

          parameters.get(:var1).should == 'value1'
          parameters.get(:var2).should == 'value2'
        end
      end

      context "parameter files that contain grouped parameter definitions" do

        it "should load all the given files and return a Parameters instance" do

          path1 = "my/path1"
          path2 = "my/path2"
          File.should_receive(:read).with(path1).once.and_return("group('group1') {var1 = 'value1'}")
          File.should_receive(:read).with(path2).once.and_return("group('group2') {group('group3') {var2 = 'value2'}}")

          parameters = Parameters.load_files(path1, path2)

          parameters.should be_kind_of Parameters

          parameters.get("group1.var1").should == 'value1'
          parameters.get("group2.group3.var2").should == 'value2'

        end
      end
    end
  end
end
