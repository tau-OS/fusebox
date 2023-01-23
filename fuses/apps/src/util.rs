use glib::{
    ffi::g_hash_table_get_type,
    gobject_ffi::{g_value_init, g_value_set_boxed, GValue},
    translate::{FromGlibPtrNone, ToGlibPtr},
    Value,
};

use std::{collections::HashMap, ffi::c_char, mem};

pub unsafe fn str_hashmap_to_glib_hashtable_value<'a, K, V>(hashmap: HashMap<K, V>) -> Value
where
    K: ToGlibPtr<'a, *mut c_char>,
    V: ToGlibPtr<'a, *mut c_char>,
{
    let hash_table = glib::ffi::g_hash_table_new(None, None);

    for (key, value) in hashmap {
        let key_ptr = key.to_glib_full();
        let value_ptr = value.to_glib_full();
        glib::ffi::g_hash_table_insert(
            hash_table,
            mem::transmute(key_ptr),
            mem::transmute(value_ptr),
        );
    }

    // TODO: Please have mercy on me god
    let mut boxed: GValue = mem::zeroed();
    g_value_init(&mut boxed as *mut _, g_hash_table_get_type());
    g_value_set_boxed(&mut boxed as *mut _, hash_table as *mut _);

    Value::from_glib_none(&boxed as *const _)
}
