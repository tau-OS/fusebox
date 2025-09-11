/*-
 * Copyright (c) 2023 Fyra Labs
 * Copyright (c) 2014-2018 elementary LLC.
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

public class Display.DisplaysOverlay : He.Bin {
    private const int SNAP_LIMIT = int.MAX - 1;
    private const int MINIMUM_WIDGET_OFFSET = 50;

    public signal void configuration_changed (bool changed);

    private bool scanning = false;
    private double current_ratio = 1.0f;
    private int current_allocated_width = 0;
    private int current_allocated_height = 0;
    private int default_x_margin = 0;
    private int default_y_margin = 0;

    private unowned Display.MonitorManager monitor_manager;
    public int active_displays { get; set; default = 0; }

    private Gtk.Box overlay;

    public DisplaysOverlay () {
        overlay = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        overlay.notify["get-child-position"].connect (() => get_child_position);

        var sw = new Gtk.ScrolledWindow () {
            max_content_height = 360,
            min_content_height = 360,
            vscrollbar_policy = Gtk.PolicyType.NEVER,
            valign = Gtk.Align.CENTER
        };
        sw.set_child (overlay);

        this.child = (sw);
        hexpand = true;
        vexpand = true;

        monitor_manager = Display.MonitorManager.get_default ();
        monitor_manager.notify["virtual-monitor-number"].connect (() => rescan_displays ());
        rescan_displays ();
    }

    private bool get_child_position (Gtk.Widget widget, out Gdk.Rectangle allocation) {
        allocation = Gdk.Rectangle ();
        if (current_allocated_width != get_allocated_width () || current_allocated_height != get_allocated_height ()) {
            calculate_ratio ();
        }

        if (widget is DisplayWidget) {
            var display_widget = (DisplayWidget) widget;

            int x, y, width, height;
            display_widget.get_geometry (out x, out y, out width, out height);
            x += display_widget.delta_x;
            y += display_widget.delta_y;
            var x_start = (int) Math.round (x * current_ratio);
            var y_start = (int) Math.round (y * current_ratio);
            var x_end = (int) Math.round ((x + width) * current_ratio);
            var y_end = (int) Math.round ((y + height) * current_ratio);
            allocation.x = default_x_margin + x_start;
            allocation.y = default_y_margin + y_start;
            allocation.width = x_end - x_start;
            allocation.height = y_end - y_start;

            return true;
        }

        return false;
    }

    public void rescan_displays () {
        scanning = true;

        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (child is DisplayWidget) {
                child.dispose ();
            }
        }

        active_displays = 0;
        foreach (var virtual_monitor in monitor_manager.virtual_monitors) {
            active_displays += virtual_monitor.is_active ? 1 : 0;
            add_output (virtual_monitor);
        }

        change_active_displays_sensitivity ();
        calculate_ratio ();
        scanning = false;
    }

    private void change_active_displays_sensitivity () {
        var first_child = overlay.get_first_child ();
        if (first_child != null && first_child is DisplayWidget) {
            var display_widget = (DisplayWidget) first_child;
            if (display_widget.virtual_monitor.is_active) {
                display_widget.only_display = (active_displays == 1);
            }
        }
    }

    private void check_configuration_changed () {
        // TODO check if it actually has changed
        configuration_changed (true);
    }

    private void calculate_ratio () {
        int added_width = 0;
        int added_height = 0;
        int max_width = int.MIN;
        int max_height = int.MIN;

        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            var display_widget = (DisplayWidget) child;
            int x, y, width, height;
            display_widget.get_geometry (out x, out y, out width, out height);

            added_width += width;
            added_height += height;
            max_width = int.max (max_width, x + width);
            max_height = int.max (max_height, y + height);
        }

        current_allocated_width = get_allocated_width ();
        current_allocated_height = get_allocated_height ();
        current_ratio = double.min (
                                    (double) (get_allocated_width () - 24) / (double) added_width,
                                    (double) (get_allocated_height () - 24) / (double) added_height
        );
        default_x_margin = (int) ((get_allocated_width () - max_width * current_ratio) / 2);
        default_y_margin = (int) ((get_allocated_height () - max_height * current_ratio) / 2);
    }

    private void add_output (Display.VirtualMonitor virtual_monitor) {
        var display_widget = new DisplayWidget (virtual_monitor);
        current_allocated_width = 0;
        current_allocated_height = 0;
        overlay.append (display_widget);

        display_widget.add_css_class ("colored");

        display_widget.set_as_primary.connect (() => set_as_primary (display_widget.virtual_monitor));

        display_widget.check_position.connect (() => {
            check_intersects (display_widget);
            close_gaps ();
            verify_global_positions ();
            calculate_ratio ();
        });

        display_widget.move_display.connect (move_display);
        display_widget.configuration_changed.connect (check_configuration_changed);
        display_widget.active_changed.connect (() => {
            active_displays += virtual_monitor.is_active ? 1 : -1;
            change_active_displays_sensitivity ();
            check_configuration_changed ();
            calculate_ratio ();
        });

        display_widget.end_grab.connect ((delta_x, delta_y) => {
            if (delta_x == 0 && delta_y == 0) {
                return;
            }

            int x, y, width, height;
            display_widget.get_geometry (out x, out y, out width, out height);
            display_widget.set_geometry (delta_x + x, delta_y + y, width, height);
            display_widget.queue_resize ();
            check_configuration_changed ();
            check_intersects (display_widget);
            snap_edges (display_widget);
            close_gaps ();
            verify_global_positions ();
            calculate_ratio ();
        });

        check_intersects (display_widget);
        var old_delta_x = display_widget.delta_x;
        var old_delta_y = display_widget.delta_y;
        display_widget.delta_x = 0;
        display_widget.delta_y = 0;
        display_widget.end_grab (old_delta_x, old_delta_y);
    }

    private void set_as_primary (Display.VirtualMonitor new_primary) {
        var first_child = overlay.get_first_child ();
        if (first_child == null || !(first_child is DisplayWidget)) {
            return;
        }

        var display_widget = (DisplayWidget) first_child;
        var virtual_monitor = display_widget.virtual_monitor;
        var is_primary = virtual_monitor == new_primary;
        display_widget.set_primary (is_primary);
        virtual_monitor.primary = is_primary;

        foreach (var vm in monitor_manager.virtual_monitors) {
            vm.primary = vm == new_primary;
        }

        check_configuration_changed ();
    }

    private void move_display (DisplayWidget display_widget, double diff_x, double diff_y) {
        display_widget.delta_x = (int) (diff_x / current_ratio);
        display_widget.delta_y = (int) (diff_y / current_ratio);
        align_edges (display_widget);

        display_widget.queue_resize ();
    }

    private void align_edges (DisplayWidget display_widget) {
        int aligned_delta[2] = { int.MAX, int.MAX };
        int current_delta[2] = { display_widget.delta_x, display_widget.delta_y };

        int x, y, width, height;
        display_widget.get_geometry (out x, out y, out width, out height);

        int widget_points[6], anchor_points[6];
        widget_points[0] = x; // x_start
        widget_points[1] = x + width / 2 - 1; // x_center
        widget_points[2] = x + width - 1; // x_end
        widget_points[3] = y; // y_start
        widget_points[4] = y + height / 2 - 1; // y_center
        widget_points[5] = y + height - 1; // y_end

        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (!(child is DisplayWidget) || (DisplayWidget) child == display_widget) {
                continue;
            }

            var anchor = (DisplayWidget) child;
            anchor.get_geometry (out x, out y, out width, out height);
            anchor_points[0] = x; // x_start
            anchor_points[1] = x + width / 2 - 1; // x_center
            anchor_points[2] = x + width - 1; // x_end
            anchor_points[3] = y; // y_start
            anchor_points[4] = y + height / 2 - 1; // y_center
            anchor_points[5] = y + height - 1; // y_end

            int threshold = int.min (width, height) / 10;
            for (var u = 0; u < 2; u++) { // 0: X, 1: Y
                for (var i = 0; i < 3; i++) {
                    for (var j = 0; j < 3; j++) {
                        int test_delta = anchor_points[i + 3 * u] - widget_points[j + 3 * u];
                        if (threshold > (test_delta - current_delta[u]).abs ()) {
                            if (test_delta.abs () < aligned_delta[u].abs ()) {
                                aligned_delta[u] = test_delta;
                                if (i == 0 && j != i) {
                                    aligned_delta[u] -= 1;
                                } else if (j == 0 && i != j) {
                                    aligned_delta[u] += 1;
                                }
                            }
                        }
                    }
                }
            }
        }

        if (aligned_delta[0] != int.MAX) {
            display_widget.delta_x = aligned_delta[0];
        }
        if (aligned_delta[1] != int.MAX) {
            display_widget.delta_y = aligned_delta[1];
        }
    }

    private void close_gaps () {
        var display_widgets = new List<DisplayWidget> ();
        var first_child = overlay.get_first_child ();
        if (first_child != null && first_child is DisplayWidget) {
            display_widgets.append ((DisplayWidget) first_child);
        }

        foreach (var display_widget in display_widgets) {
            if (!is_connected (display_widget, display_widgets)) {
                snap_edges (display_widget);
            }
        }
    }

    private bool is_connected (DisplayWidget display_widget, List<DisplayWidget> other_display_widgets) {
        int x, y, width, height;
        display_widget.get_geometry (out x, out y, out width, out height);
        Gdk.Rectangle rect = { x - 1, y - 1, width + 2, height + 2 };

        foreach (var other_display_widget in other_display_widgets) {
            if (other_display_widget == display_widget) {
                continue;
            }

            int other_x, other_y, other_width, other_height;
            other_display_widget.get_geometry (out other_x, out other_y, out other_width, out other_height);

            Gdk.Rectangle other_rect = { other_x, other_y, other_width, other_height };
            Gdk.Rectangle intersection;
            var is_connected = rect.intersect (other_rect, out intersection);
            var is_diagonal = intersection.height == 1 && intersection.width == 1;
            if (is_connected && !is_diagonal) {
                return true;
            }
        }

        return false;
    }

    private void verify_global_positions () {
        int min_x = int.MAX;
        int min_y = int.MAX;
        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (child is DisplayWidget) {
                var display_widget = (DisplayWidget) child;
                int x, y, width, height;
                display_widget.get_geometry (out x, out y, out width, out height);
                min_x = int.min (min_x, x);
                min_y = int.min (min_y, y);
            }
        }
        ;

        if (min_x == 0 && min_y == 0) {
            return;
        }

        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (child is DisplayWidget) {
                var display_widget = (DisplayWidget) child;
                int x, y, width, height;
                display_widget.get_geometry (out x, out y, out width, out height);
                display_widget.set_geometry (x - min_x, y - min_y, width, height);
            }
        }
        ;
    }

    // If widget is intersects with any other widgets -> move other widgets to fix intersection
    public void check_intersects (DisplayWidget source_display_widget, int level = 0, int distance_x = 0, int distance_y = 0) {
        if (level > 10) {
            warning ("Maximum level of recursion reached! Could not fix intersects!");
            return;
        }

        int source_x, source_y, source_width, source_height;
        source_display_widget.get_geometry (out source_x, out source_y, out source_width, out source_height);
        Gdk.Rectangle src_rect = { source_x, source_y, source_width, source_height };

        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (!(child is DisplayWidget) || (DisplayWidget) child == source_display_widget) {
                continue;
            }

            var other_display_widget = (DisplayWidget) child;
            int other_x, other_y, other_width, other_height;
            other_display_widget.get_geometry (out other_x, out other_y, out other_width, out other_height);
            Gdk.Rectangle test_rect = { other_x, other_y, other_width, other_height };
            if (src_rect.intersect (test_rect, null)) {
                if (level == 0) {
                    var distance_left = source_x - other_x - other_width;
                    var distance_right = source_x - other_x + source_width;
                    var distance_top = source_y - other_y - other_height;
                    var distance_bottom = source_y - other_y + source_height;
                    var test_distance_x = distance_right < -distance_left ? distance_right : distance_left;
                    var test_distance_y = distance_bottom < -distance_top ? distance_bottom : distance_top;

                    // if distance to upper egde == distance lower edge, move horizontally
                    if (test_distance_x.abs () <= test_distance_y.abs () || distance_top == -distance_bottom) {
                        distance_x = test_distance_x;
                    } else {
                        distance_y = test_distance_y;
                    }
                }

                other_display_widget.set_geometry (other_x + distance_x, other_y + distance_y, other_width, other_height);
                other_display_widget.queue_resize ();
                check_intersects (other_display_widget, level + 1, distance_x, distance_y);
            }
        }
    }

    public void snap_edges (DisplayWidget last_moved) {
        if (scanning)return;
        // Snap last_moved
        debug ("Snapping displays");
        var anchors = new List<DisplayWidget> ();
        Gtk.Widget child;
        for (child = overlay.get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (!(child is DisplayWidget) || last_moved.equals ((DisplayWidget) child))return;
            anchors.append ((DisplayWidget) child);
        }
        ;

        snap_widget (last_moved, anchors);
    }

    private void snap_widget (Display.DisplayWidget widget, List<Display.DisplayWidget> anchors) {
        if (anchors.length () == 0) {
            return;
        }

        int widget_x, widget_y, widget_width, widget_height;
        widget.get_geometry (out widget_x, out widget_y, out widget_width, out widget_height);
        widget_x += widget.delta_x;
        widget_y += widget.delta_y;

        int shortest_distance = int.MAX, shortest_distance_x = 0, shortest_distance_y = 0;
        foreach (var anchor in anchors) {
            int anchor_x, anchor_y, anchor_width, anchor_height;
            anchor.get_geometry (out anchor_x, out anchor_y, out anchor_width, out anchor_height);

            var distance_origin_x = anchor_x - widget_x;
            var distance_origin_y = anchor_y - widget_y;
            var distance_left = distance_origin_x + anchor_width;
            var distance_right = distance_origin_x - widget_width;
            var distance_top = distance_origin_y + anchor_height;
            var distance_bottom = distance_origin_y - widget_height;
            var distance_widget_anchor_x = distance_right > -distance_left ? distance_right : distance_left;
            var distance_widget_anchor_y = distance_bottom > -distance_top ? distance_bottom : distance_top;

            // widget is between left and right edges of anchor, no horizontal movement needed
            if (distance_left > 0 && distance_right < 0) {
                distance_widget_anchor_x = 0;
                // widget is between top and bottom edges of anchor, no vertical movement needed
            } else if (distance_top > 0 && distance_bottom < 0) {
                distance_widget_anchor_y = 0;
                // widget is diagonal to anchor, as diagonal monitors are not allowed, offset by 50px (MINIMUM_WIDGET_OFFSET)
            } else {
                if (distance_widget_anchor_x.abs () >= distance_widget_anchor_y.abs ()) {
                    distance_widget_anchor_x += (distance_origin_x > 0 ? 1 : -1) * MINIMUM_WIDGET_OFFSET;
                } else {
                    distance_widget_anchor_y += (distance_origin_y > 0 ? 1 : -1) * MINIMUM_WIDGET_OFFSET;
                }
            }

            var shortest_distance_candidate = distance_widget_anchor_x * distance_widget_anchor_x
                + distance_widget_anchor_y * distance_widget_anchor_y;
            if (shortest_distance_candidate < shortest_distance) {
                shortest_distance = shortest_distance_candidate;
                shortest_distance_x = distance_widget_anchor_x;
                shortest_distance_y = distance_widget_anchor_y;
            }
        }

        widget.set_geometry (widget_x + shortest_distance_x, widget_y + shortest_distance_y, widget_width, widget_height);
    }
}
