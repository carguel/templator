require 'templator/parameter_dsl'

module Templator

  describe ParameterFileLoader do

    after(:all) do
      File.delete("test")
      File.delete("test1")
      File.delete("test2")
    end

    subject {ParameterFileLoader.new}

    describe "#parse" do

      context "when the DSL defines a parameter" do

        it "should return an object that allows to access the parameter value in a natural way" do

          in_file "test", <<-CODE
          export :var1 => "value1"
          CODE

          group = subject.parse("test")

          group.var1.should == "value1"
        end
      end

      context "when the DSL defines a group and a parameter inside this group" do

        it "should return an object that allows to access the parameter value in a natural way" do

          in_file("test", <<-CODE)
          group "group1" do
            export :var2 => "value2"
          end
          CODE

          group = subject.parse("test")

          group.group1.var2.should == "value2"
        end
      end

      context "when the DSL defines a parameter for which the value is a parameter from another group" do

        it "should return an object that allows to access the parameter value in a natural way" do
          in_file("test", <<-CODE)
          group "group3" do
            export :var3 => "value3"
          end

          group "group4" do
            export :var4 => group3.var3
          end
          CODE


          group = subject.parse("test")

          group.group4.var4.should == group.group3.var3
        end
      end

      context "when the DSL ask to mix a group into the current group" do

        let (:code) { 
          <<-CODE
          group "source" do
            group "subgroup" do
              export :var_in_subgroup => "value_in_subgroup"
            end
            export :var_in_group => "value_in_group"
          end
          CODE
        }

        context "and the group to include is given as a String" do

          it "should include in the current group all parameters and sub groups defined in the source group" do

            in_file("test", code + <<-CODE)
            group :target do 
              include_group "source"
            end
            CODE

            group = subject.parse("test")

            group.target.subgroup.var_in_subgroup.should == "value_in_subgroup"
            group.target.var_in_group.should == "value_in_group"

          end
        end

        context "and the group to include is given as a Group" do

          it "should include in the current group all parameters and sub groups defined in the source group" do
            in_file("test", code + <<-CODE)
            group :target do 
              include_group source
            end
            CODE

            group = subject.parse("test")

            group.target.subgroup.var_in_subgroup.should == "value_in_subgroup"
            group.target.var_in_group.should == "value_in_group"
          end
        end
      end

      context "when a group is defined twice" do

        it "should merge the definition of each group into a single one" do
          in_file("test", <<-CODE)
          group :group1 do
            export :var1 => "value1"
          end

          group :group1 do
            export :var2 => "value2"
          end
          CODE

          group = subject.parse("test")

          group.group1.var1.should == "value1"
          group.group1.var2.should == "value2"
        end
      end

      context "when parameters are defined in several files" do

        it "should correctly load all parameters" do

          in_file("test1", <<-CODE)
          group :group1 do
            export :var1 => "value1"
          end
          CODE

          in_file("test2", <<-CODE)
          group :group1 do
            export :var2 => "value2"
          end
          CODE

          group = subject.parse("test1", "test2")
          group.group1.var1.should == "value1"
          group.group1.var2.should == "value2"
        end
      end

      context "when parameter file contains syntax error" do
        it "should display a clear error message" do
          in_file("test1", <<-CODE)
          groupe :wrong_syntax do
            export :var1 => "value1"
          end
          CODE

          expect {group = subject.parse("test1")}.to raise_error {|error|
            error.should be_a(ParseError)
            error.line.should == 1
            error.file.should == "test1"
          }
        end
      end
    end
  end
end
