public class Sound.Fuse : Fusebox.Fuse {
    Gtk.Grid main_grid;
    Gtk.Stack stack;

    InputPanel input_panel;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("sound", null);
        settings.set ("sound/input", "input");
        settings.set ("sound/output", "output");

        Object (
                category: Category.SYSTEM,
                code_name: "com.fyralabs.Fusebox.Sound",
                display_name: _("Sound"),
                description: _("Change sound and microphone volume"),
                icon: "settings-sound-symbolic",
                supported_settings: settings,
                index: 0
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var output_panel = new OutputPanel ();
            input_panel = new InputPanel ();

            stack = new Gtk.Stack () {
                margin_bottom = 24,
                margin_start = 24,
                margin_end = 24,
                vhomogeneous = false
            };
            var stack_switcher = new He.ViewSwitcher () {
                stack = stack
            };
            stack.add_titled (output_panel, "output", _("Output"));
            stack.add_titled (input_panel, "input", _("Input"));

            stack.notify["visible-child"].connect (() => {
                input_panel.set_visibility (stack.visible_child == input_panel);
            });

            var clamp = new Bis.Latch ();
            clamp.set_child (stack);

            var sw = new Gtk.ScrolledWindow () {
                hscrollbar_policy = Gtk.PolicyType.NEVER,
                min_content_height = 500
            };
            sw.set_child (clamp);

            var appbar = new He.AppBar () {
                viewtitle_widget = stack_switcher,
                show_back = false
            };

            main_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (sw, 0, 1);

            var pam = PulseAudioManager.get_default ();
            pam.start ();
        }

        return main_grid;
    }

    public override void shown () {
        main_grid.show ();
        if (stack.visible_child == input_panel) {
            input_panel.set_visibility (true);
        }
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
        switch (location) {
        case "input":
            stack.set_visible_child_name ("input");
            break;
        case "output":
            stack.set_visible_child_name ("output");
            break;
        }
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (
                                                                 null, null
        );

        search_results.set ("%s → %s".printf (display_name, _("Output")), "output");
        search_results.set ("%s → %s → %s".printf (display_name, _("Output"), _("Device")), "output");
        search_results.set ("%s → %s → %s".printf (display_name, _("Output"), _("Event Sounds")), "output");
        search_results.set ("%s → %s → %s".printf (display_name, _("Output"), _("Port")), "output");
        search_results.set ("%s → %s → %s".printf (display_name, _("Output"), _("Volume")), "output");
        search_results.set ("%s → %s → %s".printf (display_name, _("Output"), _("Balance")), "output");
        search_results.set ("%s → %s".printf (display_name, _("Input")), "input");
        search_results.set ("%s → %s → %s".printf (display_name, _("Input"), _("Device")), "input");
        search_results.set ("%s → %s → %s".printf (display_name, _("Input"), _("Port")), "input");
        search_results.set ("%s → %s → %s".printf (display_name, _("Input"), _("Volume")), "input");
        search_results.set ("%s → %s → %s".printf (display_name, _("Input"), _("Enable")), "input");
        return search_results;
    }
}


public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Sound fuse");
    var fuse = new Sound.Fuse ();
    return fuse;
}