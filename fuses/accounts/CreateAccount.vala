class Accounts.CreateAccount : He.Window {
  private static Regex username_regex;

  static construct {
    try {
      username_regex = new Regex ("^[a-z0-9]*$");
    } catch (Error e) {
      critical ("Failed to compile regex: %s", e.message);
    }
  }

  private string username = "";
  private string real_name = "";
  private bool administator = false;
  private string? icon_file = null;
  private string password = "";
  private string password_confirm = "";


  bool fields_changed () {
    return this.username != "" &&
           username_regex.match (this.username) &&
           this.real_name != "" &&
           this.password != "" &&
           this.password_confirm != "" &&
           this.password == this.password_confirm;
  }

  public CreateAccount (He.ApplicationWindow parent) {
    this.parent = parent;
    this.modal = true;
    this.resizable = false;

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
      margin_bottom = 24,
      margin_top = 24,
      margin_start = 24,
      margin_end = 24,
    };

    var avatar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      margin_bottom = 12,
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.CENTER,
    };
    main_box.append (avatar_box);

    var avatar = new He.Avatar (96, null, "New User");
    var avatar_edit_button = new He.DisclosureButton ("document-edit-symbolic") {
      valign = Gtk.Align.END,
      halign = Gtk.Align.END,
    };

    var avatar_overlay = new Gtk.Overlay () {
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.CENTER,
    };
    avatar_overlay.set_child (avatar);
    avatar_overlay.add_overlay (avatar_edit_button);
    avatar_box.append (avatar_overlay);

    var title = new Gtk.Label ("New User") {
      halign = Gtk.Align.CENTER,
    };
    title.add_css_class ("large-title");
    avatar_box.append (title);

    var username_block = new He.MiniContentBlock () {
      title = "Username",
    };
    main_box.append (username_block);

    var username_entry = new He.TextField.from_regex (username_regex);
    username_entry.set_parent (username_block);
    username_entry.placeholder_text = "efuentes";
    username_entry.min_length = 1;
    username_entry.max_length = 32;
    username_entry.needs_validation = true;
    username_entry.support_text = (_("4—32 non-capitalized letters/numbers."));

    var name_block = new He.MiniContentBlock () {
      title = "Name",
    };
    main_box.append (name_block);

    var name_entry = new He.TextField () {
    };
    name_entry.set_parent (name_block);
    name_entry.placeholder_text = "Emily Fuentes";

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main_box.append (password_block);

    var password_entry = new He.TextField ();
    password_entry.set_parent (password_block);
    password_entry.visibility = false;
    password_entry.placeholder_text = "••••••••";

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main_box.append (password_confirm_block);

    var password_confirm_entry = new He.TextField ();
    password_confirm_entry.visibility = false;
    password_confirm_entry.placeholder_text = "••••••••";
    password_confirm_entry.set_parent (password_confirm_block);

    var administrator_block = new He.MiniContentBlock () {
      title = "Administrator",
      subtitle = "An administrator account can act on \nsystem sensitive settings."
    };
    administrator_block.add_css_class ("text-meson-red");
    main_box.append (administrator_block);

    var administrator_switch = new Gtk.Switch () {
      valign = Gtk.Align.CENTER,
    };
    administrator_switch.add_css_class ("bg-meson-red");
    administrator_switch.set_parent (administrator_block);

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
      margin_top = 12,
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
    };
    main_box.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.set_size_request (200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Create Account")) {
      sensitive = false,
    };
    apply_button.clicked.connect (() => {
      create_user (
                   this.username,
                   this.real_name,
                   this.password,
                   this.administator ? Act.UserAccountType.ADMINISTRATOR : Act.UserAccountType.STANDARD,
                   this.icon_file
      );
      this.destroy ();
    });
    apply_button.set_size_request (200, -1);
    button_box.append (apply_button);

    var winhandle = new Gtk.WindowHandle ();
    winhandle.set_child (main_box);

    this.set_child (winhandle);
    this.add_css_class ("dialog-content");

    username_entry.get_entry ().changed.connect (() => {
      this.username = username_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    name_entry.get_entry ().changed.connect (() => {
      this.real_name = name_entry.text;
      title.set_text (this.real_name);
      apply_button.sensitive = this.fields_changed ();
    });

    password_confirm_entry.notify["is-valid"].connect (() => {
      this.password_confirm = password_confirm_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    administrator_switch.notify["active"].connect (() => {
      this.administator = administrator_switch.active;
      apply_button.sensitive = this.fields_changed ();
    });

    avatar_edit_button.clicked.connect (() => {
      var dialog = new Gtk.FileChooserDialog (_("Select an image"),
                                              this,
                                              Gtk.FileChooserAction.OPEN,
                                              _("Cancel"),
                                              Gtk.ResponseType.CANCEL,
                                              _("Select"),
                                              Gtk.ResponseType.ACCEPT);
      dialog.set_transient_for (this);
      dialog.set_modal (true);
      dialog.set_select_multiple (false);

      var filter = new Gtk.FileFilter ();
      filter.add_pixbuf_formats ();
      dialog.add_filter (filter);

      dialog.present ();

      dialog.response.connect ((response) => {
        if (response == Gtk.ResponseType.ACCEPT) {
          var file = dialog.get_file ();
          avatar.image = file.get_uri ();
          this.icon_file = file.get_path ();
          apply_button.sensitive = this.fields_changed ();
        }

        dialog.destroy ();
      });
    });
  }
}