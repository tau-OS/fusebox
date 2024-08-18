/*-
 * Copyright (c) 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

public class Fusebox.FusesManager : GLib.Object {
    private static Fusebox.FusesManager? fuses_manager = null;

    public static FusesManager get_default () {
        if (fuses_manager == null)
            fuses_manager = new FusesManager ();
        return fuses_manager;
    }

    [CCode (has_target = false)]
    private delegate Fusebox.Fuse RegisterPluginFunction (Module module);

    private GLib.List<Fusebox.Fuse> fuses;

    public signal void fuse_added (Fusebox.Fuse fuse);

    private FusesManager () {
        fuses = new GLib.List<Fusebox.Fuse> ();
        var fuses_dir_env = Environment.get_variable ("FUSES_DIR");
        var base_folder = File.new_for_path (fuses_dir_env ?? Build.FUSES_DIR);
        find_fuseins (base_folder);
    }

    private void load (string path) {
        if (Module.supported () == false) {
            error ("Fusebox is not supported by this system!");
        }

        Module module = Module.open (path, ModuleFlags.LAZY);
        if (module == null) {
            critical (Module.error ());
            return;
        }

        void* function;
        module.symbol ("get_fuse", out function);
        if (function == null) {
            critical ("get_fuse () not found in %s", path);
            return;
        }

        RegisterPluginFunction register_fusein = (RegisterPluginFunction) function;
        Fusebox.Fuse fuse = register_fusein (module);
        if (fuse == null) {
            critical ("Unknown fusein type for %s !", path);
            return;
        }
        module.make_resident ();
        register_fuse (fuse);
    }

    private void find_fuseins (File base_folder) {
        FileInfo file_info = null;
        try {
            var enumerator = base_folder.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE + "," + FileAttribute.STANDARD_CONTENT_TYPE, 0);
            while ((file_info = enumerator.next_file ()) != null) {
                var file = base_folder.get_child (file_info.get_name ());

                if (file_info.get_file_type () == FileType.REGULAR && GLib.ContentType.equals (file_info.get_content_type (), "application/x-sharedlib")) {
                    var path = file.get_path ();
                    if (path.has_suffix (Module.SUFFIX)) {
                        load (path);
                    }
                } else if (file_info.get_file_type () == FileType.DIRECTORY) {
                    find_fuseins (file);
                }
            }
        } catch (Error err) {
            warning ("Unable to scan fuses folder %s: %s\n", base_folder.get_path (), err.message);
        }
    }

    private void register_fuse (Fusebox.Fuse fuse) {
        debug ("%s registered", fuse.code_name);
        if (fuses.find (fuse) != null) {
            return;
        }

        fuses.append (fuse);
        fuse_added (fuse);
    }

    public bool has_fuses () {
        return fuses.length () != 0;
    }

    public unowned GLib.List<Fusebox.Fuse> get_fuses () {
        return fuses;
    }
}
