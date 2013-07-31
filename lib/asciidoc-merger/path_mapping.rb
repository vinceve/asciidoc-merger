module AsciiDocMerger

  class PathMapping
    attr_accessor :text, :file
    def initialize(text, file)
      @text = text
      @file = file
    end
  end

end