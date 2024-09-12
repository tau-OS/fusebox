public class Network.NetworkFuse : Fusebox.Fuse {
    private Gtk.Box main_box;
    private NM.Client? nm_client;

    private He.MiniContentBlock wired_block;
    private He.MiniContentBlock vpn_block;
    private He.MiniContentBlock proxy_block;

    private He.Switch wired_switch;
    private Gtk.DropDown proxy_dropdown;

    private string[] proxy_options = { "Off", "Manual", "Auto" };

    public NetworkFuse () {
        Object (
            category: Category.NETWORK,
            code_name: "network-fuse",
            display_name: _("Network"),
            description: _("Ethernet, VPN, Proxy"),
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
            hexpand = true,
            halign = Gtk.Align.END
        };
        wired_switch = new He.Switch() {
            valign = Gtk.Align.CENTER
        };

        var settings_button = new He.Button ("emblem-system-symbolic", "") {
            is_disclosure = true
        };
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
        vpn_block.subtitle =  (_("Not set up"));

        var settings_button = new He.Button ("emblem-system-symbolic", "") {
            is_disclosure = true
        };
        settings_button.add_css_class("circular");

        var vpn_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        vpn_box.append(settings_button);

        vpn_block.widget = vpn_box;

        settings_button.clicked.connect(open_vpn_settings);
    }

    private void create_proxy_section() {
        proxy_block = new He.MiniContentBlock();
        proxy_block.title = (_("Proxy"));

        var proxy_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        var proxy_model = new Gtk.StringList(proxy_options);
        proxy_dropdown = new Gtk.DropDown(proxy_model, null) {
            valign = Gtk.Align.CENTER
        };

        proxy_box.append(proxy_dropdown);

        proxy_block.widget = proxy_box;

        proxy_dropdown.notify["selected"].connect(update_proxy_status);
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
        var selected_option = proxy_options[proxy_dropdown.selected];
        print("Proxy status changed to: %s\n", selected_option);

        switch (selected_option) {
            case "Off":
                // Disable proxy
                break;
            case "Manual":
                open_manual_proxy_settings();
                break;
            case "Auto":
                open_auto_proxy_settings();
                break;
        }
    }

    private void open_manual_proxy_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
            _("Manual Proxy Settings"),
            null,
            Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
            _("Close"),
            Gtk.ResponseType.CLOSE
        );

        var content_area = dialog.get_content_area();

        // Add your custom manual proxy settings widgets here
        var http_label = new Gtk.Label(_("HTTP Proxy:"));
        var http_entry = new Gtk.Entry();

        var https_label = new Gtk.Label(_("HTTPS Proxy:"));
        var https_entry = new Gtk.Entry();

        var grid = new Gtk.Grid() {
            row_spacing = 6,
            column_spacing = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };

        grid.attach(http_label, 0, 0);
        grid.attach(http_entry, 1, 0);
        grid.attach(https_label, 0, 1);
        grid.attach(https_entry, 1, 1);

        content_area.append(grid);

        dialog.present();
    }

    private void open_auto_proxy_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
            _("Automatic Proxy Settings"),
            null,
            Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
            _("Close"),
            Gtk.ResponseType.CLOSE
        );

        var content_area = dialog.get_content_area();

        // Add your custom automatic proxy settings widgets here
        var pac_label = new Gtk.Label(_("PAC URL:"));
        var pac_entry = new Gtk.Entry();

        var grid = new Gtk.Grid() {
            row_spacing = 6,
            column_spacing = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };

        grid.attach(pac_label, 0, 0);
        grid.attach(pac_entry, 1, 0);

        content_area.append(grid);

        dialog.present();
    }

    private void open_vpn_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
            _("VPN Settings"),
            null,
            Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
            _("Close"),
            Gtk.ResponseType.CLOSE
        );

        var content_area = dialog.get_content_area();

        // Add your custom VPN settings widgets here
        var server_label = new Gtk.Label(_("VPN Server:"));
        var server_entry = new Gtk.Entry();

        var protocol_label = new Gtk.Label(_("Protocol:"));
        var protocol_combo = new Gtk.ComboBoxText();
        protocol_combo.append_text("OpenVPN");
        protocol_combo.append_text("L2TP");
        protocol_combo.active = 0;

        var grid = new Gtk.Grid() {
            row_spacing = 6,
            column_spacing = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };

        grid.attach(server_label, 0, 0);
        grid.attach(server_entry, 1, 0);
        grid.attach(protocol_label, 0, 1);
        grid.attach(protocol_combo, 1, 1);

        content_area.append(grid);

        dialog.present();
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