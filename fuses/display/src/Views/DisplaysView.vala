/*-
 * Copyright (c) 2023 Fyra Labs
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

public class Display.DisplaysView : Gtk.Grid {
    public DisplaysOverlay displays_overlay;

    private Gtk.ComboBoxText dpi_combo;
    private Gtk.ListBox action_bar;


    private const string TOUCHSCREEN_SETTINGS_PATH = "org.gnome.settings-daemon.peripherals.touchscreen";

    construct {
            displays_overlay = new DisplaysOverlay ();

            var mirror_switch = new He.Switch ();
            var mirror_row = new He.SettingsRow.with_details (_("Mirror Display"), null, (He.Button)mirror_switch);

            dpi_combo = new Gtk.ComboBoxText ();
            dpi_combo.append_text (_("LoDPI") + " (1×)");
            dpi_combo.append_text (_("HiDPI") + " (2×)");
            dpi_combo.append_text (_("HiDPI") + " (3×)");
            
            var dpi_row = new He.SettingsRow.with_details (_("Scaling"), null, (He.Button)dpi_combo);

            var detect_button = new He.OverlayButton ("tv-symbolic", _("Detect Displays"), null) {
                typeb = He.OverlayButton.TypeButton.PRIMARY
            };
            detect_button.child = displays_overlay;

            action_bar = new Gtk.ListBox ();
            action_bar.add_css_class ("content-list");
            action_bar.prepend (dpi_row);
            action_bar.prepend (mirror_row);

            var schema_source = GLib.SettingsSchemaSource.get_default ();
            var rotation_lock_schema = schema_source.lookup (TOUCHSCREEN_SETTINGS_PATH, true);
            if (rotation_lock_schema != null) {
                detect_accelerometer.begin ();
            } else {
                info ("Schema \"org.gnome.settings-daemon.peripherals.touchscreen\" is not installed on your system.");
            }

            orientation = Gtk.Orientation.VERTICAL;
            margin_end = margin_bottom = margin_start = 18;
            attach (detect_button, 0,0);
            attach (action_bar, 0,1);

            unowned Display.MonitorManager monitor_manager = Display.MonitorManager.get_default ();

            displays_overlay.configuration_changed.connect ((changed) => {
                monitor_manager.set_monitor_config ();
            });

            mirror_row.sensitive = monitor_manager.monitors.size > 1;
            monitor_manager.notify["monitor-number"].connect (() => {
                mirror_row.sensitive = monitor_manager.monitors.size > 1;
            });

            detect_button.clicked.connect (() => displays_overlay.rescan_displays ());

            dpi_combo.active = (int)monitor_manager.virtual_monitors[0].scale - 1;

            dpi_combo.changed.connect (() => {
                monitor_manager.set_scale_on_all_monitors ((double)(dpi_combo.active + 1));
                monitor_manager.set_monitor_config ();
            });

            mirror_switch.iswitch.active = monitor_manager.is_mirrored;
            mirror_switch.iswitch.notify["active"].connect (() => {
                if (mirror_switch.iswitch.active) {
                    monitor_manager.enable_clone_mode ();
                    monitor_manager.set_monitor_config ();
                } else {
                    monitor_manager.disable_clone_mode ();
                    monitor_manager.set_monitor_config ();
                }
            });
    }

    private async void detect_accelerometer () {
        bool has_accelerometer = false;

        try {
            SensorProxy sensors = yield GLib.Bus.get_proxy (BusType.SYSTEM, "net.hadess.SensorProxy", "/net/hadess/SensorProxy");
            has_accelerometer = sensors.has_accelerometer;
        } catch (Error e) {
            info ("Unable to connect to SensorProxy bus, probably means no accelerometer supported: %s", e.message);
        }

        if (has_accelerometer) {
            var touchscreen_settings = new GLib.Settings (TOUCHSCREEN_SETTINGS_PATH);

            var rotation_lock_switch = new He.Switch ();
            var rotation_row = new He.SettingsRow.with_details (_("Rotation Lock"), null, (He.Button)rotation_lock_switch);
            action_bar.append (rotation_row);

            touchscreen_settings.bind ("orientation-lock", rotation_lock_switch.iswitch, "state", SettingsBindFlags.DEFAULT);
        }
    }

    [DBus (name = "net.hadess.SensorProxy")]
    private interface SensorProxy : GLib.DBusProxy {
        public abstract bool has_accelerometer { get; }
    }
}
