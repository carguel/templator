module Templator

  # Defines and interprets the methods of the Parameter DSL.
  # Supported DSL methods are :
  # * export(hash) : defines a list of parameters from the given hash
  # * group(name, block) : defines a group of parameter
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
  #  end  
  #
  #
  # param5 value can retrieved with the following :
  #  p = ParameterDsl.new.parse(code)
  #  p.group2.param5
  #
  #
  class ParameterDsl

    # Name of the implicit top level group
    TOP_LEVEL_GROUP_NAME = "__top__"

    def initialize
      #initialize the top level group
      @group_stack = []
      @group_stack.push Group.new(TOP_LEVEL_GROUP_NAME)
    end

    # Parses the given code
    # @param [String] code code to parse
    # @return [Object] a dynamically built object 
    #  whose methods allow to access values of parameters defined in given code.
    def parse(code)
      instance_eval code
      @group_stack.first
    end

    # Defines parameters providing a name and a value for each parameter.
    # @param [Hash]params hash of parameter name and value 
    def export(params)
      params.each do |name, value| 
        define_method_in_current_group(name) {value}
      end
    end

    # Defines a group of parameters
    # @param [#to_s] name name of the group
    # @yield group block definition
    def group(name)
      enter_group name.to_s
      yield
      leave_group
    end

    private

    # Gets the current group from the group stack
    def current_group
      @group_stack.last
    end

    # Manages the entry in a new group:
    # * create a new Group instance
    # * define a method in the current group to access this new group
    # * push the new group instance on top of the group stack 
    # @param [#to_s] name of the new group
    #
    def enter_group(name)
      group = Group.new(name)
      define_method_in_current_group(name) {group}
      @group_stack.push(group)
    end

    # Defines a method inside the current group
    # @param [#to_s] method_name name of the method to define.
    # @param [Block] method_block block of the méthode to define
    def define_method_in_current_group(method_name, &method_block)
        (class << current_group; self; end).send(:define_method, method_name, method_block)
    end

    # Manages the exit from a group
    def leave_group
      @group_stack.pop
    end

    # Manages the access to a parameter outside of the current group
    def method_missing(name, *args)
      @group_stack.first.send(name, *args)
    end

  end

  # Base class to define a group.
  # A Group instance is created whenever a group method is parsed from the DSL code.
  # Methods are dynamically created inside the singleton of the instance to access nested parameters and groups.
  class Group
    def initialize(name)
      @name = name
    end
  end
end
