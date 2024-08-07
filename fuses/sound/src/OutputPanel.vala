public class Sound.OutputPanel : Gtk.Grid {
    private Gtk.ListBox devices_listbox;
    private unowned PulseAudioManager pam;

    He.Slider volume_scale;
    He.Switch volume_switch;
    He.Slider balance_scale;

    private Device default_device = null;

    public bool screen_reader_active { get; set; }

    construct {
        row_spacing = 6;
        margin_bottom = 18;
        margin_top = 0;

        devices_listbox = new Gtk.ListBox () {
            activate_on_single_click = true
        };

        devices_listbox.row_activated.connect ((row) => {
            pam.set_default_device.begin (((Sound.DeviceRow) row).device);
        });

        var scrolled = new Gtk.ScrolledWindow () {
            vexpand = true,
            min_content_height = 300
        };
        scrolled.set_child (devices_listbox);

        volume_switch = new He.Switch () {
            valign = Gtk.Align.CENTER,
        };
        volume_switch.iswitch.active = true;

        var volume_settings_row = new He.MiniContentBlock () {
            title = _("Volume"),
            hexpand = true
        };

        var volume_adjustment = new Gtk.Adjustment (-1, 0.0, 100.0, 5.0, 0, 0);
        volume_scale = new He.Slider () {
            hexpand = true,
            valign = Gtk.Align.CENTER
        };
        volume_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        volume_scale.scale.adjustment = volume_adjustment;
        volume_scale.scale.draw_value = false;
        volume_scale.add_mark (0, _("0%"));
        volume_scale.add_mark (70, _("Recommended"));
        volume_scale.add_mark (100, _("100%"));

        var settings = new GLib.Settings ("com.fyralabs.Fusebox");
        if (settings.get_boolean ("show-audio-dialog")) {
            audio_alert_dialog_cb ();
        }

        var volume_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        volume_box.append (volume_scale);
        volume_box.append (volume_switch);

        volume_box.set_parent (volume_settings_row);

        var balance_settings_row = new He.MiniContentBlock () {
            title = _("Balance"),
            hexpand = true
        };

        var balance_adjustment = new Gtk.Adjustment (-1, -1, 1, 0.1, 0, 0);
        balance_scale = new He.Slider () {
            hexpand = true,
            valign = Gtk.Align.CENTER
        };
        balance_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        balance_scale.scale.adjustment = balance_adjustment;
        balance_scale.scale.draw_value = false;
        balance_scale.scale.has_origin = false;
        balance_scale.add_mark (-1, _("Left"));
        balance_scale.add_mark (0, _("Center"));
        balance_scale.add_mark (1, _("Right"));

        var balance_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        balance_box.append (balance_scale);

        balance_box.set_parent (balance_settings_row);

        var alerts_settings_row = new He.MiniContentBlock () {
            title = _("Event Alerts"),
            subtitle = _("Event alerts occur when the system gives an alert"),
            hexpand = true
        };

        var audio_alert_check = new Gtk.CheckButton.with_label (_("Play sound"));

        var visual_alert_check = new Gtk.CheckButton.with_label (_("Flash screen")) {
            halign = Gtk.Align.START,
            hexpand = true
        };

        var alerts_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            valign = Gtk.Align.CENTER
        };
        alerts_box.append (audio_alert_check);
        alerts_box.append (visual_alert_check);

        alerts_box.set_parent (alerts_settings_row);

        var screen_reader_settings_row = new He.MiniContentBlock () {
            title = _("Screen Reader"),
            subtitle = _("Provide audio descriptions for items on the screen"),
            hexpand = true
        };

        var screen_reader_switch = new He.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var screen_reader_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        screen_reader_box.append (screen_reader_switch);

        screen_reader_box.set_parent (screen_reader_settings_row);

        var no_device_grid = new He.EmptyPage ();
        no_device_grid.title = _("No Connected Audio Devices Detected");
        no_device_grid.description = _("There is no devices detected. You need to add one to start listening.");
        no_device_grid.icon = "audio-volume-muted-symbolic";
        no_device_grid.action_button.visible = false;
        devices_listbox.set_placeholder (no_device_grid);

        attach (scrolled, 0, 0, 1, 2);
        attach (volume_settings_row, 0, 3);
        attach (balance_settings_row, 0, 4);
        attach (alerts_settings_row, 0, 5);
        attach (screen_reader_settings_row, 0, 6);

        var applications_settings = new GLib.Settings ("org.gnome.desktop.a11y.applications");
        applications_settings.bind ("screen-reader-enabled", this, "screen_reader_active", SettingsBindFlags.DEFAULT);
        bind_property ("screen_reader_active", screen_reader_switch.iswitch, "active", GLib.BindingFlags.BIDIRECTIONAL, () => {
            if (screen_reader_active != screen_reader_switch.iswitch.active) {
                screen_reader_switch.iswitch.activate ();
            }
        }, null);

        pam = PulseAudioManager.get_default ();
        pam.new_device.connect (add_device);
        pam.notify["default-output"].connect (default_changed);

        volume_switch.iswitch.bind_property ("active", volume_scale, "sensitive", BindingFlags.DEFAULT);
        volume_switch.iswitch.bind_property ("active", balance_scale, "sensitive", BindingFlags.DEFAULT);

        var sound_settings = new Settings ("org.gnome.desktop.sound");
        sound_settings.bind ("event-sounds", audio_alert_check, "active", GLib.SettingsBindFlags.DEFAULT);

        var wm_settings = new Settings ("org.gnome.desktop.wm.preferences");
        wm_settings.bind ("visual-bell", visual_alert_check, "active", GLib.SettingsBindFlags.DEFAULT);
        connect_signals ();
    }

    private void default_changed () {
        disconnect_signals ();
        lock (default_device) {
            if (default_device != null) {
                default_device.notify.disconnect (device_notify);
            }

            default_device = pam.default_output;
            if (default_device != null) {
                if (volume_switch.iswitch.active == default_device.is_muted) {
                    volume_switch.iswitch.activate ();
                }
                volume_scale.scale.set_value (default_device.volume);
                balance_scale.scale.set_value (default_device.balance);
                default_device.notify.connect (device_notify);
            }
        }

        connect_signals ();
    }

    private void disconnect_signals () {
        volume_switch.iswitch.notify["active"].disconnect (volume_switch_changed);
        volume_scale.scale.value_changed.disconnect (volume_scale_value_changed);
        balance_scale.scale.value_changed.disconnect (balance_scale_value_changed);
    }

    private void connect_signals () {
        volume_switch.iswitch.notify["active"].connect (volume_switch_changed);
        volume_scale.scale.value_changed.connect (volume_scale_value_changed);
        balance_scale.scale.value_changed.connect (balance_scale_value_changed);
    }

    private void volume_scale_value_changed () {
        disconnect_signals ();

        var settings = new GLib.Settings ("com.fyralabs.Fusebox");
        if (settings.get_boolean ("show-audio-dialog")) {
            audio_alert_dialog_cb ();
        } else {
            pam.change_device_volume (default_device, (float) volume_scale.scale.get_value ());
        }

        connect_signals ();
    }

    private void balance_scale_value_changed () {
        disconnect_signals ();
        pam.change_device_balance (default_device, (float) balance_scale.scale.get_value ());
        connect_signals ();
    }

    private void volume_switch_changed () {
        disconnect_signals ();
        pam.change_device_mute (default_device, !volume_switch.iswitch.active);
        connect_signals ();
    }

    private void device_notify (ParamSpec pspec) {
        disconnect_signals ();
        switch (pspec.get_name ()) {
            case "is-muted":
                if (volume_switch.iswitch.active == default_device.is_muted) {
                    volume_switch.iswitch.activate ();
                }
                break;
            case "volume":
                volume_scale.scale.set_value (default_device.volume);
                break;
            case "balance":
                balance_scale.scale.set_value (default_device.balance);
                break;
        }

        connect_signals ();
    }

    private void add_device (Device device) {
        if (device.input) {
            return;
        }

        var device_row = new DeviceRow (device);
        Gtk.ListBoxRow? row = devices_listbox.get_row_at_index (0);
        if (row != null) {
            device_row.link_to_row ((DeviceRow) row);
        }

        devices_listbox.append (device_row);
        device_row.set_as_default.connect (() => {
            pam.set_default_device.begin (device);
        });
    }

    private void audio_alert_dialog_cb () {
        var settings = new GLib.Settings ("com.fyralabs.Fusebox");
        if (volume_scale.scale.get_value () > (float) 70.0) {
            var ok_button = new He.Button (null, "Understood") {
                is_fill = true
            };

            var volume_alert_dialog = new He.Dialog (
                                                     true,
                                                     ((He.ApplicationWindow) He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this)),
                                                     (_("Audio Volume Too High!")),
                                                     "",
                                                     (_("Volume above 70% can progressively damage your eardrums as you listen to audio.")),
                                                     "audio-volume-overamplified-symbolic",
                                                     ok_button,
                                                     null
            );

            var volume_check = new Gtk.CheckButton () {
                label = (_("I understand the risks, don't show this dialog next time."))
            };

            if (volume_check.active) {
                settings.set_boolean ("show-audio-dialog", false);
            } else {
                settings.set_boolean ("show-audio-dialog", true);
            }

            volume_check.toggled.connect (() => {
                if (volume_check.active) {
                    settings.set_boolean ("show-audio-dialog", false);
                } else {
                    settings.set_boolean ("show-audio-dialog", true);
                }
            });

            volume_alert_dialog.add (volume_check);

            ok_button.clicked.connect (() => {
                if (volume_scale.scale.get_value () > (float) 70.0) {
                    volume_scale.scale.set_value ((float) 69.0);
                    pam.change_device_volume (default_device, (float) 69.0);
                }
                volume_alert_dialog.destroy ();
            });

            volume_alert_dialog.cancel_button.clicked.connect (() => {
                pam.change_device_volume (default_device, (float) volume_scale.scale.get_value ());
                volume_alert_dialog.destroy ();
            });

            volume_alert_dialog.present ();
        }
    }
}