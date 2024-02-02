/*
* Copyright (c) 2023 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Display.NightLightView : Gtk.Grid {
    private Gtk.Scale temp_scale;

    public int temperature {
        set {
            temp_scale.set_value (value);
        }
    }

    construct {
        var settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");

        var status_switch = new He.SwitchBar () {
            hexpand = true,
            title = _("Night Light"),
            subtitle = _("Use warm colors on your display to aid in sleep")
        };

        var schedule_button_a = new Gtk.ToggleButton () {
            label = (_("Manual"))
        };
        var schedule_button_b = new Gtk.ToggleButton () {
            label = (_("Automatic")),
            group = schedule_button_a
        };
        var schedule_button_c = new Gtk.ToggleButton () {
            label = (_("Sunset to Sunrise")),
            group = schedule_button_a
        };
        var schedule_button = new He.SegmentedButton () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_bottom = 6
        };
        schedule_button.append (schedule_button_b);
        schedule_button.append (schedule_button_c);
        schedule_button.append (schedule_button_a);

        var from_time = new He.TimePicker ();
        from_time.time = double_date_time (settings.get_double ("night-light-schedule-from"));

        var to_time = new He.TimePicker ();
        to_time.time = double_date_time (settings.get_double ("night-light-schedule-to"));

        var schedule_main_box = new Gtk.Grid () {
            row_spacing = 6
        };
        schedule_main_box.attach (schedule_button, 0, 0, 1, 1);
        schedule_main_box.attach (from_time, 0, 1, 1, 1);
        schedule_main_box.attach (to_time, 0, 2, 1, 1);

        var schedule_box = new He.MiniContentBlock ();
        schedule_box.title = _("Schedule");
        schedule_main_box.set_parent (schedule_box);

        temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 3500, 6000, 10);
        temp_scale.draw_value = false;
        temp_scale.has_origin = false;
        temp_scale.inverted = true;
        temp_scale.hexpand = true;
        temp_scale.add_mark (3500, Gtk.PositionType.BOTTOM, _("High"));
        temp_scale.add_mark (4500, Gtk.PositionType.BOTTOM, null);
        temp_scale.add_mark (6000, Gtk.PositionType.BOTTOM, _("Low"));
        temp_scale.get_style_context ().add_class ("warmth");
        temp_scale.set_value (settings.get_uint ("night-light-temperature"));

        var temp_box = new He.MiniContentBlock ();
        temp_box.title = _("Intensity");
        temp_scale.set_parent (temp_box);

        var content_grid = new Gtk.Grid ();
        content_grid.column_homogeneous = true;
        content_grid.attach (temp_box, 0, 2, 1, 1);
        content_grid.attach (schedule_box, 0, 0, 1, 1);

        hexpand = true;
        attach (status_switch, 0, 0, 1, 1);
        attach (content_grid, 0, 2, 2, 1);
        show ();

        settings.bind ("night-light-enabled", status_switch.main_switch.iswitch, "active", GLib.SettingsBindFlags.DEFAULT);
        settings.bind ("night-light-enabled", content_grid, "sensitive", GLib.SettingsBindFlags.GET);
        settings.bind ("night-light-temperature", this, "temperature", GLib.SettingsBindFlags.GET);

        var automatic_schedule = settings.get_boolean ("night-light-schedule-automatic");
        if (automatic_schedule) {
            schedule_button_b.active = true;
            schedule_button_a.active = false;
            from_time.sensitive = false;
            to_time.sensitive = false;
        } else {
            schedule_button_a.active = true;
            schedule_button_b.active = false;
            from_time.sensitive = true;
            to_time.sensitive = true;
        }

        schedule_button_a.toggled.connect (() => {
            settings.set_boolean ("night-light-schedule-automatic", false);
            from_time.sensitive = true;
            to_time.sensitive = true;
            clear_snooze ();
        });
        schedule_button_b.toggled.connect (() => {
            settings.set_boolean ("night-light-schedule-automatic", true);
            from_time.sensitive = false;
            to_time.sensitive = false;
        });
        schedule_button_c.toggled.connect (() => {
            settings.set_boolean ("night-light-schedule-automatic", false);
            settings.set_double ("night-light-schedule-from", 16.0f);
            settings.set_double ("night-light-schedule-to", 8.0f);
            from_time.sensitive = false;
            to_time.sensitive = false;
        });

        temp_scale.value_changed.connect (() => {
            settings.set_uint ("night-light-temperature", (uint) temp_scale.get_value ());
            clear_snooze ();
        });

        from_time.time_changed.connect (() => {
            settings.set_double ("night-light-schedule-from", date_time_double (from_time.time));
            clear_snooze ();
        });

        to_time.time_changed.connect (() => {
            settings.set_double ("night-light-schedule-to", date_time_double (to_time.time));
            clear_snooze ();
        });

        status_switch.main_switch.iswitch.notify["active"].connect (() => {
            if (status_switch.main_switch.iswitch.active) {
                clear_snooze ();
            }
        });
    }

    private void clear_snooze () {
        NightLightManager.get_instance ().snoozed = false;
    }

    private static double date_time_double (DateTime date_time) {
        double time_double = 0;
        time_double += (double) date_time.get_hour ();
        time_double += (double) date_time.get_minute () / 60;

        return Math.fmod (time_double, 24.0);
    }

    private static DateTime double_date_time (double dbl) {
        var hours = (int) dbl;
        var minutes = (int) Math.round ((dbl - hours) * 60);

        var date_time = new DateTime.local (1, 1, 1, hours, minutes, 0.0);

        return date_time;
    }
}
