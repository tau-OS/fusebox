[DBus (name = "org.freedesktop.hostname1")]
public interface SystemInterface : Object {
    [DBus (name = "IconName")]
    public abstract string icon_name { owned get; }

    public abstract string pretty_hostname { owned get; set; }
    public abstract string static_hostname { owned get; set; }
}
[DBus(name = "org.freedesktop.DBus.ObjectManager")]
interface UDisk2 : GLib.Object {
	public signal void InterfacesAdded(ObjectPath object_path, GLib.HashTable<string, GLib.HashTable<string, Variant>> interfaces_and_properties);
	public signal void InterfacesRemoved(ObjectPath object_path, string[] interfaces);
	public abstract void GetManagedObjects(out GLib.HashTable<ObjectPath, GLib.HashTable<string, GLib.HashTable<string, Variant>>> path) throws GLib.IOError, GLib.DBusError;
}
[DBus(timeout = 1000000, name = "org.freedesktop.UDisks2.Block")]
interface Block : GLib.Object {
	public abstract uint64 Size { owned get; }
}

public class About.OSView : Gtk.Box {
    private SystemInterface system_interface;
    private Gtk.Label hostname_subtitle;
    private Gtk.Label gpu_subtitle;
    private Gtk.ProgressBar storage_gauge;
    private UDisk2 udisk;
    private GLib.HashTable<ObjectPath, GLib.HashTable<string, GLib.HashTable<string, Variant>>> objects;
    private GLib.DBusConnection storage_dbus_connection;

    public signal void InterfacesAdded();
	public signal void InterfacesRemoved();

