module Templator

  class ParameterCodeLoader

    def self.load_code_from(*paths)
      files = get_candidate_files paths
      code = concatenate_content_of files
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
          candidates.concat(get_files_from_directory(path))
        else
          candidates << path
        end
      end
      return candidates
    end

    # Lists files at the root of the given directory path
    # @param [String] directory path of the directory to process
    # @return [Array<String>] array of files included at the top level of the directory
    def self.get_files_from_directory(directory)
      Dir["#{directory}/*"].sort.select do |file|
        File.file? file
      end
    end

    # Concatenates the content of the given files.
    # @param [Array<String>] files array of files to process
    # @return [String] the content concatenated of all given files
    def self.concatenate_content_of(files)
      files.inject("") do |content, file| 
        content += File.read(file) 
        content += "\n" unless content[-1, 1] == "\n"
        content
      end
    end
  end
end
