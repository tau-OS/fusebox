//  public class DockView : Gtk.Box {
//      private static GLib.Settings dock_settings;
//      private Gtk.ToggleButton dock_size_small_check;
//      private Gtk.ToggleButton dock_size_medium_check;
//      private Gtk.ToggleButton dock_size_big_check;
//      private Gtk.CheckButton dock_pos_left_check;
//      private Gtk.CheckButton dock_pos_middle_check;
//      private Gtk.CheckButton dock_pos_right_check;

//      public Fusebox.Fuse fuse { get; construct set; }

//      public DockView (Fusebox.Fuse _fuse) {
//          Object (fuse: _fuse);
//      }

//      static construct {
//          if (GLib.Environment.find_program_in_path ("kiri-panel") != null) {
//              dock_settings = new GLib.Settings ("com.fyralabs.kiri.panel.panel");
//          }
//      }

//      construct {
//          var dock_size_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
//          dock_size_box.add_css_class ("mini-content-block");

//          var dock_size_title = new Gtk.Label (_("Icon Size")) {
//              xalign = 0
//          };
//          dock_size_title.get_style_context ().add_class ("cb-title");

//          dock_size_small_check = new Gtk.ToggleButton ();
//          var dock_size_small_check_img = new Gtk.Image () {
//              pixel_size = 32,
//              icon_name = "application-default-icon-symbolic"
//          };
//          dock_size_small_check.child = dock_size_small_check_img;

//          dock_size_medium_check = new Gtk.ToggleButton () {
//              group = dock_size_small_check
//          };
//          var dock_size_medium_check_img = new Gtk.Image () {
//              pixel_size = 48,
//              icon_name = "application-default-icon-symbolic"
//          };
//          dock_size_medium_check.child = dock_size_medium_check_img;

//          dock_size_big_check = new Gtk.ToggleButton () {
//              group = dock_size_small_check
//          };
//          var dock_size_big_check_img = new Gtk.Image () {
//              pixel_size = 64,
//              icon_name = "application-default-icon-symbolic"
//          };
//          dock_size_big_check.child = dock_size_big_check_img;

//          var dock_size_box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
//              homogeneous = true
//          };
//          dock_size_box2.append (dock_size_small_check);
//          dock_size_box2.append (dock_size_medium_check);
//          dock_size_box2.append (dock_size_big_check);

//          dock_size_box.append (dock_size_title);
//          dock_size_box.append (dock_size_box2);

//          var dock_position_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
//          dock_position_box.add_css_class ("mini-content-block");
//          var dock_position_box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
//              halign = Gtk.Align.CENTER
//          };

//          dock_pos_left_check = new Gtk.CheckButton () {
//              label = ""
//          };
//          var dock_img = new Gtk.Image () {
//              pixel_size = 64,
//              icon_name = "dock-bottom-symbolic"
//          };
//          dock_pos_middle_check = new Gtk.CheckButton () {
//              group = dock_pos_left_check,
//              label = "",
//              halign = Gtk.Align.CENTER
//          };
//          dock_pos_right_check = new Gtk.CheckButton () {
//              group = dock_pos_left_check,
//              label = ""
//          };
//          dock_position_box2.append (dock_pos_left_check);
//          dock_position_box2.append (dock_img);
//          dock_position_box2.append (dock_pos_right_check);

//          var dock_position_title = new Gtk.Label (_("Screen Position")) {
//              xalign = 0
//          };
//          dock_position_title.get_style_context ().add_class ("cb-title");

//          dock_position_box.append (dock_position_title);
//          dock_position_box.append (dock_position_box2);
//          dock_position_box.append (dock_pos_middle_check);

//          var dock_autohide_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
//          dock_autohide_box.add_css_class ("mini-content-block");
//          var dock_autohide_box2 = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
//          var dock_autohide_title = new Gtk.Label (_("Intelligent Hiding")) {
//              xalign = 0
//          };
//          dock_autohide_title.get_style_context ().add_class ("cb-title");
//          var dock_autohide_subtitle = new Gtk.Label (_("Hide the dock when a window is close to it.")) {
//              xalign = 0
//          };
//          dock_autohide_subtitle.get_style_context ().add_class ("cb-subtitle");
//          dock_autohide_box2.append (dock_autohide_title);
//          dock_autohide_box2.append (dock_autohide_subtitle);
//          var dock_autohide_switch = new Gtk.Switch () {
//              valign = Gtk.Align.CENTER,
//              halign = Gtk.Align.END,
//              hexpand = true
//          };
//          dock_autohide_box.append (dock_autohide_box2);
//          dock_autohide_box.append (dock_autohide_switch);

