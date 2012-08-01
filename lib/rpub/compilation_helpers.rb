module Rpub
  # Provide a set of helper methods that are used across various commands to
  # simplify the compilation process. These methods mostly deal with loading files
  # from the current project directory.
  module CompilationHelpers

    def concatenated_document
      Kramdown::Document.new(
        markdown_files.join("\n"),
        KRAMDOWN_OPTIONS.merge(:template => layout)
      )
    end

    # Factory method for {Rpub::Book} objects, loading every markdown file as a
    # chapter.
    #
    # @see #markdown_files
    # @return [Rpub::Book]
    def create_book
      book = Book.new(layout, config, fonts)
      markdown_files.each(&book.method(:<<))
      book
    end

    # All chapter input files loaded into strings. This does not include any of
    # the files listed in the +ignore+ configuration key.
    #
    # @return [Array<String>]
    def markdown_files
      @markdown_files ||= filter_exceptions(Dir['*.md']).sort.map(&File.method(:read))
    end

  private

    def fonts
      @fonts ||= File.read(styles).scan(/url\((?:'|")?([^'")]+\.otf)(?:'|")?\)/i).flatten
    end

    def filter_exceptions(filenames)
      return filenames unless config.has_key?('ignore')
      filenames.reject(&config['ignore'].method(:include?))
    end
  end
end
