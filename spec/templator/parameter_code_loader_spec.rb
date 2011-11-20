require 'templator/parameter_code_loader'
require 'spec_helper'


module Templator

  describe "ParameterCodeLoader" do

    describe "#parameter_loader" do

      it "should load the code from the given file" do

        path = File.join(parameter_dir_path, 'parameter1')

        code = ParameterCodeLoader.load_code_from(path)
  
        code.should == parameter_file_content(path)


      end

      it "should load the code from all the files inside the given directory" do
        code = ParameterCodeLoader.load_code_from(parameter_dir_path)
        code.should == parameter_file_content(*Dir["#{parameter_dir_path}/*"])
      end
    end

  end
end
