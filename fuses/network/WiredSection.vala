public class Network.WiredSection {
    private NM.Client nm_client;
    private He.MiniContentBlock wired_block;
    private He.Switch wired_switch;
    private NM.Device? device;

    public WiredSection(NM.Client client) {
        nm_client = client;
        device = get_ethernet_device();
        create_wired_section();
    }

    public Gtk.Widget get_widget() {
        return wired_block;
    }

    private void create_wired_section() {
        wired_block = new He.MiniContentBlock();
        wired_block.title = _("Wired");

        var wired_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };
        wired_switch = new He.Switch() {
            valign = Gtk.Align.CENTER
        };

        var settings_button = new He.Button("emblem-system-symbolic", "") {
            is_disclosure = true
        };
        settings_button.add_css_class("circular");

        wired_box.append(wired_switch);
        wired_box.append(settings_button);

        wired_block.widget = wired_box;

        wired_switch.notify["active"].connect(update_wired_status);
        settings_button.clicked.connect(open_wired_settings);
    }

    private NM.Device? get_ethernet_device() {
        foreach (var d in nm_client.get_devices()) {
            if (d.get_device_type() == NM.DeviceType.ETHERNET) {
                return d;
            }
        }
        return null;
    }

    public void update() {
        update_wired_status();
    }

    private void update_wired_status() {
        if (device != null) {
            var active_connection = device.get_active_connection();
            if (active_connection != null) {
                wired_block.subtitle = _("Connected - %u Mb/s").printf(((NM.DeviceEthernet) device).get_speed());
                wired_switch.iswitch.active = true;
            } else {
                wired_block.subtitle = _("Disconnected");
                wired_switch.iswitch.active = false;
            }
        } else {
            wired_block.subtitle = _("Not available");
            wired_switch.sensitive = false;
        }
    }

    private void open_wired_settings() {
        try {
            var appinfo = AppInfo.create_from_commandline(
                                                          "nm-connection-editor", null, AppInfoCreateFlags.NONE
            );
            appinfo.launch(null, null);
        } catch (Error e) {
            warning("Failed to open wired settings: %s", e.message);
        }
    }
}
