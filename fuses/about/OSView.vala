[DBus (name = "org.freedesktop.hostname1")]
public interface SystemInterface : Object {
    [DBus (name = "IconName")]
    public abstract string icon_name { owned get; }

    public abstract string pretty_hostname { owned get; set; }
    public abstract string static_hostname { owned get; set; }
}
[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get; }
}

public class About.OSView : Gtk.Box {
    private SystemInterface system_interface;
    private SessionManager? session_manager;
    private Gtk.Label hostname_subtitle;
    private Gtk.Label gpu_subtitle;
    private Gtk.Label storage_subtitle;
    private Gtk.ProgressBar storage_gauge;

    construct {
        try {
            system_interface = Bus.get_proxy_sync (
                                                   BusType.SYSTEM,
                                                   "org.freedesktop.hostname1",
                                                   "/org/freedesktop/hostname1"
            );
        } catch (GLib.Error e) {
            warning ("%s", e.message);
        }

        var os_pretty_name = "%s".printf (
                                          Environment.get_os_info (GLib.OsInfoKey.NAME)
        );
        var os_sub_name = "<b>%s %s</b>".printf (
                                                 Environment.get_os_info (GLib.OsInfoKey.VERSION_ID) ?? "",
                                                 Environment.get_os_info (GLib.OsInfoKey.VERSION_CODENAME) ??
                                                 "(Guadalajara)" // Remember to change this with every new GNOME release until we do a new DE
        );
        var os_title = new Gtk.Label (os_pretty_name) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        os_title.add_css_class ("view-title");
        var os_subtitle = new Gtk.Label (os_sub_name.replace ("(", "“").replace (")", "”")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        os_subtitle.add_css_class ("view-subtitle");
        var os_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        os_box.append (os_title);
        os_box.append (os_subtitle);
        os_box.add_css_class ("main-content-block");

        var hostname_title = new Gtk.Label (_("Device Name")) {
            selectable = true,
            xalign = 0
        };
        hostname_title.add_css_class ("cb-title");
        hostname_subtitle = new Gtk.Label (get_host_name ()) {
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        hostname_subtitle.add_css_class ("cb-subtitle");
        var hostname_image = new Gtk.Image () {
            halign = Gtk.Align.START,
        };
        var icon_name = system_interface.icon_name + "-symbolic" ?? "computer-symbolic";
        // check if icon exists
        var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        if (!icon_theme.has_icon (icon_name)) {
            warning ("TODO: Icon %s not found, using default icon.", icon_name);
            icon_name = "computer-symbolic";
        }
        hostname_image.icon_name = icon_name;
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
            valign = Gtk.Align.CENTER
        };
        var storage_title = new Gtk.Label (_("Storage")) {
            selectable = true,
            margin_bottom = 6,
            xalign = 0
        };
        storage_title.add_css_class ("cb-title");
        storage_subtitle = new Gtk.Label ("") {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        storage_subtitle.add_css_class ("cb-subtitle");
        get_storage_info.begin ();
        var storage_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        storage_box.append (storage_gauge);
        storage_box.append (storage_title);
        storage_box.append (storage_subtitle);
        storage_box.add_css_class ("mini-content-block");

        var model_title = new Gtk.Label (_("Model")) {
            selectable = true,
            xalign = 0
        };
        model_title.add_css_class ("cb-title");
        var model_subtitle = new Gtk.Label (get_model_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        model_subtitle.add_css_class ("cb-subtitle");
        var model_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        model_box.append (model_title);
        model_box.append (model_subtitle);
        model_box.add_css_class ("mini-content-block");

        var ram_title = new Gtk.Label (_("RAM")) {
            selectable = true,
            xalign = 0
        };
        ram_title.add_css_class ("cb-title");
        var ram_subtitle = new Gtk.Label (get_mem_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        ram_subtitle.add_css_class ("cb-subtitle");
        var ram_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        ram_box.append (ram_title);
        ram_box.append (ram_subtitle);
        ram_box.add_css_class ("mini-content-block");

        var cpu_title = new Gtk.Label (_("Processor")) {
            selectable = true,
            xalign = 0
        };
        cpu_title.add_css_class ("cb-title");
        var cpu_subtitle = new Gtk.Label (get_cpu_info ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        cpu_subtitle.add_css_class ("cb-subtitle");
        var cpu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        cpu_box.append (cpu_title);
        cpu_box.append (cpu_subtitle);
        cpu_box.add_css_class ("mini-content-block");

        var gpu_title = new Gtk.Label (_("Graphics")) {
            selectable = true,
            xalign = 0
        };
        gpu_title.add_css_class ("cb-title");
        gpu_subtitle = new Gtk.Label ("") {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        gpu_subtitle.add_css_class ("cb-subtitle");
        get_graphics_info.begin ();
        var gpu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        gpu_box.append (gpu_title);
        gpu_box.append (gpu_subtitle);
        gpu_box.add_css_class ("mini-content-block");

        var stor_host_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_bottom = 6,
            vexpand = false,
            homogeneous = true
        };
        stor_host_box.append (hostname_box);
        stor_host_box.append (storage_box);

        var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
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

        var bug_button = new He.OverlayButton ("emblem-important-symbolic",_("Report Problem…"), null);
        bug_button.child = (scroller);
        bug_button.typeb = He.OverlayButton.TypeButton.PRIMARY;

        var clamp = new Bis.Latch ();
        clamp.set_child (bug_button);

        append (clamp);
        orientation = Gtk.Orientation.VERTICAL;

        bug_button.clicked.connect (() => {
            try {
                var appinfo = GLib.AppInfo.create_from_commandline (
                                                                    "com.fyralabs.Mondai",
                                                                    "com.fyralabs.Mondai",
                                                                    GLib.AppInfoCreateFlags.NONE
                );
                if (appinfo != null) {
                    try {
                        appinfo.launch (null, null);
                    } catch (Error e) {
                        critical (e.message);
                    }
                } else {
                    warning ("Could not find Mondai, falling back to bugurl");
                    // get bugurl from /etc/os-release
                    var bugurl = Environment.get_os_info ("BUG_REPORT_URL");

                    if (bugurl != null) {
                        try {
                            AppInfo.launch_default_for_uri (bugurl, null);
                        } catch (Error e) {
                            critical (e.message);
                        }
                    } else {
                        warning ("Could not find bugurl");
                    }
                }
            } catch (Error e) {
                critical (e.message);
            }
        });

        hostname_button.clicked.connect (() => {
            var rename_button = new He.FillButton (_("Rename")) {
                sensitive = false
            };
            var title_label = new Gtk.Label ("Rename Your Computer") {
                halign = Gtk.Align.CENTER
            };
            title_label.add_css_class ("view-title");
            var t_label = new Gtk.Label
                    ("When the computer is renamed, it affects how it is seen via Bluetooth and SSH.") {
                halign = Gtk.Align.START,
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD
            };
            var image = new Gtk.Image () {
                pixel_size = 64,
                icon_name = "dialog-information-symbolic"
            };

            var rename_entry = new He.TextField () {
                text = system_interface.pretty_hostname
            };

            rename_entry.notify["is-valid"].connect (() => {
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
            main_box.append (t_label);
            main_box.append (rename_entry);

            var cancel_button = new He.TextButton ("Cancel");

            var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                homogeneous = true
            };
            action_box.append (cancel_button);
            action_box.append (rename_button);

            main_box.append (action_box);

            var handle = new Gtk.WindowHandle ();
            handle.set_child (main_box);

            var rename_dialog = new He.Window () {
                resizable = false,
                has_title = false,
                parent = He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this)
            };
            rename_dialog.set_size_request (360, 266);
            rename_dialog.set_default_size (360, 266);
            rename_dialog.set_child (handle);
            rename_dialog.add_css_class ("dialog-content");
            rename_dialog.show ();

            rename_button.clicked.connect (() => {
                set_host_name (rename_entry.text);
                rename_dialog.close ();
            });

            cancel_button.clicked.connect (() => {
                rename_dialog.close ();
            });
        });
    }

    private string get_host_name () {
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
                sname.canon ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'", ' ');
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
                                new Variant ("(sb)", sname.replace (" ", "-").replace ("'", "").ascii_down (), false),
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
            { "Mesa DRI ", "" },
            { "Mesa (.*)", "\\1" },
            { "[(]R[)]", "®" },
            { "[(]TM[)]", "™" },
            { "Gallium .* on (AMD .*)", "\\1" },
            { "(AMD .*) [(].*", "\\1" },
            { "(AMD Ryzen) (.*)", "\\1 \\2" },
            { "(AMD [A-Z])(.*)", "\\1\\L\\2\\E" },
            { "Advanced Micro Devices, Inc\\. \\[.*?\\] .*? \\[(.*?)\\] .*", "AMD® \\1" },
            { "Advanced Micro Devices, Inc\\. \\[.*?\\] (.*)", "AMD® \\1" },
            { "Graphics Controller", "Graphics" },
            { "Intel Corporation", "Intel®" },
            { "NVIDIA Corporation (.*) \\[(\\S*) (\\S*) (.*)\\]", "NVIDIA® \\2® \\3® \\4" }
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

    private string ? try_get_arm_model (GLib.HashTable<string, string> values) {
        string? cpu_implementer = values.lookup ("CPU implementer");
        string? cpu_part = values.lookup ("CPU part");

        if (cpu_implementer == null || cpu_part == null) {
            return null;
        }

        return ARMPartDecoder.decode_arm_model (cpu_implementer, cpu_part);
    }

    private string ? get_cpu_info () {
        unowned GLibTop.sysinfo? info = GLibTop.get_sysinfo ();

        if (info == null) {
            return null;
        }

        var counts = new GLib.HashTable<string, uint> (str_hash, str_equal);
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

            if (!counts.contains (model)) {
                counts.@set (model, 1);
            } else {
                counts.@set (model, counts.@get (model) + 1);
            }
        }

        if (counts.size () == 0) {
            return null;
        }

        string result = "";
        foreach (var key in counts.get_keys_as_array ()) {
            if (result.length > 0) {
                result += "\n";
            }

            // get core count
            uint cores = counts.@get (key);

            result += "%s x%u".printf (clean_name (key), cores);
        }

        return result;
    }

    private string get_mem_info () {
        uint64 mem_total = 0;

        GUdev.Client client = new GUdev.Client ({ "dmi" });
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
        var primary_gpu = yield get_gpu_info ();

        gpu_subtitle.label = primary_gpu;
    }

    private async string ? get_gpu_info () {
        if (session_manager == null) {
            try {
                session_manager = yield Bus.get_proxy (BusType.SESSION,
                    "org.gnome.SessionManager",
                    "/org/gnome/SessionManager");

                // ! really sus
                return clean_name (session_manager.renderer == "" ?
                                   GL.glGetString (GL.GL_RENDERER) :
                                   session_manager.renderer
                );
            } catch (IOError e) {
                warning ("Unable to connect to GNOME Session Manager for GPU details: %s", e.message);
                return _("Unknown Graphics");
            }
        }

        return "";
    }

    private string ? get_model_info () {
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
            // var manufacturer_name = "To Be Filled By O.E.M.";

            return get_board_info ();
        }
    }

    // Fallback function to get the board name instead
    private string ? get_board_info () {
        try {
            // get product name
            var product_name_file = File.new_for_path ("/sys/devices/virtual/dmi/id/product_name");
            var product_name = (string) product_name_file.load_bytes (null, null).get_data ();
            product_name = product_name.strip ();

            return product_name;
        } catch (Error e) {
            debug (e.message);
            // continue
        }


        try {
            // load /sys/dmi/device/board_vendor
            var board_vendor_file = File.new_for_path ("/sys/devices/virtual/dmi/id/board_vendor");
            uint8[] board_vendor_raw;
            board_vendor_file.load_contents (null, out board_vendor_raw, null);
            string board_vendor = (string) board_vendor_raw;
            board_vendor = board_vendor.strip ();


            // board_name
            var board_name_file = File.new_for_path ("/sys/devices/virtual/dmi/id/board_name");
            uint8[] board_name_raw;
            board_name_file.load_contents (null, out board_name_raw, null);
            string board_name = (string) board_name_raw;
            board_name = board_name.strip ();

            string board = @"$board_vendor $board_name".strip ();

            return board;
        } catch (Error e) {
            debug ("Error loading board vendor: %s", e.message);
            var board_vendor = "To Be Filled By O.E.M.";

            return board_vendor;
        }
    }

    private async void get_storage_info () {
        // We are only interested in the main drive's size
        var file_root = GLib.File.new_for_path ("/");
        string storage_capacity = "";
        string used = "";

        try {
            var infos = yield file_root.query_filesystem_info_async (GLib.FileAttribute.FILESYSTEM_SIZE);

            storage_capacity = GLib.format_size (infos.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_SIZE));

            var infou = yield file_root.query_filesystem_info_async (GLib.FileAttribute.FILESYSTEM_USED);

            used = GLib.format_size (infou.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_USED));

            var fraction = (double.parse (used) * 1.04858) / (double.parse (storage_capacity) * 1.04858);

            storage_gauge.set_fraction (fraction);
            storage_subtitle.label = used + " / " + storage_capacity;
        } catch (Error e) {
            critical (e.message);
            storage_subtitle.label = _("Unknown");
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

    public static string ? decode_arm_model (string cpu_implementer, string cpu_part) {
        string? result = null;

        if (cpu_implementer == null || cpu_part == null) {
            return result;
        }

        // long.parse supports 0x format hex strings
        int cpu_implementer_int = (int) long.parse (cpu_implementer);
        int cpu_part_int = (int) long.parse (cpu_part);

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
