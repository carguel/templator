#!/usr/bin/env ruby

if RUBY_VERSION < "1.9"
  require "rubygems"
end

$LOAD_PATH << "../lib"
require "thor"
require "templator/parameters"
require "templator/actions"


class TemplatorCli < Thor
  include Thor::Actions
  include Templator::Actions


  # Root directory to prepend to relative paths
  source_root(Dir.pwd)

  #
  # THOR TASK gen
  # Generate a file from a template
  # 
  desc "gen TEMPLATE OUTPUT", "Generate a file from a template"
  method_option "parameter-files", 
                :aliases => "-p", 
                :type => :array, 
                :desc => "list of files and directories, that defines parameters"
  method_option "context", 
                :aliases => '-c', 
                :type => :string, 
                :desc => "context name prepended to parameter name from template (action <%=param name%>)"
  def gen(template, output)
    
    @template = template

    if options.has_key?("parameter-files")
      @parameters = Templator::Parameters.load_files *options["parameter-files"]
    end

    template template, output
  end

  
  #
  # THOR TASK get_param
  # Get the value of a parameter from provided parameter files.
  # 
  desc "get_param PARAMETER_NAME", "Get a parameter value"
  method_option "parameter-files", 
                :aliases => "-p", 
                :required => true, 
                :type => :array, 
                :desc => "list of files and directories, that defines parameters"
  method_option "context", 
                :aliases => '-c', 
                :type => :string, 
                :desc => "context name prepended to parameter name from template (action <%=param name%>)"
  def get_param(parameter_name)

      if options.has_key?("parameter-files")
        @parameters = Templator::Parameters.load_files *options["parameter-files"]
      end

      begin
        puts param(parameter_name)
      rescue
        STDERR.puts "%{parameter_name} is not defined"
        exit 1
      end

      exit 0
  end


  #
  # Internal methods
  #
  no_tasks do

    def parameters
      @parameters
    end

    def context
      @options["context"]
    end

    def search_path
      [File.expand_path(File.dirname(@template))]
    end

    def method_missing(method, *args)
      @parameters.get(method)
    end

    # Check global consistency of provided options
    def sanity_check

      #mutually exclusive options
      mandatory_and_mutually_exclusive "template-directory",  "template-file"
      optional_and_mutually_exclusive "output-directory",    "output-file"

      #dependent option
      dependent "template-file", "output-file"
      dependent "template-directory", "output-directory"
    end

    # Check that options hash has one and only one of two given keys
    def mandatory_and_mutually_exclusive(key1, key2)
      raise Thor::Error.new("One of --#{key1} or --#{key2} must be provided. Try again.") unless (options.has_key?(key1) ^ options.has_key?(key2))
    end

    # Check that options hash has zero or one of two given keys
    def optional_and_mutually_exclusive(key1, key2)
      raise Thor::Error.new("Only one of --#{key1} or --#{key2} must be provided. Try again.") unless (options.has_key(key1) || options.has_key?(key2)) || ! (options.has_key?(key1) && options.has_key?(key2))
    end

    # Check that options hash has child_key if it has parent_key.
    def dependent(parent_key, child_key)
      raise Thor::Error.new("--#{child_key} must be provided when using --#{parent_key}. Try again.") if  (options.has_key?(parent_key) && ! options.has_key?(child_key))
    end

    # Build a list of template files from provided options
    def templates
      options.has_key?("template-file") ? [options["template-file"]] : options["template-directory"]
    end

    # Build the output path based on the given option and the current template file.
    def output_path(template_file)
      options.has_key?("output-directory") ? File.join(options["output-directory"], template_file) : options["output-file"]
    end
  end
end

TemplatorCli.start
