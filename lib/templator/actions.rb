require 'tempfile'
require 'erb'

module Templator

  module Actions

    def param(name)
      begin
        parameters.get(name)
      rescue NoMethodError => e
        parameters.get("#{context}.#{name}")
      end
    end

    def param_exists?(name)
      begin
        param(name)
        true
      rescue
        false
      end
    end

    def include_file(filename)
      content=""
      catch(:file_found) do
        search_path.each do |dir|
          path = File.join(dir, filename)
          if File.exist?(path) 
            content = ERB.new(::File.read(path), nil, '-', 'included_template').result(binding)
            throw :file_found
          end
        end
      end
      return content
    end
  end
end
