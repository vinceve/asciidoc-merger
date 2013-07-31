require File.expand_path("lib/asciidoc-merger.rb")

merger = AsciiDocMerger::Parser.new
merger.file = "/home/vince/Projects/dps_doc/sources/master/OAUTH_Howto/toc.txt"
merger.ignore_non_existing_images = true
merger.merge!

puts merger.output