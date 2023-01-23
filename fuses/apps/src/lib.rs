#![allow(clippy::missing_safety_doc, clippy::new_without_default)]
use std::{collections::HashMap, ffi::c_void};

use fusebox::FuseCategory;
use glib::Object;
use util::str_hashmap_to_glib_hashtable_value;

mod imp;
mod util;

glib::wrapper! {
    pub struct AppsFuse(ObjectSubclass<imp::AppsFuse>)
        @extends fusebox::Fuse;
}

impl AppsFuse {
    pub fn new() -> Self {
        let supported_settings: HashMap<&str, Option<&str>> = HashMap::from([("wallpaper", None)]);

        Object::builder()
            .property("category", &FuseCategory::System)
            .property("code-name", &"apps-use")
            .property("display-name", &"Applications")
            .property("description", &"Manage applications")
            .property("icon", &"system-run")
            .property("supported-settings", &unsafe {
                str_hashmap_to_glib_hashtable_value(supported_settings)
            })
            .build()
    }
}

#[no_mangle]
pub unsafe extern "C" fn get_fuse(_: c_void) -> AppsFuse {
    println!("Activating Sample fuse from Rust!");
    gtk4::init().unwrap();
    AppsFuse::new()
}
