public class Network.NetworkFuse : Fusebox.Fuse {
    private Gtk.Box main_box;
    private NM.Client? nm_client;

    private He.MiniContentBlock wired_block;
    private He.MiniContentBlock vpn_block;
    private He.MiniContentBlock proxy_block;

    private He.Switch wired_switch;
    private Gtk.DropDown proxy_dropdown;

    private NM.Device? device = null;
    protected string uuid = "";

    private List<NM.VpnConnection> vpn_connections;
    private Gtk.ListBox vpn_list_box;

    private string[] proxy_options = { "Off", "Manual", "Auto" };

    public NetworkFuse() {
        Object(
               category : Category.NETWORK,
               code_name : "network-fuse",
               display_name: _("Network"),
               description: _("Ethernet, VPN, Proxy"),
               icon: "preferences-desktop-network-symbolic",
               supported_settings: new GLib.HashTable<string, string?> (null, null)
        );
        supported_settings.set("network", null);
    }

    construct {
        try {
            nm_client = new NM.Client();
        } catch (Error e) {
            warning("Failed to create NM.Client: %s", e.message);
        }

        foreach (var d in nm_client.get_devices()) {
            if (d.get_device_type() == NM.DeviceType.ETHERNET) {
                device = d;
                break;
            }
        }

        get_uuid();
        device.state_changed.connect_after(() => {
            get_uuid();
        });
    }

