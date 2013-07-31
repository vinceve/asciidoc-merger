require 'fileutils'
require 'pry'

module AsciiDocMerger

  STANDARD_IMAGE_PATH = "assets"

  class Parser

    attr_accessor :output, :file, :image_folder, :pwd

    def initialize
      @pwd = Dir.pwd
    end

    def merge!
      parse_main_file!
      @output
    end

    private

    def parse_main_file!
      @output = parse_includes @file
    end

    def parse_includes(current_file)
      unprocessed_output = read(current_file)
      includes = find_include_paths(unprocessed_output)

      processed_output = unprocessed_output
      processed_output = parse_images! processed_output, File.dirname(current_file)

      for mapping in includes
        processed_output = process_output(processed_output, mapping)
      end
      processed_output
    end

    def process_output(unprocessed_output, file_mapping)
      sub_output = parse_includes file_mapping.file
      unprocessed_output.gsub(file_mapping.text, sub_output)
    end

    def find_include_paths(input)
      cleanup_paths input.to_enum(:scan, /include::(.*)\[(.*)\]/).map { Regexp.last_match }
    end

    def parse_images!(input, current_file_path)
      image_list = find_images input
      if image_list.any?
        copy_images image_list, current_file_path
        output = replace_image_paths image_list, input
      else
        output = input
      end
      output
    end

    def replace_image_paths(images, input)
      input
    end

    def find_images(input)
      # inline images
      binding.pry
      images = input.to_enum(:scan, /image[:]{1}(.*)\[(.*)\]/).map { Regexp.last_match }
      #image_block = input.to_enum(:scan, /image::(.*)\[(.*)\]/).map { Regexp.last_match }
      images.concat image_block
      images
    end

    def copy_images(remote_files, current_file_path)
      if !@image_folder
        @image_folder = AsciiDocMerger::STANDARD_IMAGE_PATH
      end
      FileUtils.mkdir_p(@image_folder)
      if remote_files.any?
        remote_files.each do |file|
          basename = File.basename file[1]
          Dir.chdir(File.dirname(@file)) do
            require 'pry'
            binding.pry
            FileUtils.cp( File.join(current_file_path, file[1]), File.join(@pwd, @image_folder, basename))
          end
        end
      end
    end

    def cleanup_paths(includes)
      paths = []
      for match in includes
        paths.push PathMapping.new(match[0], match[1])
      end
      paths
    end

    def read(relative_file_path)
      Dir.chdir(File.dirname(@file)) do
        File.read(File.expand_path(relative_file_path))
      end
    end

  end

end