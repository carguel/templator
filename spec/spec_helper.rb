
def parameter_dir_path
  File.join(File.dirname(__FILE__), 'data', 'parameter_dir') 
end

def parameter_file_content(*paths)
  content = paths.sort.inject("") { |c, path| c+= File.read(path)}
end


