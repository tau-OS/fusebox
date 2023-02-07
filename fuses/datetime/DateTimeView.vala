[DBus (name = "org.freedesktop.timedate1")]
interface DateTime.DateTime1 : Object {
    public abstract string Timezone { public owned get; }
    public abstract bool LocalRTC { public get; }
    public abstract bool CanNTP { public get; }
    public abstract bool NTP { public get; }

    // usec_utc expects number of microseconds since 1 Jan 1970 UTC
    public abstract void set_time (int64 usec_utc, bool relative, bool user_interaction) throws GLib.Error;
    public abstract void set_timezone (string timezone, bool user_interaction) throws GLib.Error;
    public abstract void SetLocalRTC (bool local_rtc, bool fix_system, bool user_interaction) throws GLib.Error; // vala-lint=naming-convention
    public abstract void SetNTP (bool use_ntp, bool user_interaction) throws GLib.Error; // vala-lint=naming-convention
}

public class DateTime.DateTimeView : Gtk.Box {
    private static GLib.Settings timezone_settings;
    private static GLib.Settings timeformat_settings;
    private DateTime1 datetime1;
    private CurrentTimeManager ct_manager;
    private WorldLocationFinder location_finder;

    static construct {
        timezone_settings = new GLib.Settings ("org.gnome.desktop.datetime");
        timeformat_settings = new GLib.Settings ("org.gnome.desktop.interface");
    }

    construct {
        var date_time_label = new Gtk.Label (_("Automatic Date & Time")) {
            halign = Gtk.Align.START
        };
        date_time_label.add_css_class ("cb-title");
        var date_time_sublabel = new Gtk.Label (_("Requires internet")) {
            halign = Gtk.Align.START
        };
        date_time_sublabel.add_css_class ("cb-subtitle");

        var date_time_label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        date_time_label_box.append (date_time_label);
        date_time_label_box.append (date_time_sublabel);

        var date_time_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var date_time_auto_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        date_time_auto_box.append (date_time_label_box);
        date_time_auto_box.append (date_time_switch);

        var date_time_manual_label = new Gtk.Label (_("Date & Time")) {
            halign = Gtk.Align.START,
            sensitive = false
        };
        date_time_manual_label.add_css_class ("cb-title");

        var date_time_time_picker = new DateTime.TimePicker () {
            halign = Gtk.Align.END,
            hexpand = true
        };
        var date_time_date_picker = new DateTime.DatePicker ();

        var date_time_manual_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            visible = false
        };
        date_time_manual_box.append (date_time_manual_label);
        date_time_manual_box.append (date_time_time_picker);
        date_time_manual_box.append (date_time_date_picker);