    public override Gtk.Widget get_widget() {
        if (main_box == null) {
            main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12) {
                margin_start = 18,
                margin_end = 18,
                margin_bottom = 18
            };

            create_wired_section();
            create_vpn_section();
            create_proxy_section();

            var view_label = new Gtk.Label("Network") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class("view-title");

            var appbar = new He.AppBar() {
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

        var settings_button = new He.Button("emblem-system-symbolic", "") {
            is_disclosure = true
        };
        settings_button.add_css_class("circular");

        wired_box.append(wired_switch);
        wired_box.append(settings_button);

        wired_block.widget = wired_box;

        wired_switch.notify["active"].connect(update_wired_status);
        settings_button.clicked.connect(() => {
            open_wired_settings(uuid);
        });
    }

    private void update_wired_status() {
        if (nm_client == null)return;

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

    private void open_wired_settings(string uuid) {
        try {
            var appinfo = AppInfo.create_from_commandline(
                                                          "nm-connection-editor --edit=%s".printf(uuid), null, AppInfoCreateFlags.NONE
            );
            appinfo.launch(null, null);
        } catch (Error e) {
            warning("Failed to open wired settings: %s", e.message);
        }
    }

    private void get_uuid() {
        var active_connection = device.get_active_connection();
        if (active_connection != null) {
            uuid = active_connection.get_uuid();
        } else {
            var available_connections = device.get_available_connections();
            if (available_connections.length > 0) {
                uuid = available_connections[0].get_uuid();
            } else {
                uuid = "";
            }
        }
    }

    private void create_vpn_section() {
        vpn_block = new He.MiniContentBlock();
        vpn_block.title = (_("VPN"));
        update_vpn_subtitle();

        var settings_button = new He.Button("emblem-system-symbolic", "") {
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

    private void update_vpn_list() {
        vpn_connections = new List<NM.VpnConnection> ();

        foreach (var ac in nm_client.get_active_connections()) {
            if (ac is NM.VpnConnection) {
                vpn_connections.append((NM.VpnConnection) ac);
            }
        }

        // Remove all existing rows
        while (vpn_list_box.get_first_child() != null) {
            vpn_list_box.remove(vpn_list_box.get_first_child());
        }

        foreach (var vpn in vpn_connections) {
            var row = new VpnListBoxRow(this, nm_client, vpn);
            vpn_list_box.append(row);
        }

        if (vpn_connections.length() == 0) {
            var no_vpn_label = new Gtk.Label(_("No VPN Connections"));
            no_vpn_label.add_css_class("dim-label");
            vpn_list_box.append(no_vpn_label);
        }
    }

    private void open_vpn_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
                                                 _("VPN Settings"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (main_box),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
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

        dialog.set_default_response(Gtk.ResponseType.APPLY);

        dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY) {
                var server = server_entry.text;
                var protocol = protocol_combo.active.to_string();

                if (server != "" && protocol != null) {
                    apply_vpn_settings(server, protocol);
                } else {
                    warning("Invalid VPN settings");
                }
            }
            dialog.destroy();
        });

        dialog.present();
    }

    private void apply_vpn_settings(string server, string protocol) {
        var connection_name = "%s (%s)".printf(server, protocol);
        var existing_connection = find_vpn_connection(connection_name);

        NM.Connection connection;
        if (existing_connection != null) {
            connection = NM.SimpleConnection.new_clone(existing_connection);
        } else {
            connection = NM.SimpleConnection.new_clone(null);
        }

        // Configure connection settings
        var s_con = connection.get_setting_connection() ?? new NM.SettingConnection();
        s_con.set_property("id", connection_name);
        s_con.set_property("type", "vpn");
        if (existing_connection == null) {
            s_con.set_property("uuid", NM.Utils.uuid_generate());
        }
        connection.add_setting(s_con);

        // Configure VPN settings
        var s_vpn = connection.get_setting_vpn() ?? new NM.SettingVpn();
        s_vpn.set_property("service-type", get_vpn_service_type(protocol));
        s_vpn.set_data("gateway", server);
        connection.add_setting(s_vpn);

        // Add or update the connection
        nm_client.add_connection_async.begin(connection, true, null, (obj, res) => {
            try {
                nm_client.add_connection_async.end(res);
                update_vpn_list();
            } catch (Error e) {
                warning("Failed to add/update VPN connection: %s", e.message);
            }
        });
    }

    private NM.Connection? find_vpn_connection(string connection_name) {
        foreach (var conn in nm_client.get_connections()) {
            var s_con = conn.get_setting_connection();
            if (s_con != null && s_con.get_connection_type() == "vpn" && s_con.get_id() == connection_name) {
                return conn;
            }
        }
        return null;
    }

    private string get_vpn_service_type(string protocol) {
        switch (protocol.down()) {
        case "openvpn" :
            return "org.freedesktop.NetworkManager.openvpn";
        case "l2tp":
            return "org.freedesktop.NetworkManager.l2tp";
        default:
            warning("Unsupported VPN protocol: %s", protocol);
            return "";
        }
    }

    public void update_vpn_subtitle() {
        var active_vpn = get_active_vpn_connection();
        if (active_vpn != null) {
            vpn_block.subtitle = active_vpn.get_id();
        } else {
            vpn_block.subtitle = _("Not connected");
        }
    }

    private NM.VpnConnection? get_active_vpn_connection() {
        foreach (var ac in nm_client.get_active_connections()) {
            if (ac is NM.VpnConnection) {
                return (NM.VpnConnection) ac;
            }
        }
        return null;
    }

    private void create_proxy_section() {
        proxy_block = new He.MiniContentBlock();
        proxy_block.title = ("Proxy");

        proxy_dropdown = new Gtk.DropDown.from_strings(proxy_options) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        update_proxy_dropdown();

        proxy_dropdown.notify["selected-item"].connect(() => {
            handle_proxy_selection();
        });

        proxy_block.widget = proxy_dropdown;
    }

    private void update_proxy_dropdown() {
        var proxy_mode = get_proxy_mode();
        if (proxy_mode == "manual") {
            proxy_dropdown.selected = 1; // Manual
        } else if (proxy_mode == "auto") {
            proxy_dropdown.selected = 2; // Auto
        } else {
            proxy_dropdown.selected = 0; // Off
        }
    }

    // Handle proxy selection from dropdown
    private void handle_proxy_selection() {
        uint selected = proxy_dropdown.selected;

        switch (proxy_options[selected]) {
        case "Manual" :
            open_manual_proxy_settings();
            break;
        case "Auto":
            set_auto_proxy("");
            break;
        default: // "Off"
            disable_proxy();
            break;
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
                                                 _("Manual Proxy Configuration"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (main_box),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
        );

        var server_label = new Gtk.Label("Proxy Server:");
        var server_entry = new Gtk.Entry();

        var port_label = new Gtk.Label("Port:");
        var port_entry = new Gtk.Entry();

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
        grid.attach(port_label, 0, 1);
        grid.attach(port_entry, 1, 1);

        dialog.get_content_area().append(grid);

        dialog.set_default_response(Gtk.ResponseType.APPLY);

        dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY) {
                var server = server_entry.get_text();
                var port = port_entry.get_text();
                if (server != "" && port != "") {
                    set_manual_proxy(server, port);
                } else {
                    warning("Invalid proxy settings");
                }
            }
            dialog.destroy();
        });

