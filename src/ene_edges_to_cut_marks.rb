# frozen_string_literal: true

require "extensions"

# Eneroth Extensions
module Eneroth
  # Eneroth Edges to Cut Marks
  module EdgesToCutMarks
    path = __FILE__.dup
    path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

    # Identifier for this extension.
    PLUGIN_ID = File.basename(path, ".*")

    # Root directory of this extension.
    PLUGIN_ROOT = File.join(File.dirname(path), PLUGIN_ID)

    # Extension object for this extension.
    EXTENSION = SketchupExtension.new(
      "Eneroth Edges to Cut Marks",
      File.join(PLUGIN_ROOT, "main")
    )

    EXTENSION.creator     = "Eneroth"
    EXTENSION.description =
      "Replace selected edges with short stumps at their ends. "\
      "Can be used as cut marks after printing."
    EXTENSION.version     = "1.0.0"
    EXTENSION.copyright   = "2024, #{EXTENSION.creator}"
    Sketchup.register_extension(EXTENSION, true)
  end
end
