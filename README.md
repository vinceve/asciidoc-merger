# AsciiDoc Merger

A simple gem to merge different asciidoc files into 1 big file. It also copies all images into a folder
along the merged file.

## How to use

1. Install the gem

```
gem install asciidoc-merger
```

2. Create a new instance and provide your main file

```
require 'asciidoc-merger'

asciidoc_parser = AsciiDocMerger::Parser.new
asciidoc_parser.file = "/home/vince/Projects/dps_doc/sources/master/OAUTH_Howto/toc.txt"
asciidoc_parser.merge!
```


### Optional parameters

* Ignore non existing images:

```
asciidoc_parser.ignore_non_existing_images = true
```

* Set the output folder

```
asciidoc_parser.output_folder = "/path/to/folder/"
```

* Set the file name of the merged file

```
asciidoc_parser.merged_file_name = "my_awesome_filename.asciidoc"
```