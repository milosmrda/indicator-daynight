/*
 * Copyright (c) 2019 mazen ()
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
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
 * Authored by: mazen <mmaz999@outlook.com>
 */

public class Daynight.Indicator : Wingpanel.Indicator {
    private Gtk.Grid main_grid;
    private Gtk.Image display_icon;
    private GLib.KeyFile keyfile;
    private string path;
    private Wingpanel.Widgets.Switch toggle_switch;
    Gtk.ModelButton restart_button;



    public Indicator () {
        Object (
            code_name: "Daynight",
            display_name: _("indicator-daynight"),
            description:_("A wingpanel indicator to toggle 'prefer dark variant' option in Elementary OS.")
        );
    }

    construct {
        //accessing the settings.ini file
        keyfile = new GLib.KeyFile ();

        try {
            path = GLib.Environment.get_user_config_dir() + "/gtk-3.0/settings.ini";
            keyfile.load_from_file (path, 0);
        }
        catch (Error e) {
            warning ("Error loading GTK+ Keyfile settings.ini: " + e.message);
        }

        var indicator_logo = "display-brightness-symbolic";
        var is_dark = get_integer("gtk-application-prefer-dark-theme");

        toggle_switch = new Wingpanel.Widgets.Switch ("Prefer dark variant");

        if(is_dark == 1) {
            toggle_switch.set_active(true);
            indicator_logo = "weather-clear-night-symbolic";
        } else {
            toggle_switch.set_active(false);
        }

        display_icon = new Gtk.Image.from_icon_name (indicator_logo, Gtk.IconSize.LARGE_TOOLBAR);

        restart_button = new Gtk.ModelButton();
        restart_button.text = "Restart dock and panel";

        main_grid = new Gtk.Grid();
        main_grid.attach(toggle_switch, 0, 0);
        main_grid.attach(new Wingpanel.Widgets.Separator (), 0, 1);
        main_grid.attach(restart_button, 0, 2);

        this.visible = true;

        connect_signals();
    }

    private void connect_signals() {
        toggle_switch.notify["active"].connect (() => {
            display_icon.set_from_icon_name (toggle_switch.active ? "weather-clear-night-symbolic" : "display-brightness-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            if(toggle_switch.active){
                set_integer("gtk-application-prefer-dark-theme", 1);
            } else {
                set_integer("gtk-application-prefer-dark-theme", 0);
            }
        });

        restart_button.clicked.connect(() => {
            Posix.system("pkill wingpanel && pkill plank");
        });
    }
    //function to get value from settings.ini
    private int get_integer (string key) {
        int key_int = 0;

        try {
            key_int = keyfile.get_integer ("Settings", key);
        }
        catch (Error e) {
            warning ("Error getting GTK+ int setting: " + e.message);
        }

        return key_int;
    }
    //function to set value into settings.ini
    private void set_integer (string key, int val) {
        keyfile.set_integer ("Settings", key, val);

        save_keyfile ();
    }

    private void save_keyfile () {
        try {
            string data = keyfile.to_data();
            GLib.FileUtils.set_contents(path, data);
        }
        catch (GLib.FileError e) {
            warning ("Error saving GTK+ Keyfile settings.ini: " + e.message);
        }
    }

    public override Gtk.Widget get_display_widget () {
        return display_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
            main_grid.set_orientation (Gtk.Orientation.VERTICAL);
            
            main_grid.show_all ();
        }

        return main_grid;
    }

    public override void opened () { }

    public override void closed () { }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    // Temporal workarround for Greeter crash
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }
    debug ("Activating daynight widget");
    var indicator = new Daynight.Indicator ();
    return indicator;
}