        dialog.show();
    }

    private void open_auto_proxy_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
                                                 _("Automatic Proxy Settings"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (main_box),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
        );

        var content_area = dialog.get_content_area();

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

        dialog.set_default_response(Gtk.ResponseType.APPLY);

        dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY) {
                var pac_url = pac_entry.get_text();
                if (pac_url != "") {
                    set_auto_proxy(pac_url);
                } else {
                    warning("Invalid PAC URL");
                }
            }
            dialog.destroy();
        });

        dialog.show();
    }

    private void set_manual_proxy(string server, string port) {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");

        // Set proxy mode to manual
        gsettings.set_string("mode", "manual");

        // Set proxy details (for HTTP, can repeat for HTTPS, FTP, etc.)
        var http_gsettings = new GLib.Settings("org.gnome.system.proxy.http");
        http_gsettings.set_string("host", server);
        http_gsettings.set_int("port", int.parse(port));

        print("Manual Proxy set: %s:%s\n", server, port);
    }

    // Set Auto proxy (PAC) using gsettings
    private void set_auto_proxy(string url) {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");

        gsettings.set_string("mode", "auto");
        gsettings.set_string("autoconfig-url", url);

        print("Auto Proxy is enabled with PAC URL: %s\n", url);
    }

    // Disable proxy by setting mode to 'none'
    private void disable_proxy() {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");

        // Set the proxy mode to none
        gsettings.set_string("mode", "none");

        print("Proxy is disabled.\n");
    }

    // Helper to get current proxy mode
    private string get_proxy_mode() {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");
        return gsettings.get_string("mode");
    }

    public override void shown() {
        update_wired_status();
        update_proxy_status();
        update_vpn_list();
        update_vpn_subtitle();

        if (nm_client != null) {
            nm_client.notify["active-connections"].connect(() => {
                update_wired_status();
                update_vpn_subtitle();
            });
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
        var results = new GLib.HashTable<string, string> (null, null);

        return results;
    }

    private class VpnListBoxRow : Gtk.ListBoxRow {
        private NM.Client nm_client;
        private NM.VpnConnection vpn_connection;
        private NM.Connection connection;
        private Gtk.Label name_label;
        private Gtk.Label status_label;
        private He.Switch vpn_switch;
        private NetworkFuse parent_fuse;

        public VpnListBoxRow(NetworkFuse parent, NM.Client client, NM.VpnConnection vpn) {
            this.nm_client = client;
            this.parent_fuse = parent;
            this.vpn_connection = vpn;
            this.connection = nm_client.get_connection_by_uuid(vpn.get_uuid());

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12);
            box.margin_start = box.margin_end = 12;
            box.margin_top = box.margin_bottom = 6;

            name_label = new Gtk.Label(vpn.get_id());
            name_label.halign = Gtk.Align.START;
            name_label.hexpand = true;

            status_label = new Gtk.Label("");
            status_label.halign = Gtk.Align.END;

            vpn_switch = new He.Switch();
            vpn_switch.valign = Gtk.Align.CENTER;

            box.append(name_label);
            box.append(status_label);
            box.append(vpn_switch);

            child = box;

            update_status();

            vpn_switch.iswitch.notify["active"].connect(toggle_vpn_connection);
            vpn_connection.notify["state"].connect(() => {
                update_status();
                parent_fuse.update_vpn_subtitle();
            });
        }

        private void update_status() {
            switch (vpn_connection.get_state()) {
            case NM.ActiveConnectionState.ACTIVATED:
                status_label.label = _("Connected");
                vpn_switch.iswitch.active = true;
                break;
            case NM.ActiveConnectionState.ACTIVATING:
                status_label.label = _("Connecting...");
                vpn_switch.iswitch.active = true;
                break;
            default:
                status_label.label = _("Disconnected");
                vpn_switch.iswitch.active = false;
                break;
            }
        }

        private void toggle_vpn_connection() {
            if (vpn_switch.iswitch.active) {
                if (connection != null) {
                    nm_client.activate_connection_async.begin(connection, null, null, null, (obj, res) => {
                        try {
                            nm_client.activate_connection_async.end(res);
                            parent_fuse.update_vpn_subtitle();
                        } catch (Error e) {
                            warning("Failed to activate VPN connection: %s", e.message);
                        }
                    });
                } else {
                    warning("Failed to find VPN connection");
                }
            } else {
                nm_client.deactivate_connection_async.begin(vpn_connection, null, (obj, res) => {
                    try {
                        nm_client.deactivate_connection_async.end(res);
                        parent_fuse.update_vpn_subtitle();
                    } catch (Error e) {
                        warning("Failed to deactivate VPN connection: %s", e.message);
                    }
                });
            }
        }
    }
}

public Fusebox.Fuse get_fuse(Module module) {
    debug("Activating Network fuse");
    var fuse = new Network.NetworkFuse();
    return fuse;
}
