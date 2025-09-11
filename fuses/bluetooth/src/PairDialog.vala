/*
 * Copyright (c) 2023 Fyra Labs
 * Copyright (c) 2016-2022 elementary LLC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
public class PairDialog : He.Dialog {
    public enum AuthType {
        REQUEST_CONFIRMATION,
        REQUEST_AUTHORIZATION,
        DISPLAY_PASSKEY,
        DISPLAY_PIN_CODE
    }

    public ObjectPath object_path { get; construct; }
    public AuthType auth_type { get; construct; }
    public string passkey { get; construct; }
    public bool cancelled { get; set; }

    // Un-used default constructor
    private PairDialog (Gtk.Window? main_window) {
        base (main_window, "", "", "", null, null);
    }

    public PairDialog.request_authorization (ObjectPath object_path, Gtk.Window ? main_window) {
        Object (
                auth_type : AuthType.REQUEST_AUTHORIZATION,
                object_path : object_path,
                title: _("Confirm Bluetooth Pairing")
        );
    }

    public PairDialog.display_passkey (ObjectPath object_path,
                                       uint32 passkey,
                                       uint16 entered,
                                       Gtk.Window ? main_window) {
        Object (
                auth_type : AuthType.DISPLAY_PASSKEY,
                object_path: object_path,
                passkey: "%u".printf (passkey),
                title: _("Confirm Bluetooth Passkey")
        );
    }

    public PairDialog.request_confirmation (ObjectPath object_path,
                                            uint32 passkey,
                                            Gtk.Window ? main_window) {
        Object (
                auth_type : AuthType.REQUEST_CONFIRMATION,
                object_path: object_path,
                passkey: "%u".printf (passkey),
                title: _("Confirm Bluetooth Passkey")
        );
    }

    public PairDialog.display_pin_code (ObjectPath object_path, string pincode, Gtk.Window ? main_window) {
        Object (
                auth_type : AuthType.DISPLAY_PIN_CODE,
                object_path: object_path,
                passkey: pincode,
                title: _("Enter Bluetooth PIN")
        );
    }

    construct {
        Bluetooth.Services.Device device;
        string device_name = _("Unknown Bluetooth Device");
        try {
            device = Bus.get_proxy_sync (
                                         BusType.SYSTEM,
                                         "org.bluez",
                                         object_path,
                                         DBusProxyFlags.GET_INVALIDATED_PROPERTIES
            );
            icon = device.icon ?? "settings-bluetooth-symbolic";
            device_name = device.name ?? device.address;
        } catch (IOError e) {
            icon = "settings-bluetooth-symbolic";
            critical (e.message);
        }

        switch (auth_type) {
        case AuthType.REQUEST_CONFIRMATION:
            info = _("See if the code displayed on “%s” matches below.").printf (device_name);

            var confirm_button = new He.Button (null, _("Pair")) {
                is_fill = true
            };
            primary_button = confirm_button;
            break;
        case AuthType.DISPLAY_PASSKEY:
            info = _("“%s” wants to pair with this device. See if the code displayed on “%s” matches below.")
                 .printf (device_name, device_name);

            var confirm_button = new He.Button (null, _("Pair")) {
                is_fill = true
            };
            primary_button = confirm_button;
            break;
        case AuthType.DISPLAY_PIN_CODE:
            info = _("Type the code displayed below on “%s”, followed by Enter.").printf (device_name);
            break;
        case AuthType.REQUEST_AUTHORIZATION:
            info = _("“%s” wants to pair with this device.").printf (device_name);

            var confirm_button = new He.Button (null, _("Pair")) {
                is_fill = true
            };
            primary_button = confirm_button;
            break;
        }

        if (passkey != null && passkey != "") {
            var passkey_label = new Gtk.Label (passkey);
            passkey_label.add_css_class ("display");
            add (passkey_label);
        }
    }
}
