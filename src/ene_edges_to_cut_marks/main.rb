module Eneroth
  module EdgesToCutMarks
    unless @loaded
      @loaded = true

      menu = UI.menu("Plugins")
      menu.add_item(EXTENSION.name) { loose_edges_to_cutmarks }
    end

    # Replace edges with cut marks
    def self.loose_edges_to_cutmarks
      model = Sketchup.active_model
      entities = model.active_entities
      selection = model.selection

      edges = selection.grep(Sketchup::Edge)
      if edges.empty?
        UI.messagebox("Please select at least one edge and try again.")
        return
      end

      @cut_mark_length ||= metric? ? 5.mm : 0.25.inch
      input = UI.inputbox(["Cut mark length"], [@cut_mark_length], EXTENSION.name)
      return unless input
      @cut_mark_length = input[0]

      model.start_operation("Edges to Cut Marks")

      new_edge_coords = []
      edges.each do |edge|
        direction = edge.line[1]

        new_edge_coords << [
          edge.start.position,
          edge.start.position.offset(direction, -@cut_mark_length)
        ]
        new_edge_coords << [
          edge.end.position,
          edge.end.position.offset(direction, @cut_mark_length)
        ]
      end

      entities.erase_entities(edges)
      new_edge_coords.each { |coords| entities.add_line(coords) }

      model.commit_operation
    end

    def self.metric?
      unit_options = Sketchup.active_model.options["UnitsOptions"]
      return false unless unit_options["LengthFormat"] == Length::Decimal

      [Length::Millimeter, Length::Centimeter, Length::Meter].include?(unit_options["LengthUnit"])
    end
  end
end
