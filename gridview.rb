require "gtk3"

class TileWorld < Gtk::Application
  def initialize(grid)
    @grid = grid
    surface = nil
    super "be.sourcery.tileworld", Gio::ApplicationFlags::FLAGS_NONE
    signal_connect :activate do |application|
      window = Gtk::ApplicationWindow.new(application)
      window.set_title "TileWorld"
      window.signal_connect "delete-event" do
        window.destroy
      end
      frame = Gtk::Frame.new
      frame.shadow_type = Gtk::ShadowType::IN
      window.add frame

      view = Gtk::DrawingArea.new
      view.set_size_request COLS * MAG + 250, ROWS * MAG
      frame.add(view)

      view.signal_connect "draw" do |_da, cr|
        cr.set_source(surface, 0, 0)
        cr.paint
        false
      end
      view.signal_connect "configure-event" do |da, _ev|
        surface.destroy if surface
        surface = window.window.create_similar_surface(Cairo::CONTENT_COLOR,
                                                       da.allocated_width,
                                                       da.allocated_height)
        true
      end

      GLib::Timeout.add(TIMEOUT) {
        @grid.update
        @grid.printGrid
        rect = Gdk::Rectangle.new(0, 0, view.allocation.width, view.allocation.height)
        window.window.invalidate_rect(rect, false)
        redraw(view, surface, @grid)
        true
      }
      window.show_all
    end
  end

  def redraw(view, surface, grid)
    cr = Cairo::Context.new(surface)
    cr.set_source_rgb(1, 1, 1)
    cr.paint
    cr.set_line_width(2)
    cr.rectangle(0, 0, COLS * MAG, ROWS * MAG)
    for r in 0..(ROWS - 1)
      for c in 0..(COLS - 1)
        cr.set_source_rgb(0, 0, 0)
        o = grid.object(Location.new(c, r))
        if o != nil
          x = c * MAG
          y = r * MAG
          if o.instance_of? Agent
            drawAgent(view, cr, o, x, y)
          elsif o.instance_of? Hole
            cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
            cr.fill
          elsif o.instance_of? Tile
            drawTile view, cr, o, x, y
          elsif o.instance_of? Obstacle
            cr.rectangle(x, y, MAG, MAG)
            cr.fill()
          end
        else
        end
        cr.stroke
      end
    end
    x = COLS * MAG + 50
    y = 20
    @grid.agents.each { |a|
      r, b, g = getColor(a.num)
      cr.set_source_rgb(r, g, b)
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      draw_text cr, x, y + id * MAG, text
    }
  end

  def drawAgent(view, cr, a, x, y)
    r, b, g = getColor(a.num)
    cr.set_source_rgb(r, g, b)
    cr.rectangle(x, y, MAG, MAG)
    if a.hasTile()
      cr.new_sub_path
      cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
      cr.new_sub_path
      draw_text(cr, x + MAG / 4, y + 3, a.tile.score.to_s)
    end
  end

  def drawTile(view, cr, tile, x, y)
    cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
    cr.new_sub_path
    draw_text(cr, x + MAG / 4, y + 3, tile.score.to_s)
  end

  def draw_text(cr, x, y, text)
    font = Pango::FontDescription.new
    font.set_family("Monospace")
    font.set_weight(Pango::Weight::BOLD)
    layout = cr.create_pango_layout
    layout.set_text(text)
    layout.set_font_description(font)
    cr.move_to(x, y)
    cr.show_pango_layout(layout)
  end

  def getColor(num)
    if num == 0
      return 0, 0, 255
    elsif num == 1
      return 255, 0, 0
    elsif num == 2
      return 0, 255, 0
    elsif num == 3
      return 128, 128, 0
    elsif num == 4
      return 0, 128, 128
    elsif num == 5
      return 128, 0, 128
    end
  end
end
