require 'fileutils'
require 'pathname'

module AsciiDocMerger

  STANDARD_IMAGE_PATH = "assets"
  DEFAULT_MERGED_FILE_NAME = "merged_document.asciidoc"

  class Parser

    attr_accessor :output, :file, :image_folder, :pwd, :ignore_non_existing_images, :output_folder, :merged_file_name

    def initialize
      @pwd = Dir.pwd
    end

    def merge!
      parse_main_file!
      save!
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

      output = input

      images.each do |match|
        new_string = match[0]
        basename = File.basename match[2]
        new_string = new_string.gsub(match[2], File.join(relative_assets_path, basename))

        output = output.gsub(match[0], new_string)

      end

      output
    end

    def find_images(input)
      # inline images
      images = input.to_enum(:scan, /image:(:)?(.*)\[(.*)\]/).map { Regexp.last_match }
      images
    end

    def copy_images(remote_files, current_file_path)
      if !@image_folder
        @image_folder = AsciiDocMerger::STANDARD_IMAGE_PATH
      end
      FileUtils.mkdir_p(@image_folder)
      if remote_files.any?
        remote_files.each do |file|
          basename = File.basename file[2]
          Dir.chdir(File.dirname(@file)) do
            original_file_path = File.join(current_file_path, file[2])
            destination_path = File.join(assets_path, basename)
            copy_file! original_file_path, destination_path, current_file_path
          end
        end
      end
    end

    def assets_path
      File.join(save_path, @image_folder)
    end

    def relative_assets_path
      Pathname.new(assets_path).relative_path_from(Pathname.new(save_path)).to_s
    end

    def save_path
      if @output_folder
        @output_folder
      else
        @pwd
      end
    end

    def copy_file!(source, destination, current_file_path)
      basename = File.basename source
      if File.exists? source
        FileUtils.cp( source, destination)
      else
        if !@ignore_non_existing_images
          raise IOError, "Could not find file: #{basename} in file: #{current_file_path}"
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

    def get_file_name
      if @merged_file_name
        @merged_file_name
      else
        DEFAULT_MERGED_FILE_NAME
      end
    end

    def save!
      file = File.join(save_path, get_file_name)
      merged_document = File.open( file, 'w' )
      merged_document << @output
      merged_document.close
    end

  end

end