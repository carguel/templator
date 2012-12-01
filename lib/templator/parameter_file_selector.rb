module Templator

  class ParameterFileSelector

    def self.select_parameter_files(*paths)
      files = get_candidate_files paths
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
  end
end
