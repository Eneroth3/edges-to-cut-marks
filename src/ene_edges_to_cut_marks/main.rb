module Eneroth
  module EdgesToCutMarks
    unless @loaded
      @loaded = true

      menu = UI.menu("Plugins")
      menu.add_item(EXTENSION.name) { loose_edges_to_cutmarks }
    end

    # Replace loose edges with
    def self.loose_edges_to_cutmarks
      model = Sketchup.active_model
      entities = model.active_entities
      selection = model.selection

      edges = selection.grep(Sketchup::Edge)
      if edges.empty?
        UI.messagebox("Please select at least one edge and try again.")
        return
      end

      # TODO: Save value within session
      input = UI.inputbox(["Cut mark length"], [5.mm], EXTENSION.name)
      return unless input
      cut_mark_length = input[0]

      model.start_operation("Edges to Cut Marks")

      # REVIEW
      # Dive in recursively? Or only on directly selected?
      # Skip "non-flat" edges? (Those that can't be removed without losing faces)
      # Or only work on loose edges to begin with?

      new_edge_coords = []
      edges.each do |edge|
        direction = edge.line[1]

        new_edge_coords << [
          edge.start.position,
          edge.start.position.offset(direction, -cut_mark_length)
        ]
        new_edge_coords << [
          edge.end.position,
          edge.end.position.offset(direction, cut_mark_length)
        ]
      end

      entities.erase_entities(edges)
      new_edge_coords.each { |coords| entities.add_line(coords) }

      model.commit_operation
    end

    def self.our_edge?(edge)
      return true if edge.faces.size == 0 # Toss in free standing edges too
      return false unless coplanar_edge?(edge)

      edge.faces[0].material == edge.faces[1].material &&
        edge.faces[0].back_material == edge.faces[1].back_material
    end
  end
end
