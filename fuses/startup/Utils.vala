/*-
 * Copyright (c) 2023 Fyra Labs
 * Copyright (c) 2015-2016 elementary LLC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace Startup.Utils {
    private const string AUTOSTART_DIR = "autostart";
    public string get_autostart_dir () {
        var config_dir = Environment.get_user_config_dir ();
        var startup_dir = Path.build_filename (config_dir, AUTOSTART_DIR);

        if (FileUtils.test (startup_dir, FileTest.EXISTS) == false) {
            var file = File.new_for_path (startup_dir);

            try {
                file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        return startup_dir;
    }

    public bool is_desktop_file (string name) {
        return !name.contains ("~") && name.has_suffix (".desktop");
    }

    public string[] get_autostart_files () {
        var startup_dir = Utils.get_autostart_dir ();
        var enumerator = new Backend.DesktopFileEnumerator ({ startup_dir });
        return enumerator.get_desktop_files ();
    }
}