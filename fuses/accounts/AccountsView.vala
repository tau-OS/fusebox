public class Accounts.AccountsView : Gtk.Box {
    private ListStore account_list = get_account_list_store ();

    construct {
        var users = Act.UserManager.get_default ().list_users ();

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var overlay_button = new He.OverlayButton ("list-add-symbolic", null, null);
        overlay_button.clicked.connect (() => {
            var dialog = new Accounts.CreateAccount (He.Misc.find_ancestor_of_type<He.ApplicationWindow>(this));
            dialog.present ();
        });
        mbox.append (overlay_button);

        var user_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        user_list.bind_model (this.account_list, (user) => {
            return new Accounts.AccountRow ((Act.User) user);
        });
        user_list.add_css_class ("content-list");
        overlay_button.child = user_list;

        var autologin_box = new He.MiniContentBlock () {
            title = _("Automatic Login"),
        };
        mbox.append (autologin_box);

        var autologin_actions_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        autologin_actions_box.set_parent (autologin_box);

        var autologin_dropdown = new Gtk.DropDown (this.account_list, new Gtk.PropertyExpression (typeof(Act.User), null, "user_name"));
        autologin_actions_box.append (autologin_dropdown);

        var autologin_switch = new Gtk.Switch ();
        autologin_actions_box.append (autologin_switch);

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);
        this.append (clamp);
        this.orientation = Gtk.Orientation.VERTICAL;
    }
}
