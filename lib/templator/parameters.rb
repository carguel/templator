require 'rubygems'
require 'sourcify'

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

      files = get_candidate_files paths

      code = concatenate_content_of files

      parameters = Parameters.new
      parameters.load(code)
      return parameters
    end

    # Retrieves the value of a variable
    # defined in the parameter files previously loaded
    # @param [String, Symbol] var the fully qualified name of the variable (in dot notation)
    def get(var)
      @context.get_var(var)
    end


    # Loads code in a fresh context
    # @param [String ] code code to load
    def load(code)
      @context = Context.new
      @context.eval_code(code)
    end

    private 

    # Identifies all candidate files from the given array of paths.
    # A path may match a file or a directory. 
    # The method considers as candidates :
    #  * all paths that match a regular file
    #  * all files at the root of a directory when the path match a directory
    # @param [Array<String>] paths list of paths
    # @return [Array<String>] array of candidate files.
    def self.get_candidate_files(paths)
      candidates = []
      paths.each do |path|
        if File.directory?(path)
          candidates << get_files_from_directory(path)
        else
          candidates << path
        end
      end
    end

    # Lists files at the root of the given directory path
    # @param [String] directory path of the directory to process
    # @return [Array<String>] array of files included at the top level of the directory
    def self.get_files_from_directory(directory)
      Dir["#{directory}/*"].find do |file|
        File.file? file
      end
    end

    # Concatenates the content of the given files.
    # @param [Array<String>] files array of files to process
    # @return [String] the content concatenated of all given files
    def self.concatenate_content_of(files)
      files.inject("") {|content, file| content += File.read(file) + "\n"}
    end
  end

  # A Context instance defines the context in which code 
  # from parameter file is loaded
  class Context

    # Initialize a context
    def initialize
      @bindings = {}
      @current_group = "."
    end

    # Evaluates the given code with regards to the context of the current instance
    # @param [String] code the code to evaluate
    def eval_code(code)
      code_string = nil

      if code.respond_to? :to_proc
        code_string = proc_to_code_string code.to_proc
      else
        code_string = string_to_code_string code.to_s
      end

      @bindings[@current_group] = instance_eval code_string
    end

    # Retrieves the value of a variable previously evaluated
    # by {#eval_code}.
    # The fully qualified name of variable defined in a group block
    # is of the form:
    #  <group_name>.<var_name>
    # @param [#to_s] fq_var fully qualified name of the variable
    # @return [Object] the value associated to the variable
    def get_var(fq_var)
      (group, var) = group_and_var(fq_var.to_s)
      @bindings[group].eval(var)
    end

    def method_missing(method, *args)
      get_var(method)
    end

    private 

    # Defines a group block.
    # This method is suited to be called from the code evaluated 
    # by {#eval_code}.
    # @param [String] group_name name of the group
    # @param [Proc] block block associated to the group.
    def group(group_name, &block)
      enter_group group_name
      eval_code block
      exit_group group_name
      return nil
    end

    # Helper method called each time a group block is entered.
    # It appends to the current group hierarchy, the given group name.
    # @param [String] group_name name of the entered group 
    def enter_group(group_name)
      @current_group += "." unless @current_group.end_with? "."
      @current_group += group_name
    end

    # Helper method called each time a group block is exited.
    # It removes the given group name at the en of the current group hierarchy.
    # @param [String] group_name name of the exited group
    def exit_group(group_name)
      @current_group.sub!(/\.#{group_name}\z/, "")
      @current_group = "." if @current_group.empty?
    end

    def proc_to_code_string(code_proc)
      code_proc.to_source.sub(/\}\z/, "; binding}.call")
    end

    def string_to_code_string(code)
      <<-END_OF_CODE
      #{code}
      binding
      END_OF_CODE
    end

    def group_and_var(fq_var)
      matcher = fq_var.match(/\.?([^\.]+)\z/)
      ["." + matcher.pre_match, matcher[1]]
    end
  end
end
