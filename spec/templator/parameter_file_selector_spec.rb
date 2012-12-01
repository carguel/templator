require 'templator/parameter_file_selector'
require 'spec_helper'


module Templator

  describe "ParameterFileSelector" do

    describe "#select_parameter_files" do

      it "should select the given file" do

        path = File.join(parameter_dir_path, 'parameter1')

        file = ParameterFileSelector.select_parameter_files(path)
  
        file.should == [path]


      end

      it "should load the code from all the files inside the given directory" do
        files = ParameterFileSelector.select_parameter_files(parameter_dir_path)
        files.sort.should == Dir["#{parameter_dir_path}/*"].sort
      end
    end

  end
end
