require 'templator/parameter_dsl'

module Templator

  describe ParameterDsl do

    describe "#parse" do

      context "when the DSL defines a parameter" do

        it "should return an object that allows to access the parameter value in a natural way" do

          code =<<-CODE
          export :var1 => "value1"
          CODE

          pdsl = ParameterDsl.new
          group = pdsl.parse(code)

          group.var1.should == "value1"
        end
      end

      context "when the DSL defines a group and a parameter inside this group" do

        it "should return an object that allows to access the parameter value in a natural way" do
          code = <<-CODE
          group "group1" do
            export :var2 => "value2"
          end
          CODE

          pdsl = ParameterDsl.new
          group = pdsl.parse(code)

          group.group1.var2.should == "value2"
        end
      end

      context "when the DSL defines a parameter for which the value is a parameter from another group" do

        it "should return an object that allows to access the parameter value in a natural way" do
          code = <<-CODE
          group "group3" do
            export :var3 => "value3"
          end

          group "group4" do
            export :var4 => group3.var3
          end
          CODE


          pdsl = ParameterDsl.new
          group = pdsl.parse(code)

          group.group4.var4.should == group.group3.var3
        end
      end
    end
  end
end
