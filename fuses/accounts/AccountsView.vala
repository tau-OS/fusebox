public class Accounts.AccountsView : Gtk.Box {
    private ListStore account_list = get_account_list_store ();

    construct {
        var user_manager = Act.UserManager.get_default ();
        var users = user_manager.list_users ();

        var overlay_button = new He.OverlayButton ("list-add-symbolic", null, null) {
            typeb = PRIMARY
        };
        overlay_button.clicked.connect (() => {
            var dialog = new Accounts.CreateAccount (He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this));
            dialog.present ();
        });

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        overlay_button.child = mbox;

        var user_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        user_list.bind_model (this.account_list, (user) => {
            return new Accounts.AccountRow ((Act.User) user);
        });
        user_list.add_css_class ("content-list");
        mbox.append (user_list);

        var autologin_box = new He.MiniContentBlock () {
            title = _("Automatic Login")
        };
        mbox.append (autologin_box);

        var autologin_actions_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        autologin_actions_box.set_parent (autologin_box);

        Act.User? inital_autologin_user = null;
        foreach (var user in users) {
            if (user.automatic_login) {
                inital_autologin_user = user;
                break;
            }
        }

        var autologin_dropdown = new Gtk.DropDown (this.account_list,
                                                   new Gtk.PropertyExpression (typeof (Act.User),
                                                                               null,
                                                                               "real_name"
                                                   )
        )
        {
            valign = Gtk.Align.CENTER
        };
        autologin_actions_box.append (autologin_dropdown);

        if (inital_autologin_user != null) {
            autologin_dropdown.selected = users.index (inital_autologin_user);
        }

        var autologin_switch = new He.Switch () {
            valign = Gtk.Align.CENTER
        };
        autologin_switch.iswitch.active = inital_autologin_user != null;
        autologin_actions_box.append (autologin_switch);

        // TODO If the user cancels, we need to reset the switch to the previous state.. since it seems like it doesn't throw an error, this isn't straightforward

        autologin_dropdown.notify["selected-item"].connect (() => {
            var user = (Act.User) autologin_dropdown.selected_item;
            if (user != null && autologin_switch.iswitch.active) {
                user.set_automatic_login (true);
            }
        });

        autologin_switch.iswitch.notify["active"].connect (() => {
            var user = (Act.User) autologin_dropdown.selected_item;
            if (user != null) {
                user.set_automatic_login (autologin_switch.iswitch.active);
            }
        });

        var clamp = new Bis.Latch ();
        clamp.set_child (overlay_button);
        this.append (clamp);
        this.orientation = Gtk.Orientation.VERTICAL;
    }
}
