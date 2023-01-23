use fusebox::subclass::prelude::FuseImpl;
use glib::{subclass::prelude::*, Cast};
use gtk4::{prelude::*, Align, Grid};
use gtk4::{Label, Widget};
use libflatpak::traits::InstallationExt;
use libhelium::traits::AppBarExt;
use libhelium::*;
use gettextrs::*;

// This is fucking ugly.
// Why is GLib with Rust so fucking ugly?
// I need to write a macro to make this easier.

pub struct AppsFuse {
    widget: Widget,
}

impl Default for AppsFuse {
    fn default() -> Self {
        let main_grid = Grid::builder()
            .margin_start(18)
            .margin_end(18)
            .row_spacing(12)
            .build();

        let app_bar = AppBar::builder()
            .show_back(false)
            .halign(Align::Fill)
            .hexpand(true)
            .build();

        app_bar.add_css_class("flat");
        let view_label = Label::builder()
            .label(&gettext("Applications"))
            .css_classes(vec!["view-title".to_string()])
            .halign(Align::Start)
            .build();

        app_bar.set_viewtitle_widget(Some(&view_label));

        main_grid.attach(&app_bar, 0, 0, 1, 1);

        let hello_label = Label::builder()
            .label("Hello from Rust!")
            .halign(Align::Start)
            .build();

        main_grid.attach(&hello_label, 0, 1, 1, 1);


        // libflatpak stuff

        // let fl = libflatpak::Instance::all();
        // for f in fl {
        //     println!("Flatpak: {:#?}", f);
        // }

        // let inst = libflatpak::functions::system_installations(gio::Cancellable::NONE).unwrap();
        // for i in inst {
        //     println!("Installation: {:#?}", i);
        //     for r in i.list_installed_refs(gio::Cancellable::NONE).unwrap() {
        //         println!("Ref: {:#?}", r.list_properties());
        //     }
        // }

        // get all flatpak apps
        let apps = libflatpak::functions::system_installations(gio::Cancellable::NONE).unwrap()[0].list_installed_refs(gio::Cancellable::NONE).unwrap();
        for r in apps {
            println!("Ref: {:#?}", r.property::<String>("name"));
        }

        Self {
            widget: main_grid.upcast(),
        }
    }
}

#[glib::object_subclass]
impl ObjectSubclass for AppsFuse {
    const NAME: &'static str = "AppsFuse";
    type Type = super::AppsFuse;
    type ParentType = fusebox::Fuse;
}

impl ObjectImpl for AppsFuse {}

impl FuseImpl for AppsFuse {
    fn get_widget(&self) -> Widget {
        self.widget.clone()
    }

    fn shown(&self) {
        println!("Sample fuse shown!");
    }

    fn hidden(&self) {
        println!("Sample fuse hidden!");
    }
}
