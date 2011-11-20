require 'templator/actions'

module Templator

  describe Actions do

    # test class
    class Includer
      include Actions

      def initialize
        @context = nil
      end

      def context
        return @context
      end

      def context=(context)
        @context = context
      end

    end

    before do
      @includer = Includer.new
      @varname = "foo"
      @varvalue = "bar"
    end

    describe "#param" do

      context ", when no context is provided," do
        it "should retrieve from the #parameters instance the value of the provided parameter name" do

          parameters = mock(:parameters)

          @includer.should_receive(:parameters).once.and_return(parameters)
          parameters.should_receive(:get).with(@varname).once.and_return(@varvalue)

          @includer.param(@varname).should == @varvalue

        end
      end

      context ", when a context is defined in the includer" do

        before do
            @parameters = mock(:parameters)

            @context_name = "context"
            @includer.context = @context_name
        end

        context "and the provided parameter is defined outside of the context," do

          it "should retrieve the value of the provided parameter name from #parameters" do

            @includer.should_receive(:parameters).once.and_return(@parameters)
            @parameters.should_receive(:get).with(@varname).once.and_return(@varvalue)

            @includer.param(@varname).should == @varvalue

          end
        end

        context "and the provided variable is defined inside of the context," do
          it "should retrieve the value of the provided parameter name from #parameters" do

            @includer.should_receive(:parameters).at_least(:once).and_return(@parameters)
            @parameters.should_receive(:get).with(any_args).twice.and_return do |varname|
              case varname
              when @varname
                raise NoMethodError.new
              when "#{@context_name}.#{@varname}"
                @varvalue
              end
            end

            @includer.param(@varname).should == @varvalue
          end
        end
      end
    end

    describe "#include_file" do

      it "should include a file relative to the current template file" do

        test_file = File.expand_path('file_to_include', File.join(File.dirname(__FILE__),'../data'))

        @includer.should_receive(:search_path).once.and_return([File.dirname(test_file)])
        @includer.include_file(File.basename(test_file)).should == File.new(test_file).read
      end
    end
  end
end
