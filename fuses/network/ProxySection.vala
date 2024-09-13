public class Network.ProxySection {
    private He.MiniContentBlock proxy_block;
    private Gtk.DropDown proxy_dropdown;
    private string[] proxy_options = { "Off", "Manual", "Auto" };

    public ProxySection() {
        create_proxy_section();
    }

    public Gtk.Widget get_widget() {
        return proxy_block;
    }

    private void create_proxy_section() {
        proxy_block = new He.MiniContentBlock();
        proxy_block.title = _("Proxy");

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

    public void update() {
        update_proxy_dropdown();
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

    private void handle_proxy_selection() {
        uint selected = proxy_dropdown.selected;

        switch (proxy_options[selected]) {
        case "Manual":
            open_manual_proxy_settings();
            break;
        case "Auto":
            open_auto_proxy_settings();
            break;
        default: // "Off"
            disable_proxy();
            break;
        }
    }

    private void open_manual_proxy_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
                                                 _("Manual Proxy Configuration"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (proxy_block),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
        );

        var server_label = new Gtk.Label(_("Proxy Server:"));
        var server_entry = new Gtk.Entry();

        var port_label = new Gtk.Label(_("Port:"));
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

        dialog.present();
    }

    private void open_auto_proxy_settings() {
        var dialog = new Gtk.Dialog.with_buttons(
                                                 _("Automatic Proxy Settings"),
                                                 He.Misc.find_ancestor_of_type<He.ApplicationWindow> (proxy_block),
                                                 Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
                                                 _("Cancel"), Gtk.ResponseType.CANCEL,
                                                 _("Apply"), Gtk.ResponseType.APPLY
        );

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

        dialog.get_content_area().append(grid);

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

        dialog.present();
    }

    private void set_manual_proxy(string server, string port) {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");

        gsettings.set_string("mode", "manual");

        var http_gsettings = new GLib.Settings("org.gnome.system.proxy.http");
        http_gsettings.set_string("host", server);
        http_gsettings.set_int("port", int.parse(port));

        update_proxy_dropdown();
    }

    private void set_auto_proxy(string url) {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");

        gsettings.set_string("mode", "auto");
        gsettings.set_string("autoconfig-url", url);

        update_proxy_dropdown();
    }

    private void disable_proxy() {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");
        gsettings.set_string("mode", "none");
        update_proxy_dropdown();
    }

    private string get_proxy_mode() {
        var gsettings = new GLib.Settings("org.gnome.system.proxy");
        return gsettings.get_string("mode");
    }
}
