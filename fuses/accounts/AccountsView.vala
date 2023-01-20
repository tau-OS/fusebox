public class Accounts.AccountsView : Gtk.Box {
    private ListStore account_list = get_account_list_store ();

    construct {
        var users = Act.UserManager.get_default ().list_users ();

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var overlay_button = new He.OverlayButton ("list-add-symbolic", null, null);
        mbox.append (overlay_button);

        var user_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        user_list.bind_model (this.account_list, (user) => {
            return new Accounts.AccountRow ((Act.User) user);
        });
        user_list.add_css_class ("content-list");
        overlay_button.child = user_list;

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);
        this.append (clamp);
        this.orientation = Gtk.Orientation.VERTICAL;
    }
}
