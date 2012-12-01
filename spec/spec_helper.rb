
def parameter_dir_path
  File.join(File.dirname(__FILE__), 'data', 'parameter_dir') 
end

def parameter_file_content(*paths)
  content = paths.sort.inject("") { |c, path| c+= File.read(path)}
end

def in_file(filename, content)
  File.open(filename, "w") do |f|
    f.puts content
  end
end

