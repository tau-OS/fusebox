public class Network.VpnSection {
    private NetworkFuse fuse;
    private NM.Client nm_client;
    private He.MiniContentBlock vpn_block;
    private Gtk.ListBox vpn_list_box;

    public VpnSection(NetworkFuse nfuse, NM.Client client) {
        nm_client = client;
        fuse = nfuse;
        create_vpn_section();
    }

    public Gtk.Widget get_widget() {
        return vpn_block;
    }

    private void create_vpn_section() {
        vpn_block = new He.MiniContentBlock();
        vpn_block.title = _("VPN");

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

        vpn_list_box = new Gtk.ListBox();
        vpn_list_box.set_selection_mode(Gtk.SelectionMode.NONE);
        vpn_block.widget = vpn_list_box;

        update_vpn_list();
    }

    public void update() {
        update_vpn_list();
        update_vpn_subtitle();
    }

    private void update_vpn_list() {
        Gtk.Widget? child = vpn_list_box.get_first_child();
        while (child != null) {
            vpn_list_box.remove(child);
            child = vpn_list_box.get_first_child();
        }

        foreach (var connection in nm_client.get_active_connections()) {
            if (connection is NM.VpnConnection) {
                var row = new VpnListBoxRow(this, nm_client, (NM.VpnConnection) connection);
                vpn_list_box.append(row);
            }
        }
    }

    private void update_vpn_subtitle() {
        var active_vpn = get_active_vpn_connection();
        if (active_vpn != null) {
            vpn_block.subtitle = active_vpn.get_id();
        } else {
            vpn_block.subtitle = _("Not connected");
        }
    }

    private void open_vpn_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
                                                 _("VPN Settings"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (vpn_block),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
        );

        var content_area = dialog.get_content_area();

        // Add your custom VPN settings widgets here
        var server_label = new Gtk.Label(_("VPN Server:"));
        var server_entry = new Gtk.Entry();

        var protocol_label = new Gtk.Label(_("Protocol:"));
        var protocol_cb = new He.Dropdown();
        protocol_cb.append("OpenVPN");
        protocol_cb.append("L2TP");
        protocol_cb.dropdown.selected = 0;
        protocol_cb.valign = Gtk.Align.CENTER;

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
        grid.attach(protocol_cb, 1, 1);

        content_area.append(grid);

        dialog.set_default_response(Gtk.ResponseType.APPLY);

        dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY) {
                var server = server_entry.text;
                var protocol = protocol_cb.dropdown.selected.to_string();

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
        case "l2tp" :
            return "org.freedesktop.NetworkManager.l2tp";
        default:
            warning("Unsupported VPN protocol: %s", protocol);
            return "";
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

    private class VpnListBoxRow : Gtk.ListBoxRow {
        private NM.Client nm_client;
        private NM.VpnConnection vpn_connection;
        private NM.Connection connection;
        private Gtk.Label name_label;
        private Gtk.Label status_label;
        private He.Switch vpn_switch;
        private VpnSection parent_section;

        public VpnListBoxRow(VpnSection parent, NM.Client client, NM.VpnConnection vpn) {
            this.nm_client = client;
            this.parent_section = parent;
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
                parent_section.update();
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
                            parent_section.update();
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
                        parent_section.update();
                    } catch (Error e) {
                        warning("Failed to deactivate VPN connection: %s", e.message);
                    }
                });
            }
        }
    }
}