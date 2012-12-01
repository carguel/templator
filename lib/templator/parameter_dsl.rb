module Templator

  # Parse a the given files with respect to the Parameter DSL.
  #
  # Supported DSL methods are :
  # * export(hash) : defines a list of parameters from the given hash
  # * group(name, block) : defines a group of parameter
  # * include_group(name) : include parameters and sub groups the given group into the current group
  #
  # =Example
  # With the following code :
  #  export :param1 => 'value1'
  #  export :param2 => 'value2', :param3 => 'value3'
  #  group "group1" do
  #    export :param4 => value4
  #  end
  #  group "group2" do
  #    export :param5 => group1.param4
  #    group "group3" do
  #      export :param6 => "value6"
  #    end
  #  end  
  #  group "group4" do
  #    include_group "group2.group3"
  #  end
  #
  # param5 value can retrieved with the following :
  #  p = ParameterFileLoader.new.parse("path/to/parameter_file")
  #  p.group2.param5
  #
  class ParameterFileLoader

    # Parses the given files
    # @param [String[]] files files to parse
    # @return [Object] a dynamically built object 
    #  whose methods allow to access values of parameters defined in given code.
    def parse(*files)
      files.each do |file|
        begin
          load file
        rescue ::Exception => e
          raise ParseError.new(e, file)
        end
      end
      DslContext.top_level_group
    end

  end

  # Error wrapper of all errors occuring during the parsing of a parameter file.
  # This wrapper provides convenient methods to retrieve the origin of the error.
  class ParseError < Exception
    
    attr_reader :file, :line

    def initialize(original_exception, file)
      @original_exception = original_exception
      @file = file

      process original_exception
    end


    def message_to_s
      @message.sub(/\A.*:\d+:\s*/, "")
    end

    def origin_to_s
      "in file #{file}" + (@line ? " line #{@line}" : "")
    end


    def to_s
      "ParseError #{origin_to_s}: #{message_to_s}"
    end

    private 

    def process(exception)
      @message = exception.message

      case exception
      when LoadError, ::SyntaxError
        trace = nil
      else
        trace = exception.backtrace.drop_while {|line| line.match(/#{__FILE__}/)}.first
      end

      @line = find_line_number_in_trace trace if trace
    end

    def find_line_number_in_trace(trace)
      line = nil
      matcher = trace.match(/:(\d+):/)
      line = matcher[1].to_i if matcher
    end

  end

  # Base class to define a group.
  # A Group instance is created whenever a group method is parsed from the DSL code.
  # Methods are dynamically created inside the singleton of the instance to access nested parameters and groups.
  class Group
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  # Context used by the DSL methods to retrieve and update
  # the current group.
  class DslContext
    
    # Retrieve the current group from the context
    # @return [Group] the current group
    def self.current_group
      group_stack.last
    end

    # Retrieve the top level group from the context
    # @return [Group] the top level group
    def self.top_level_group
      group_stack.first
    end

    # Enter a new group.
    # This method shall be called by the DSL methods whenever 
    # a new group is entered.
    # @param [Group] group group entered.
    def self.enter_group(group)
      group_stack.push(group)
    end

    # Leave a group.
    # This method shall be calles by the DSL methods whenever
    # a group is left.
    def self.leave_group
      group_stack.pop
    end

    private

    # Retrieve the stack of groups.
    # The stack is automatically created on the first call
    # and the top level group is inserted as the first element
    # of the stack.
    # @return [Array<Group>] the stack of groups.
    def self.group_stack
      if (@group_stack.nil?)
        @group_stack = []
        @group_stack.push Group.new(DslMethods::TOP_LEVEL_GROUP_NAME)
      end
      @group_stack
    end
  end

  # Module that defines the Parameter DSL methods.
  module DslMethods

    # Name of the implicit top level group
    TOP_LEVEL_GROUP_NAME = "__top__"

    # Defines parameters providing a name and a value for each parameter.
    # @param [Hash]params hash of parameter name and value 
    def export(params)
      params.each do |name, value| 
        define_method_in_current_group(name) {value}
      end
    end

    # Defines a group of parameters.
    # @param [#to_s] name name of the group
    # @yield group block definition
    def group(name)
      enter_group name.to_s
      yield
      leave_group
    end

    # Includes all parameters and sub groups of a given group into the current group.
    # @param [Group,#to_s] group group to include
    def include_group(group)
      source_group = group
      if ! group.kind_of? Group
        source_group = get_group group.to_s
      end
      source_group.singleton_methods.each do |method|
        define_method_in_current_group(method) {source_group.send(method)}
      end
    end

    private

    # Gets the current group from the DslContext
    def current_group
        DslContext.current_group
    end

    # Manages the entry in a new group:
    # * create a new Group instance (or retrieve it if it already exists in the current context)
    # * define a method in the current group to access the new group
    # * notify the context about the entry in a new group
    # @param [#to_s] name name of the new group
    #
    def enter_group(name)
      group = group_in_current_context(name) || Group.new(name)
      define_method_in_current_group(name) {group}
      DslContext.enter_group(group)
    end

    # Defines a method inside the current group
    # @param [#to_s] method_name name of the method to define.
    # @param [Block] method_block block of the méthode to define
    def define_method_in_current_group(method_name, &method_block)
      (class << current_group; self; end).send(:define_method, method_name, method_block)
    end

    # Verify if a group belongs to the current group
    # @param [#to_s] name name of the group to control
    # @return the group with the given name if it belongs to the current group, nil otherwise
    def group_in_current_context(name)
      current_group.respond_to?(name) ? current_group.send(name) : nil
    end

    # Manages the exit from a group
    def leave_group
      DslContext.leave_group
    end

    # Manages the access to a parameter outside of the current group
    def method_missing(name, *args)
      DslContext.top_level_group.send(name, *args)
    end

    # Get a group from its fully qualified name
    def get_group(fully_qualified_name)
      fully_qualified_name.to_s.split('.').inject(DslContext.top_level_group) {|result, name| result.send(name)}
    end

  end
end

#inject the DSL methos in the main object
extend Templator::DslMethods 
