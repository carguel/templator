require 'rubygems'
require 'templator/parameter_code_loader'
require 'templator/parameter_dsl'

module Templator

  class Parameters

    # Loads parameter files from given paths.
    #
    # @param [Array<String>] paths list of paths that match parameter files.
    #   Each element can match an individual file or a directory, in this case
    #   all files included at the root of this directory are assumed to be 
    #   parameter files.
    # 
    # @return [Parameters] a Parameters instance.
    #  This instance is suitable to provide a later access 
    #  to parameters defined in loaded files.
    def self.load_files(*paths)

      code = ParameterCodeLoader.load_code_from(*paths)

      parameters = Parameters.new
      parameters.load(code)
      return parameters
    end

    # Retrieves the value of a variable
    # defined in the parameter files previously loaded
    # @param [#to_s] var the fully qualified name of the variable (in dot notation)
    def get(var)
      var.to_s.split('.').inject(@parameters) {|result, element| result.send(element)} 
    end

    # Loads code in a fresh context
    # @param [String ] code code to load
    def load(code)
      @parameters = Templator::ParameterDsl.new.parse(code)
    end
  end
end
