public class Network.WifiSection {
    private NM.Client nm_client;
    private He.MiniContentBlock wifi_block;
    private He.Switch wifi_switch;
    private NM.DeviceWifi? wifi_device;
    private Gtk.ListBox wifi_list_box;

    public WifiSection(NM.Client client) {
        nm_client = client;
        wifi_device = get_wifi_device();
        create_wifi_section();
    }

    public Gtk.Widget get_widget() {
        return wifi_block;
    }

    private void create_wifi_section() {
        wifi_block = new He.MiniContentBlock();
        wifi_block.title = _("Wi-Fi");

        var wifi_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        wifi_switch = new He.Switch() {
            valign = Gtk.Align.CENTER
        };

        var settings_button = new He.Button("emblem-system-symbolic", "") {
            is_disclosure = true
        };
        settings_button.add_css_class("circular");

        wifi_box.append(wifi_switch);
        wifi_box.append(settings_button);

        wifi_block.widget = wifi_box;

        wifi_switch.notify["active"].connect(toggle_wifi);
        settings_button.clicked.connect(open_wifi_settings);

        wifi_list_box = new Gtk.ListBox();
        wifi_list_box.set_selection_mode(Gtk.SelectionMode.NONE);
        wifi_block.widget = wifi_list_box;

        update_wifi_status();
        scan_wifi_networks();
    }

    private NM.DeviceWifi? get_wifi_device() {
        foreach (var device in nm_client.get_devices()) {
            if (device is NM.DeviceWifi) {
                return device as NM.DeviceWifi;
            }
        }
        return null;
    }

    public void update() {
        update_wifi_status();
        scan_wifi_networks();
    }

    private void update_wifi_status() {
        if (wifi_device != null) {
            wifi_switch.iswitch.active = wifi_device.get_state() == NM.DeviceState.ACTIVATED;
            wifi_block.subtitle = wifi_switch.iswitch.active ? _("Connected") : _("Disconnected");
        } else {
            wifi_block.subtitle = _("Not available");
            wifi_switch.sensitive = false;
        }
    }

    private void toggle_wifi() {
        if (wifi_device != null) {
            bool enable_wifi = wifi_switch.iswitch.active;
            nm_client.wireless_set_enabled(enable_wifi);
            if (enable_wifi) {
                scan_wifi_networks();
            } else {
                clear_wifi_list();
            }
        }
    }

    private void open_wifi_settings() {
        try {
            var appinfo = AppInfo.create_from_commandline(
                                                          "nm-connection-editor", null, AppInfoCreateFlags.NONE
            );
            appinfo.launch(null, null);
        } catch (Error e) {
            warning("Failed to open Wi-Fi settings: %s", e.message);
        }
    }

    private void scan_wifi_networks() {
        if (wifi_device != null) {
            wifi_device.request_scan_async.begin(null, (obj, res) => {
                try {
                    wifi_device.request_scan_async.end(res);
                    update_wifi_list();
                } catch (Error e) {
                    warning("Failed to scan Wi-Fi networks: %s", e.message);
                }
            });
        }
    }

    private void update_wifi_list() {
        clear_wifi_list();

        if (wifi_device != null) {
            var access_points = wifi_device.get_access_points();
            access_points.foreach((ap) => {
                var row = new WifiListBoxRow(nm_client, wifi_device, ap);
                wifi_list_box.append(row);
            });
        }
    }

    private void clear_wifi_list() {
        while (wifi_list_box.get_first_child() != null) {
            wifi_list_box.remove(wifi_list_box.get_first_child());
        }
    }
}

private class WifiListBoxRow : Gtk.ListBoxRow {
    public WifiListBoxRow(NM.Client client, NM.DeviceWifi device, NM.AccessPoint ap) {
        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12);
        box.margin_start = box.margin_end = 12;
        box.margin_top = box.margin_bottom = 6;

        var ssid = NM.Utils.ssid_to_utf8(ap.get_ssid().get_data());
        var name_label = new Gtk.Label(ssid) {
            halign = Gtk.Align.START,
            hexpand = true
        };

        var strength_icon = new Gtk.Image();
        update_strength_icon(ap, strength_icon);

        box.append(name_label);
        box.append(strength_icon);

        child = box;

        ap.notify["strength"].connect(() => {
            update_strength_icon(ap, strength_icon);
        });
    }

    private void update_strength_icon(NM.AccessPoint ap, Gtk.Image icon) {
        string icon_name;
        if (ap.get_strength() > 80) {
            icon_name = "network-wireless-signal-excellent-symbolic";
        } else if (ap.get_strength() > 55) {
            icon_name = "network-wireless-signal-good-symbolic";
        } else if (ap.get_strength() > 30) {
            icon_name = "network-wireless-signal-ok-symbolic";
        } else {
            icon_name = "network-wireless-signal-weak-symbolic";
        }
        icon.set_from_icon_name(icon_name);
    }
}
