require 'rubygems'
require 'templator/parameter_file_selector'
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

      files = ParameterFileSelector.select_parameter_files(*paths)

      parameters = Parameters.new
      parameters.load(files)
      return parameters
    end

    # Retrieves the value of a variable
    # defined in the parameter files previously loaded.
    # @param [#to_s] var the fully qualified name of the variable (in dot notation)
    def get(var)
      var.to_s.split('.').inject(@parameters) {|result, element| result.send(element)} 
    end

    # Loads parameters from provided files.
    # @param [Array<String>] files files to load.
    def load(files)
      @parameters = Templator::ParameterFileLoader.new.parse(*files)
    end
  end
end
