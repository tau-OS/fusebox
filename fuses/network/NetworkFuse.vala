public class Network.NetworkFuse : Fusebox.Fuse {
    private Gtk.Box main_box;
    private NM.Client? nm_client;

    private WiredSection wired_section;
    private WifiSection wifi_section;
    private VpnSection vpn_section;
    private ProxySection proxy_section;

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

        wired_section = new WiredSection(nm_client);
        wifi_section = new WifiSection(nm_client);
        vpn_section = new VpnSection(this, nm_client);
        proxy_section = new ProxySection();

        foreach (var d in nm_client.get_devices()) {
            if (d.get_device_type() == NM.DeviceType.ETHERNET) {
                device = d;
                break;
            }
        }
    }

    public override Gtk.Widget get_widget() {
        if (main_box == null) {
            main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12) {
                margin_start = 18,
                margin_end = 18,
                margin_bottom = 18
            };

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
            main_box.append(wired_section.get_widget());
            main_box.append(wifi_section.get_widget());
            main_box.append(vpn_section.get_widget());
            main_box.append(proxy_section.get_widget());
        }

        return main_box;
    }

    public override void shown() {
        wired_section.update();
        wifi_section.update();
        vpn_section.update();
        proxy_section.update();
    }

    public override void hidden() {
    }

    public override void search_callback(string location) {
    }

    public override async GLib.HashTable<string, string> search(string search) {
        var results = new GLib.HashTable<string, string> (null, null);

        return results;
    }
}

public Fusebox.Fuse get_fuse(Module module) {
    debug("Activating Network fuse");
    var fuse = new Network.NetworkFuse();
    return fuse;
}
