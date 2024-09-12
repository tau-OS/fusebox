public class Network.NetworkFuse : Fusebox.Fuse {
    private Gtk.Box main_box;
    private NM.Client? nm_client;

    private He.MiniContentBlock wired_block;
    private He.MiniContentBlock vpn_block;
    private He.MiniContentBlock proxy_block;

    private He.Switch wired_switch;
    private He.Switch proxy_switch;

    public NetworkFuse () {
        Object (
            category: Category.NETWORK,
            code_name: "network-fuse",
            display_name: _("Network"),
            description: _("Manage network connections and settings"),
            icon: "preferences-desktop-network-symbolic",
            supported_settings: new GLib.HashTable<string, string?> (null, null)
        );
        supported_settings.set ("network", null);
    }

    construct {
        try {
            nm_client = new NM.Client();
        } catch (Error e) {
            warning("Failed to create NM.Client: %s", e.message);
        }
    }

    public override Gtk.Widget get_widget () {
        if (main_box == null) {
            main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12) {
                margin_start = 18,
                margin_end = 18,
                margin_bottom = 18
            };

            create_wired_section();
            create_vpn_section();
            create_proxy_section();

            var view_label = new Gtk.Label ("Network") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var appbar = new He.AppBar () {
                viewtitle_widget = view_label,
                show_back = false,
                show_left_title_buttons = false,
                show_right_title_buttons = true
            };

            main_box.append(appbar);
            main_box.append(wired_block);
            main_box.append(vpn_block);
            main_box.append(proxy_block);
        }

        return main_box;
    }

    private void create_wired_section() {
        wired_block = new He.MiniContentBlock();
        wired_block.title = (_("Wired"));

        var wired_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.END
        };
        wired_switch = new He.Switch() {
            valign = Gtk.Align.CENTER
        };

        var settings_button = new Gtk.Button.from_icon_name("emblem-system-symbolic");
        settings_button.add_css_class("circular");

        wired_box.append(wired_switch);
        wired_box.append(settings_button);

        wired_block.widget = wired_box;

        wired_switch.notify["active"].connect(update_wired_status);
        settings_button.clicked.connect(open_wired_settings);
    }

    private void create_vpn_section() {
        vpn_block = new He.MiniContentBlock();
        vpn_block.title = (_("VPN"));

        var vpn_label = new Gtk.Label(_("Not set up")) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        vpn_block.widget = vpn_label;
    }

    private void create_proxy_section() {
        proxy_block = new He.MiniContentBlock();
        proxy_block.title = (_("Proxy"));

        var proxy_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.END
        };
        proxy_switch = new He.Switch() {
            hexpand = true,
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER
        };

        var proxy_settings_button = new Gtk.Button.with_label(_("Off")) {
            valign = Gtk.Align.CENTER
        };
        proxy_settings_button.add_css_class("flat");

        proxy_box.append(proxy_switch);
        proxy_box.append(proxy_settings_button);

        proxy_block.widget = proxy_box;

        proxy_switch.notify["active"].connect(update_proxy_status);
        proxy_settings_button.clicked.connect(open_proxy_settings);
    }

    private void update_wired_status() {
        if (nm_client == null) return;

        NM.Device? wired_device = null;
        foreach (var device in nm_client.get_devices()) {
            if (device.get_device_type() == NM.DeviceType.ETHERNET) {
                wired_device = device;
                break;
            }
        }

        if (wired_device != null) {
            var active_connection = wired_device.get_active_connection();
            if (active_connection != null) {
                wired_block.subtitle = _("Connected - %u Mb/s").printf(((NM.DeviceEthernet)wired_device).get_speed());
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

    private void update_proxy_status() {
        if (proxy_switch.iswitch.active) {
            ((Gtk.Label)((Gtk.Button)proxy_switch.get_next_sibling()).get_child()).label = _("On");
        } else {
            ((Gtk.Label)((Gtk.Button)proxy_switch.get_next_sibling()).get_child()).label = _("Off");
        }
    }

    private void open_wired_settings() {
        try {
            Process.spawn_command_line_async("nm-connection-editor --type=ethernet");
        } catch (Error e) {
            warning("Failed to open wired settings: %s", e.message);
        }
    }

    private void open_proxy_settings() {
        print("Opening proxy settings...\n");
    }

    public override void shown() {
        update_wired_status();
        update_proxy_status();

        if (nm_client != null) {
            nm_client.notify["active-connections"].connect(update_wired_status);
        }
    }

    public override void hidden() {
        if (nm_client != null) {
            nm_client.notify["active-connections"].disconnect(update_wired_status);
        }
    }

    public override void search_callback(string location) {

    }

    public override async GLib.HashTable<string, string> search(string search) {
        var results = new GLib.HashTable<string, string>(null, null);

        return results;
    }
}

public Fusebox.Fuse get_fuse(Module module) {
    debug("Activating Network fuse");
    var fuse = new Network.NetworkFuse();
    return fuse;
}