//          var dock_panel_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
//          dock_panel_box.add_css_class ("mini-content-block");
//          var dock_panel_box2 = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
//          var dock_panel_title = new Gtk.Label (_("Panel Mode")) {
//              xalign = 0
//          };
//          dock_panel_title.get_style_context ().add_class ("cb-title");
//          var dock_panel_subtitle = new Gtk.Label (_("Extend the dock to the screen borders.")) {
//              xalign = 0
//          };
//          dock_panel_subtitle.get_style_context ().add_class ("cb-subtitle");
//          dock_panel_box2.append (dock_panel_title);
//          dock_panel_box2.append (dock_panel_subtitle);
//          var dock_panel_switch = new Gtk.Switch () {
//              valign = Gtk.Align.CENTER,
//              halign = Gtk.Align.END,
//              hexpand = true
//          };
//          dock_panel_box.append (dock_panel_box2);
//          dock_panel_box.append (dock_panel_switch);

//          var grid = new Gtk.Grid () {
//              row_spacing = 6,
//              margin_start = 18,
//              margin_end = 18,
//              margin_bottom = 18
//          };
//          grid.attach (dock_size_box, 0, 0);
//          grid.attach (dock_position_box, 0, 1);
//          grid.attach (dock_autohide_box, 0, 2);
//          grid.attach (dock_panel_box, 0, 3);

//          var clamp = new Bis.Latch ();
//          clamp.set_child (grid);

//          append (clamp);

//          if (GLib.Environment.find_program_in_path ("kiri-panel") != null) {
//              dock_size_small_check.toggled.connect (() => {
//                  dock_settings.set_int ("size", 32);
//              });
//              dock_size_medium_check.toggled.connect (() => {
//                  dock_settings.set_int ("size", 48);
//              });
//              dock_size_big_check.toggled.connect (() => {
//                  dock_settings.set_int ("size", 64);
//              });
//              dock_size_refresh ();
//              dock_settings.notify["changed::size"].connect (() => {
//                  dock_size_refresh ();
//              });
    
//              dock_pos_left_check.toggled.connect (() => {
//                  dock_settings.set_enum ("location", 8);
//                  dock_img.icon_name = "dock-left-symbolic";
//              });
//              dock_pos_middle_check.toggled.connect (() => {
//                  dock_settings.set_enum ("location", 2);
//                  dock_img.icon_name = "dock-bottom-symbolic";
//              });
//              dock_pos_right_check.toggled.connect (() => {
//                  dock_settings.set_enum ("location", 16);
//                  dock_img.icon_name = "dock-right-symbolic";
//              });
//              dock_position_refresh ();
//              dock_settings.notify["changed::location"].connect (() => {
//                  dock_position_refresh ();
//              });
    
//              if (dock_autohide_switch.active) {
//                  dock_settings.set_enum ("autohide", 4);
//              } else {
//                  dock_settings.set_enum ("autohide", 4);
//              }
//              dock_autohide_switch.notify["active"].connect (() => {
//                  if (dock_autohide_switch.active) {
//                      dock_settings.set_enum ("autohide", 4);
//                  } else {
//                      dock_settings.set_enum ("autohide", 4);
//                  }
//              });
    
//              dock_settings.bind ("dock-mode", dock_panel_switch, "active", GLib.SettingsBindFlags.DEFAULT);
//          }
//      }

//      private void dock_position_refresh () {
//          if (GLib.Environment.find_program_in_path ("kiri-panel") != null) {
//              int value = dock_settings.get_enum ("location");
//              if (value == 16) {
//                  dock_pos_left_check.set_active (false);
//                  dock_pos_middle_check.set_active (false);
//                  dock_pos_right_check.set_active (true);
//              } else if (value == 2) {
//                  dock_pos_left_check.set_active (false);
//                  dock_pos_middle_check.set_active (true);
//                  dock_pos_right_check.set_active (false);
//              } else if (value == 8) {
//                  dock_pos_left_check.set_active (true);
//                  dock_pos_middle_check.set_active (false);
//                  dock_pos_right_check.set_active (false);
//              } else {
//                  dock_pos_left_check.set_active (false);
//                  dock_pos_middle_check.set_active (true);
//                  dock_pos_right_check.set_active (false);
//              }
//          }
//      }

//      private void dock_size_refresh () {
//          if (GLib.Environment.find_program_in_path ("kiri-panel") != null) {
//              int value = dock_settings.get_int ("size");
//              if (value == 32) {
//                  dock_size_small_check.set_active (true);
//                  dock_size_medium_check.set_active (false);
//                  dock_size_big_check.set_active (false);
//              } else if (value == 48) {
//                  dock_size_small_check.set_active (false);
//                  dock_size_medium_check.set_active (true);
//                  dock_size_big_check.set_active (false);
//              } else if (value == 64) {
//                  dock_size_small_check.set_active (false);
//                  dock_size_medium_check.set_active (false);
//                  dock_size_big_check.set_active (true);
//              } else {
//                  dock_size_small_check.set_active (false);
//                  dock_size_medium_check.set_active (true);
//                  dock_size_big_check.set_active (false);
//              }
//          }
//      }
//  }
