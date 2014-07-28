
public class OutputList : GtkClutter.Embed {
    const int PADDING = 48;

    public signal void show_settings (Gnome.RROutputInfo output, Gdk.Rectangle position);

    public OutputList () {
        size_allocate.connect (reposition);
    }

    public void add_output (Gnome.RROutputInfo output) {
        var monitor = new Monitor (output);
        monitor.show_settings.connect ((output, rect) => {
            Gtk.Allocation alloc;
            get_allocation (out alloc);

            show_settings (output, rect);
        });
        get_stage ().add_child (monitor);

        reposition ();
    }

    public void reposition () {
        var left = int.MAX;
        var right = 0;
        var top = int.MAX;
        var bottom = 0;

        // TODO respect rotation

        int x, y, width, height;

        foreach (var child in get_stage ().get_children ()) {
            unowned Monitor monitor = (Monitor) child;

            monitor.output.get_geometry (out x, out y, out width, out height);

            if (x < left)
                left = x;
            if (y < top)
                top = y;
            if (x + width > right)
                right = x + width;
            if (y + height > bottom)
                bottom = y + height;
        }

        var layout_width = right - left;
        var layout_height = bottom - top;
        var container_width = get_allocated_width ();
        var container_height = get_allocated_height ();
        var inner_width = container_width - PADDING * 2;
        var inner_height = container_height - PADDING * 2;

        var scale_factor = (float) inner_height / layout_height;

        if (layout_width * scale_factor > inner_width)
            scale_factor = (float) inner_width / layout_width;

        var offset_x = (container_width - layout_width * scale_factor) / 2.0f;
        var offset_y = (container_height - layout_height * scale_factor) / 2.0f;

        foreach (var child in get_stage ().get_children ()) {
            ((Monitor) child).update_position (scale_factor, offset_x, offset_y);
        }
    }

    public void remove_all () {
        get_stage ().destroy_all_children ();
    }
}