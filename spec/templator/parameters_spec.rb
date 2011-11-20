require 'templator/parameters'
require 'spec_helper'

module Templator

  describe Parameters do


    describe "#load_files" do


      context "parameter files that contain only simple parameter definitions" do

        it "should load the given file and return a Parameters instance" do
          path = File.join(parameter_dir_path, 'parameter1')

          parameters = Parameters.load_files(path)

          parameters.should be_kind_of Parameters

          parameters.get(:parameter1).should == 'value1'
          parameters.get("group1.parameter2").should == 'value2'
        end
      end
    end
  end
end