        var date_time_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            visible = false
        };

        var date_time_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_end = 18,
            margin_start = 18
        };
        date_time_box.add_css_class ("content-block");
        date_time_box.append (date_time_auto_box);
        date_time_box.append (date_time_sep);
        date_time_box.append (date_time_manual_box);

        var timezone_label = new Gtk.Label (_("Automatic Timezone")) {
            halign = Gtk.Align.START
        };
        timezone_label.add_css_class ("cb-title");
        var timezone_sublabel = new Gtk.Label (_("Requires internet and location")) {
            halign = Gtk.Align.START
        };
        timezone_sublabel.add_css_class ("cb-subtitle");

        var timezone_label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        timezone_label_box.append (timezone_label);
        timezone_label_box.append (timezone_sublabel);

        var timezone_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var timezone_auto_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        timezone_auto_box.append (timezone_label_box);
        timezone_auto_box.append (timezone_switch);

        try {
            datetime1 = Bus.get_proxy_sync (
                                            BusType.SYSTEM,
                                            "org.freedesktop.timedate1",
                                            "/org/freedesktop/timedate1"
            );

            if (datetime1.CanNTP == false) {
                date_time_switch.sensitive = false;
            } else if (datetime1.NTP) {
                date_time_switch.active = true;
            }
        } catch (IOError e) {
            critical (e.message);
        }

        var timezone_manual_label = new Gtk.Label (_("Timezone")) {
            halign = Gtk.Align.START,
            sensitive = false
        };
        timezone_manual_label.add_css_class ("cb-title");
        var timezone_manual_button_content = new He.ButtonContent ();
        timezone_manual_button_content.label = datetime1.Timezone ?? _("No Location");
        timezone_manual_button_content.icon = "globe-symbolic";
        location_finder = new WorldLocationFinder ();
        var timezone_menu_popover = new Gtk.Popover () {
            autohide = true
        };
        var timezone_menu_popover_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };
        timezone_menu_popover_grid.attach (location_finder, 0, 0, 1, 1);
        timezone_menu_popover.child = timezone_menu_popover_grid;
        var timezone_manual_button = new Gtk.MenuButton () {
            popover = timezone_menu_popover,
            halign = Gtk.Align.END,
            hexpand = true
        };
        timezone_manual_button.child = timezone_manual_button_content;
        var timezone_manual_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            visible = false
        };
        timezone_manual_box.append (timezone_manual_label);
        timezone_manual_box.append (timezone_manual_button);

        var timezone_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            visible = false
        };

        var timezone_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_end = 18,
            margin_start = 18
        };
        timezone_box.add_css_class ("content-block");
        timezone_box.append (timezone_auto_box);
        timezone_box.append (timezone_sep);
        timezone_box.append (timezone_manual_box);

        var timeformat_label = new Gtk.Label (_("Time Format")) {
            halign = Gtk.Align.START
        };
        timeformat_label.add_css_class ("cb-title");

        var timeformat_12h_toggle = new Gtk.ToggleButton () {
            label = _("AM/PM")
        };
        var timeformat_24h_toggle = new Gtk.ToggleButton () {
            label = _("24h"),
            group = timeformat_12h_toggle
        };

        var timeformat_toggle_box = new He.SegmentedButton () {
            halign = Gtk.Align.END,
            hexpand = true
        };
        timeformat_toggle_box.append (timeformat_12h_toggle);
        timeformat_toggle_box.append (timeformat_24h_toggle);

        var timeformat_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_end = 18,
            margin_start = 18,
            margin_top = 6
        };
        timeformat_box.add_css_class ("content-block");
        timeformat_box.append (timeformat_label);
        timeformat_box.append (timeformat_toggle_box);

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        mbox.append (date_time_box);
        mbox.append (timezone_box);
        mbox.append (timeformat_box);

        var clamp = new Bis.Latch () {
            hexpand = true
        };
        clamp.set_child (mbox);

        append (clamp);
        orientation = Gtk.Orientation.VERTICAL;

        date_time_switch.notify["state"].connect (() => {
            try {
                datetime1.SetNTP (date_time_switch.active, true);
            } catch (Error e) {
                date_time_switch.active = false;
                date_time_switch.sensitive = false;
                critical (e.message);
            }

            if (date_time_switch.active) {
                date_time_manual_box.visible = false;
                date_time_sep.visible = false;
            } else {
                date_time_manual_box.visible = true;
                date_time_sep.visible = true;
            }
        });
        if (date_time_switch.active) {
            date_time_manual_box.visible = false;
            date_time_sep.visible = false;
        } else {
            date_time_manual_box.visible = true;
            date_time_sep.visible = true;
        }

        bool syncing_datetime = false;
        ct_manager = new CurrentTimeManager ();
        ct_manager.time_has_changed.connect ((dt) => {
            syncing_datetime = true;
            date_time_time_picker.time = dt;
            date_time_date_picker.date = dt;
            syncing_datetime = false;
        });

        date_time_time_picker.time_changed.connect (() => {
            if (syncing_datetime == true)
                return;

            var now_local = new GLib.DateTime.now_local ();
            var minutes = date_time_time_picker.time.get_minute () - now_local.get_minute ();
            var hours = date_time_time_picker.time.get_hour () - now_local.get_hour ();
            var now_utc = new GLib.DateTime.now_utc ();
            var usec_utc = now_utc.add_hours (hours).add_minutes (minutes).to_unix ();
            try {
                datetime1.set_time (usec_utc * 1000000, false, true);
            } catch (Error e) {
                critical (e.message);
            }
            ct_manager.datetime_has_changed ();
        });

        date_time_date_picker.notify["date"].connect (() => {
            if (date_time_switch.active == true)
                return;

            var now_local = new GLib.DateTime.now_local ();
            var years = date_time_date_picker.date.get_year () - now_local.get_year ();
            var days = date_time_date_picker.date.get_day_of_year () - now_local.get_day_of_year ();
            var now_utc = new GLib.DateTime.now_utc ();
            var usec_utc = now_utc.add_years (years).add_days (days).to_unix ();
            try {
                datetime1.set_time (usec_utc * 1000000, false, true);
            } catch (Error e) {
                critical (e.message);
            }
            ct_manager.datetime_has_changed ();
        });

        timezone_settings.bind ("automatic-timezone", timezone_switch, "active", SettingsBindFlags.DEFAULT);
        timezone_switch.notify["state"].connect (() => {
            if (timezone_switch.active) {
                timezone_manual_box.visible = false;
                timezone_sep.visible = false;
            } else {
                timezone_manual_box.visible = true;
                timezone_sep.visible = true;
            }
        });
        if (timezone_switch.active) {
            timezone_manual_box.visible = false;
            timezone_sep.visible = false;
        } else {
            timezone_manual_box.visible = true;
            timezone_sep.visible = true;
        }

        location_finder.notify["selected-row"].connect (() => {
            var loc = location_finder.get_selected_location ();
            if (loc != null) {
                change_tz (loc.get_timezone_str ());
                timezone_manual_button_content.label = loc.get_timezone_str ();
            }
        });

        change_tz (datetime1.Timezone);

        timeformat_settings.changed["clock-format"].connect (() => {
            if (timeformat_settings.get_string ("clock-format").contains ("12h")) {
                timeformat_12h_toggle.active = true;
                timeformat_24h_toggle.active = false;
            } else {
                timeformat_12h_toggle.active = false;
                timeformat_24h_toggle.active = true;
            }
            ct_manager.datetime_has_changed (true);
        });
        if (timeformat_settings.get_string ("clock-format").contains ("12h")) {
            timeformat_12h_toggle.active = true;
            timeformat_24h_toggle.active = false;
        } else {
            timeformat_12h_toggle.active = false;
            timeformat_24h_toggle.active = true;
        }
        timeformat_12h_toggle.toggled.connect (() => {
            timeformat_settings.set_string ("clock-format", "12h");
            ct_manager.datetime_has_changed (true);
        });
        timeformat_24h_toggle.toggled.connect (() => {
            timeformat_settings.set_string ("clock-format", "24h");
            ct_manager.datetime_has_changed (true);
        });
    }

    private void change_tz (string _tz) {
        var tz = _(_tz);
        var english_tz = _tz;

        var location = location_finder.get_selected_location ();
        if (location != null) {
            tz = location.get_timezone_str ();
        }

        if (datetime1.Timezone != english_tz) {
            try {
                datetime1.set_timezone (english_tz, true);
            } catch (Error e) {
                critical (e.message);
            }
            ct_manager.timezone_has_changed ();
        }

        var local_time = new GLib.DateTime.now_local ();

        float offset = (float) (local_time.get_utc_offset ()) / (float) (GLib.TimeSpan.HOUR);

        if (local_time.is_daylight_savings ()) {
            offset--;
        }
    }
}