    construct {
        try {
			this.storage_dbus_connection = Bus.get_sync(BusType.SYSTEM);

			this.udisk = this.storage_dbus_connection.get_proxy_sync<UDisk2>("org.freedesktop.UDisks2", "/org/freedesktop/UDisks2");
			this.udisk.InterfacesAdded.connect((object_path, interfaces_and_properties) => { InterfacesAdded(); });
			this.udisk.InterfacesRemoved.connect((object_path, interfaces) => { InterfacesRemoved(); });
		} catch (GLib.IOError e) {
			this.udisk = null;
			this.storage_dbus_connection = null;
		}

        var os_pretty_name = "%s".printf (
            Environment.get_os_info (GLib.OsInfoKey.NAME)
        );
        var os_sub_name = "<b>%s %s</b>".printf (
            Environment.get_os_info (GLib.OsInfoKey.VERSION_ID) ?? "",
            Environment.get_os_info (GLib.OsInfoKey.VERSION_CODENAME) ?? "(Guadalajara)" // Remember to change this with every new GNOME release until we do a new DE
        );
        var os_title = new Gtk.Label (os_pretty_name) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        os_title.get_style_context ().add_class ("view-title");
        var os_subtitle = new Gtk.Label (os_sub_name.replace ("(","“").replace(")","”")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        os_subtitle.get_style_context ().add_class ("view-subtitle");
        var os_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        os_box.append (os_title);
        os_box.append (os_subtitle);
        os_box.add_css_class ("main-content-block");

        var hostname_title = new Gtk.Label (_("Device Name")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        hostname_title.get_style_context ().add_class ("cb-title");
        hostname_subtitle = new Gtk.Label (get_host_name ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        hostname_subtitle.get_style_context ().add_class ("cb-subtitle");
        var hostname_image = new Gtk.Image () {
            halign = Gtk.Align.START,
            icon_name = system_interface.icon_name + "-symbolic"
        };
        hostname_image.add_css_class ("rounded-icon");
        var hostname_button = new Gtk.Button () {
            icon_name = "pan-end-symbolic",
            hexpand = true,
            halign = Gtk.Align.END
        };
        hostname_button.add_css_class ("flat");
        hostname_button.add_css_class ("circular");
        var hostname_action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        hostname_action_box.append (hostname_title);
        hostname_action_box.append (hostname_button);
        var hostname_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        hostname_box.append (hostname_image);
        hostname_box.append (hostname_action_box);
        hostname_box.append (hostname_subtitle);
        hostname_box.add_css_class ("mini-content-block");

        storage_gauge = new Gtk.ProgressBar () {
            vexpand = true,
            valign = Gtk.Align.START
        };
        get_storage_frac.begin ();
        var storage_title = new Gtk.Label (_("Storage")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            margin_bottom = 6,
            xalign = 0
        };
        storage_title.get_style_context ().add_class ("cb-title");
        string inf = get_storage_info ();
        var storage_subtitle = new Gtk.Label (inf) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        storage_subtitle.get_style_context ().add_class ("cb-subtitle");
        var storage_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        storage_box.append (storage_gauge);
        storage_box.append (storage_title);
        storage_box.append (storage_subtitle);
        storage_box.add_css_class ("mini-content-block");

        var model_title = new Gtk.Label (_("Model")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        model_title.get_style_context ().add_class ("cb-title");
        var model_subtitle = new Gtk.Label (get_model_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        model_subtitle.get_style_context ().add_class ("cb-subtitle");
        var model_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        model_box.append (model_title);
        model_box.append (model_subtitle);
        model_box.add_css_class ("mini-content-block");

        var ram_title = new Gtk.Label (_("RAM")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        ram_title.get_style_context ().add_class ("cb-title");
        var ram_subtitle = new Gtk.Label (get_mem_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        ram_subtitle.get_style_context ().add_class ("cb-subtitle");
        var ram_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        ram_box.append (ram_title);
        ram_box.append (ram_subtitle);
        ram_box.add_css_class ("mini-content-block");

        var cpu_title = new Gtk.Label (_("Processor")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        cpu_title.get_style_context ().add_class ("cb-title");
        var cpu_subtitle = new Gtk.Label (get_cpu_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        cpu_subtitle.get_style_context ().add_class ("cb-subtitle");
        var cpu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        cpu_box.append (cpu_title);
        cpu_box.append (cpu_subtitle);
        cpu_box.add_css_class ("mini-content-block");

        var gpu_title = new Gtk.Label (_("Graphics")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        gpu_title.get_style_context ().add_class ("cb-title");
        gpu_subtitle = new Gtk.Label ("") {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        get_graphics_info.begin ();
        gpu_subtitle.get_style_context ().add_class ("cb-subtitle");
        var gpu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        gpu_box.append (gpu_title);
        gpu_box.append (gpu_subtitle);
        gpu_box.add_css_class ("mini-content-block");

        var bug_button = new He.PillButton (_("Report A Problem…")) {
            hexpand = true,
            margin_bottom = 12,
            halign = Gtk.Align.CENTER
        };

        var view_label = new Gtk.Label ("About") {
            halign = Gtk.Align.START,
            margin_bottom = 6,
            margin_start = 18,
            margin_end = 18
        };
        view_label.add_css_class ("view-title");

        var stor_host_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_bottom = 6,
            vexpand = false
        };
        stor_host_box.append (hostname_box);
        stor_host_box.append (storage_box);

        var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18
        };
        info_box.append (os_box);
        info_box.append (stor_host_box);
        info_box.append (model_box);
        info_box.append (cpu_box);
        info_box.append (gpu_box);
        info_box.append (ram_box);

        var scroller = new Gtk.ScrolledWindow () {
            vexpand = true
        };
        scroller.set_child (info_box);

        orientation = Gtk.Orientation.VERTICAL;
        spacing = 6;
        append (view_label);
        append (scroller);
        append (bug_button);

        hostname_button.clicked.connect (() => {
            var rename_button = new He.FillButton (_("Rename")) {
                sensitive = false
            };
            var title_label = new Gtk.Label ("Rename Your Computer") {
                halign = Gtk.Align.START
            };
            title_label.add_css_class ("view-title");
            var subtitle_label = new Gtk.Label ("The computer's identity") {
                halign = Gtk.Align.START
            };
            subtitle_label.add_css_class ("view-subtitle");
            var text_label = new Gtk.Label ("When you rename your computer, it'll reflect on how it is seen by other devices. For example, via bluetooth and secure shells.") {
                halign = Gtk.Align.START,
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD
            };
            var image = new Gtk.Image () {
                pixel_size = 128,
                icon_name = "dialog-information-symbolic"
            };

            var rename_entry = new Gtk.Entry () {
                text = hostname_subtitle.label
            };

            rename_entry.buffer.inserted_text.connect (() => {
                rename_button.sensitive = true;
            });

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24) {
                margin_top = 24,
                margin_bottom = 24,
                margin_start = 24,
                margin_end = 24
            };
            main_box.append (image);
            main_box.append (title_label);
            main_box.append (subtitle_label);
            main_box.append (text_label);
            main_box.append (rename_entry);

            var cancel_button = new He.TextButton ("Cancel");

            var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                homogeneous = true
            };
            action_box.append (cancel_button);
            action_box.append (rename_button);

            main_box.append (action_box);

            var rename_dialog = new He.Window () {
                resizable = false,
                has_title = false
            };
            rename_dialog.set_size_request (360, 400);
            rename_dialog.set_default_size (360, 400);
            rename_dialog.set_child (main_box);
            rename_dialog.show ();

            rename_button.clicked.connect (() => {
                set_host_name (rename_entry.buffer.get_text ());
                rename_dialog.close ();
            });

            cancel_button.clicked.connect (() => {
                rename_dialog.close ();
            });
        });

        bug_button.clicked.connect (() => {
            var appinfo = new GLib.DesktopAppInfo ("co.tauos.Mondai");
            if (appinfo != null) {
                try {
                    appinfo.launch (null, null);
                } catch (Error e) {
                    critical (e.message);
                }
            }
        });
    }

    private void get_system_interface_instance () {
        if (system_interface == null) {
            try {
                system_interface = Bus.get_proxy_sync (
                    BusType.SYSTEM,
                    "org.freedesktop.hostname1",
                    "/org/freedesktop/hostname1"
                );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }

    private string get_host_name () {
        get_system_interface_instance ();

        if (system_interface == null) {
            return GLib.Environment.get_host_name ();
        }

        string hostname = system_interface.pretty_hostname;

        if (hostname.length == 0) {
            hostname = system_interface.static_hostname;
        }

        return hostname;
    }

    private void set_host_name (string sname) {
        get_system_interface_instance ();
        hostname_subtitle.label = sname;

        if (system_interface.pretty_hostname != null) {
            try {
                var dbsi = new DBusProxy.for_bus_sync (
                                                        BusType.SYSTEM,
                                                        DBusProxyFlags.NONE,
                                                        null,
                                                        "org.freedesktop.hostname1",
                                                        "/org/freedesktop/hostname1",
                                                        "org.freedesktop.hostname1",
                                                        null
                                                      );
                dbsi.call_sync (            
                                "SetPrettyHostname",
                                new Variant ("(sb)", sname, false),
                                DBusCallFlags.NONE,
                                -1,
                                null
                               );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
        if (system_interface.static_hostname != null) {
            try {
                sname.canon ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", ' ');
                var dbsi = new DBusProxy.for_bus_sync (
                                                        BusType.SYSTEM,
                                                        DBusProxyFlags.NONE,
                                                        null,
                                                        "org.freedesktop.hostname1",
                                                        "/org/freedesktop/hostname1",
                                                        "org.freedesktop.hostname1",
                                                        null
                                                      );
                dbsi.call_sync (            
                                "SetStaticHostname",
                                new Variant ("(sb)", sname.replace (" ","-").ascii_down (), false),
                                DBusCallFlags.NONE,
                                -1,
                                null
                               );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }

    struct ReplaceStrings {
        string regex;
        string replacement;
    }
    private string clean_name (string info) {

        string pretty = GLib.Markup.escape_text (info).strip ();

        const ReplaceStrings REPLACE_STRINGS[] = {
            { "Mesa DRI ", ""},
            { "Mesa (.*)", "\\1"},
            { "[(]R[)]", "®"},
            { "[(]TM[)]", "™"},
            { "Gallium .* on (AMD .*)", "\\1"},
            { "(AMD .*) [(].*", "\\1"},
            { "(AMD Ryzen) (.*)", "\\1 \\2"},
            { "(AMD [A-Z])(.*)", "\\1\\L\\2\\E"},
            { "Advanced Micro Devices, Inc\\. \\[.*?\\] .*? \\[(.*?)\\] .*", "AMD® \\1"},
            { "Advanced Micro Devices, Inc\\. \\[.*?\\] (.*)", "AMD® \\1"},
            { "Graphics Controller", "Graphics"},
            { "Intel Corporation", "Intel®"},
            { "NVIDIA Corporation (.*) \\[(\\S*) (\\S*) (.*)\\]", "NVIDIA® \\2® \\3® \\4"}
        };

        try {
            foreach (ReplaceStrings replace_string in REPLACE_STRINGS) {
                GLib.Regex re = new GLib.Regex (replace_string.regex, 0, 0);
                bool matched = re.match (pretty);
                pretty = re.replace (pretty, -1, 0, replace_string.replacement, 0);
                if (matched) {
                    break;
                }
            }
        } catch (Error e) {
            critical ("Couldn't cleanup vendor string: %s", e.message);
        }

        return pretty;
    }
    private string? try_get_arm_model (GLib.HashTable<string, string> values) {
        string? cpu_implementer = values.lookup ("CPU implementer");
        string? cpu_part = values.lookup ("CPU part");

        if (cpu_implementer == null || cpu_part == null) {
            return null;
        }

        return ARMPartDecoder.decode_arm_model (cpu_implementer, cpu_part);
    }
    private string? get_cpu_info () {
        unowned GLibTop.sysinfo? info = GLibTop.get_sysinfo ();

        if (info == null) {
            return null;
        }

        var counts = new Gee.HashMap<string, uint> ();
        const string[] KEYS = { "model name", "cpu", "Processor" };

        for (int i = 0; i < info.ncpu; i++) {
            unowned GLib.HashTable<string, string> values = info.cpuinfo[i].values;
            string? model = null;
            foreach (var key in KEYS) {
                model = values.lookup (key);

                if (model != null) {
                    break;
                }
            }

            if (model == null) {
                model = try_get_arm_model (values);
                if (model == null) {
                    continue;
                }
            }

            string? core_count = values.lookup ("cpu cores");
            if (core_count != null) {
                counts.@set (model, uint.parse (core_count));
                continue;
            }

            if (!counts.has_key (model)) {
                counts.@set (model, 1);
            } else {
                counts.@set (model, counts.@get (model) + 1);
            }
        }

        if (counts.size == 0) {
            return null;
        }

        string result = "";
        foreach (var cpu in counts.entries) {
            if (result.length > 0) {
                result += "\n";
            }

            result += "%s ".printf (clean_name (cpu.key));
        }

        return result;
    }

    private string get_mem_info () {
        uint64 mem_total = 0;

        GUdev.Client client = new GUdev.Client ({"dmi"});
        GUdev.Device? device = client.query_by_sysfs_path ("/sys/devices/virtual/dmi/id");

        if (device != null) {
            uint64 devices = device.get_property_as_uint64 ("MEMORY_ARRAY_NUM_DEVICES");
            for (int item = 0; item < devices; item++) {
                mem_total += device.get_property_as_uint64 ("MEMORY_DEVICE_%d_SIZE".printf (item));
            }
        }

        if (mem_total == 0) {
            GLibTop.mem mem;
            GLibTop.get_mem (out mem);
            mem_total = mem.total;
        }

        return GLib.format_size (mem_total, GLib.FormatSizeFlags.DEFAULT);
    }
    private async void get_graphics_info () {
        try {
            var dbsi = new DBusProxy.for_bus_sync (
                BusType.SESSION,
                DBusProxyFlags.NONE,
                null,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager",
                "org.gnome.SessionManager",
                null
            );

            var vr = dbsi.get_cached_property ("Renderer");
            var renderer = vr.get_string ();
            gpu_subtitle.label = clean_name(renderer);
        } catch (Error e) {
            debug (e.message);
            var renderer = (_("Unknown Graphics"));
            gpu_subtitle.label = renderer;
        }
    }

    private string? get_model_info () {
        try {
            var oem_file = new KeyFile ();
            oem_file.load_from_file ("/etc/oem.conf", KeyFileFlags.NONE);
            // Assume we get the manufacturer name
            var manufacturer_name = oem_file.get_string ("OEM", "Manufacturer");
            var manufacturer_version = oem_file.get_string ("OEM", "Version");
            var manufacturer_support = oem_file.get_string ("OEM", "URL");

            return manufacturer_name + manufacturer_version + "/n" + manufacturer_support;
        } catch (Error e) {
            debug (e.message);
            var manufacturer_name = "To Be Filled By O.E.M.";

            return manufacturer_name;
        }
    }

    private string? get_storage_info () {
        double storage_capacity = 0.0;
        double used = 0.0;
        try {
            udisk.GetManagedObjects(out objects);
		    foreach (var o in objects.get_keys()) {
                var block = storage_dbus_connection.get_proxy_sync<Block>("org.freedesktop.UDisks2", o);
                storage_capacity += double.parse (GLib.format_size (block.Size));
            }
        } catch (Error e) {
            critical (e.message);
        }

        var file_root = GLib.File.new_for_path ("/");
        try {
            var info = file_root.query_filesystem_info (GLib.FileAttribute.FILESYSTEM_USED);
            used = (double.parse(GLib.format_size (info.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_USED))));
        } catch (Error e) {
            critical (e.message);
        }

        return "%0.0f GB / %0.0f GB".printf(used, storage_capacity);
    }
    private async void get_storage_frac () {
        var file_root = GLib.File.new_for_path ("/");
        try {
            var info = yield file_root.query_filesystem_info_async (GLib.FileAttribute.FILESYSTEM_USED);
            storage_gauge.set_fraction (double.parse(GLib.format_size (info.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_USED))) / 1024);
        } catch (Error e) {
            critical (e.message);
        }
    }
}

public class About.ARMPartDecoder {
    struct ARMPart {
        int id;
        string name;
    }

    struct ARMImplementer {
        int id;
        ARMPart[] parts;
        string name;
    }

    const ARMPart ARM_PARTS[] = {
        { 0x810, "ARM810" },
        { 0x920, "ARM920" },
        { 0x922, "ARM922" },
        { 0x926, "ARM926" },
        { 0x940, "ARM940" },
        { 0x946, "ARM946" },
        { 0x966, "ARM966" },
        { 0xa20, "ARM1020" },
        { 0xa22, "ARM1022" },
        { 0xa26, "ARM1026" },
        { 0xb02, "ARM11 MPCore" },
        { 0xb36, "ARM1136" },
        { 0xb56, "ARM1156" },
        { 0xb76, "ARM1176" },
        { 0xc05, "Cortex-A5" },
        { 0xc07, "Cortex-A7" },
        { 0xc08, "Cortex-A8" },
        { 0xc09, "Cortex-A9" },
        { 0xc0d, "Cortex-A17" }, /* Originally A12 */
        { 0xc0f, "Cortex-A15" },
        { 0xc0e, "Cortex-A17" },
        { 0xc14, "Cortex-R4" },
        { 0xc15, "Cortex-R5" },
        { 0xc17, "Cortex-R7" },
        { 0xc18, "Cortex-R8" },
        { 0xc20, "Cortex-M0" },
        { 0xc21, "Cortex-M1" },
        { 0xc23, "Cortex-M3" },
        { 0xc24, "Cortex-M4" },
        { 0xc27, "Cortex-M7" },
        { 0xc60, "Cortex-M0+" },
        { 0xd01, "Cortex-A32" },
        { 0xd03, "Cortex-A53" },
        { 0xd04, "Cortex-A35" },
        { 0xd05, "Cortex-A55" },
        { 0xd07, "Cortex-A57" },
        { 0xd08, "Cortex-A72" },
        { 0xd09, "Cortex-A73" },
        { 0xd0a, "Cortex-A75" },
        { 0xd0b, "Cortex-A76" },
        { 0xd0c, "Neoverse-N1" },
        { 0xd13, "Cortex-R52" },
        { 0xd20, "Cortex-M23" },
        { 0xd21, "Cortex-M33" },
        { 0xd4a, "Neoverse-E1" }
    };

    const ARMPart BROADCOM_PARTS[] = {
        { 0x0f, "Brahma B15" },
        { 0x100, "Brahma B53" }
    };

    const ARMPart DEC_PARTS[] = {
        { 0xa10, "SA110" },
        { 0xa11, "SA1100" }
    };

    const ARMPart CAVIUM_PARTS[] = {
        { 0x0a0, "ThunderX" },
        { 0x0a1, "ThunderX 88XX" },
        { 0x0a2, "ThunderX 81XX" },
        { 0x0a3, "ThunderX 83XX" },
        { 0x0af, "ThunderX2 99xx" }
    };

    const ARMPart APM_PARTS[] = {
        { 0x000, "X-Gene" }
    };

    const ARMPart QUALCOMM_PARTS[] = {
        { 0x00f, "Scorpion" },
        { 0x02d, "Scorpion" },
        { 0x04d, "Krait" },
        { 0x06f, "Krait" },
        { 0x201, "Kryo" },
        { 0x205, "Kryo" },
        { 0x211, "Kryo" },
        { 0x800, "Falkor V1/Kryo" },
        { 0x801, "Kryo V2" },
        { 0xc00, "Falkor" },
        { 0xc01, "Saphira" }
    };

    const ARMPart SAMSUNG_PARTS[] = {
        { 0x001, "exynos-m1" }
    };

    const ARMPart NVIDIA_PARTS[] = {
        { 0x000, "Denver" },
        { 0x003, "Denver 2" }
    };

    const ARMPart MARVELL_PARTS[] = {
        { 0x131, "Feroceon 88FR131" },
        { 0x581, "PJ4/PJ4b" },
        { 0x584, "PJ4B-MP" }
    };

    const ARMPart FARADAY_PARTS[] = {
        { 0x526, "FA526" },
        { 0x626, "FA626" }
    };

    const ARMPart INTEL_PARTS[] = {
        { 0x200, "i80200" },
        { 0x210, "PXA250A" },
        { 0x212, "PXA210A" },
        { 0x242, "i80321-400" },
        { 0x243, "i80321-600" },
        { 0x290, "PXA250B/PXA26x" },
        { 0x292, "PXA210B" },
        { 0x2c2, "i80321-400-B0" },
        { 0x2c3, "i80321-600-B0" },
        { 0x2d0, "PXA250C/PXA255/PXA26x" },
        { 0x2d2, "PXA210C" },
        { 0x411, "PXA27x" },
        { 0x41c, "IPX425-533" },
        { 0x41d, "IPX425-400" },
        { 0x41f, "IPX425-266" },
        { 0x682, "PXA32x" },
        { 0x683, "PXA930/PXA935" },
        { 0x688, "PXA30x" },
        { 0x689, "PXA31x" },
        { 0xb11, "SA1110" },
        { 0xc12, "IPX1200" }
    };

    const ARMPart HISILICON_PARTS[] = {
        { 0xd01, "Kunpeng-920" } /* aka tsv110 */
    };

    const ARMImplementer ARM_IMPLEMENTERS[] = {
        { 0x41, ARM_PARTS, "ARM" },
        { 0x42, BROADCOM_PARTS, "Broadcom" },
        { 0x43, CAVIUM_PARTS, "Cavium" },
        { 0x44, DEC_PARTS, "DEC" },
        { 0x48, HISILICON_PARTS, "HiSilicon" },
        { 0x4e, NVIDIA_PARTS, "Nvidia" },
        { 0x50, APM_PARTS, "APM" },
        { 0x51, QUALCOMM_PARTS, "Qualcomm" },
        { 0x53, SAMSUNG_PARTS, "Samsung" },
        { 0x56, MARVELL_PARTS, "Marvell" },
        { 0x66, FARADAY_PARTS, "Faraday" },
        { 0x69, INTEL_PARTS, "Intel" },
    };

    public static string? decode_arm_model (string cpu_implementer, string cpu_part) {
        string? result = null;

        if (cpu_implementer == null || cpu_part == null) {
            return result;
        }

        // long.parse supports 0x format hex strings
        int cpu_implementer_int = (int)long.parse (cpu_implementer);
        int cpu_part_int = (int)long.parse (cpu_part);

        if (cpu_implementer_int == 0 || cpu_part_int == 0) {
            return result;
        }

        foreach (var implementer in ARM_IMPLEMENTERS) {
            if (cpu_implementer_int == implementer.id) {
                result = implementer.name + " ";
                foreach (var part in implementer.parts) {
                    if (cpu_part_int == part.id) {
                        result += part.name;
                    }
                }
            }
        }

        return result;
    }
}