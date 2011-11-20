require 'tempfile'
require 'erb'

module Templator

  module Actions

    def param(varname)
      begin
        parameters.get(varname)
      rescue NoMethodError => e
        parameters.get("#{context}.#{varname}")
      end
    end

    def include_file(filename)
      content=""
      catch(:file_found) do
        search_path.each do |dir|
          path = File.join(dir, filename)
          if File.exist?(path) 
            content = ERB.new(::File.read(path), nil, '-', '@included_template').result(binding)
            throw :file_found
          end
        end
      end
      return content
    end
  end
end
