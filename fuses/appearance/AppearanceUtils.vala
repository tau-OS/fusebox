/*
* Copyright (c) 2021-2023 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace Appearance.Utils {
    public class Palette : Object {
        const double TARGET_DARK_LUMA = 0.40;
        const double MAX_DARK_LUMA = 0.60;
        const double MIN_LIGHT_LUMA = 0.60;
        const double TARGET_LIGHT_LUMA = 1;
        const double MIN_NORMAL_LUMA = 0.40;
        const double TARGET_NORMAL_LUMA = 0.60;
        const double MAX_NORMAL_LUMA = 1;
        const double TARGET_MUTED_SATURATION = 0.40;
        const double MAX_MUTED_SATURATION = 1;
        const double TARGET_VIBRANT_SATURATION = 1;
        const double MIN_VIBRANT_SATURATION = 0.60;
        const double WEIGHT_SATURATION = 0.60;
        const double WEIGHT_LUMA = 0.40;
        const double WEIGHT_POPULATION = 0.20;

        public class Swatch : Object {
            public float R = 0.0f;
            public float G = 0.0f;
            public float B = 0.0f;
            public float A = 0.0f;
            public int population { get; construct; }

            public Swatch (uint8 red, uint8 green, uint8 blue, int population) {
                Object (population: population);

                R = red / 255.0f;
                G = green / 255.0f;
                B = blue / 255.0f;
                A = 1.0f;

                this.red = red;
                this.green = green;
                this.blue = blue;
            }

            public uint8 red { get; set; }
            public uint8 green { get; set; }
            public uint8 blue { get; set; }

            public Swatch.from_rgb (int rgb) {
                red = (uint8)((rgb >> 16) & 0xFF);
                green = (uint8)((rgb >> 8) & 0xFF);
                blue = (uint8)(rgb & 0xFF);
            }

            public int to_rgb () {
                return (0xFF << 24) | (red << 16) | (green << 8) | blue;
            }

            public uint8 get_component (SwatchComponent component) {
                switch (component) {
                    case SwatchComponent.RED:
                        return red;
                    case SwatchComponent.GREEN:
                        return green;
                    case SwatchComponent.BLUE:
                        return blue;
                }

                return 0;
            }
        }

        public const uint8 MAX_QUALITY = 10;
        public const uint8 MIN_QUALITY = 10;
        public const uint8 DEFAULT_QUALITY = 10;
        public const uint16 MAX_COLORS = 128;
        public const uint16 DEFAULT_COLORS = 128;
        public const uint16 MIN_COLORS = 128;

        private Gee.List<Swatch> _swatches;
        public Gee.List<Swatch> swatches {
            owned get {
                return _swatches.read_only_view;
            }
        }

        public Swatch? vibrant_swatch { get; private set; }
        public Swatch? light_vibrant_swatch { get; private set; }
        public Swatch? dark_vibrant_swatch { get; private set; }
        public Swatch? muted_swatch { get; private set; }
        public Swatch? light_muted_swatch { get; private set; }
        public Swatch? dark_muted_swatch { get; private set; }
        public Swatch? dominant_swatch { get; private set; }
        public Swatch? title_swatch { get; private set; }
        public Swatch? body_swatch { get; private set; }

        private int max_population = 0;

        public Gdk.Pixbuf? pixbuf { get; construct set; }
        public string pixel_data { get; set; }

        private uint8 _quality = DEFAULT_QUALITY;
        public uint8 quality {
            get {
                return _quality;
            }

            construct set {
                _quality = value.clamp (MIN_QUALITY, MAX_QUALITY);
            }
        }

        private uint16 _max_colors = DEFAULT_COLORS;
        public uint16 max_colors {
            get {
                return _max_colors;
            }

            construct set {
                _max_colors = value.clamp (MIN_COLORS, MAX_COLORS);
            }
        }

        private Gee.HashMap<int, int> histogram;
        public bool has_alpha { get; construct set; }

        public enum SwatchComponent {
            RED,
            GREEN,
            BLUE
        }

        construct {
            histogram = new Gee.HashMap<int, int> ();
        }

        public Palette () {

        }

        public Palette.from_pixbuf (Gdk.Pixbuf pixbuf, uint16 max_colors = DEFAULT_COLORS, uint8 quality = DEFAULT_QUALITY) {
            Object (pixbuf: pixbuf, max_colors: max_colors, quality: quality);
        }

        public Palette.from_data (owned string pixels, bool has_alpha, uint16 max_colors = DEFAULT_COLORS, uint8 quality = DEFAULT_QUALITY) {
            this.pixel_data = pixels;
            Object (has_alpha: has_alpha, max_colors: max_colors, quality: quality);
        }

        public async void generate_async () {
            Gee.List<Swatch> pixels;
            if (pixbuf != null) {
                pixels = convert_pixels_to_rgb (pixbuf.get_pixels_with_length (), pixbuf.has_alpha);
            } else {
                pixels = convert_pixels_to_rgb (pixel_data.data, has_alpha);
            }

            uint8 max_depth = (uint8)Math.log2 (max_colors);
            _swatches = yield quantize (pixels, 0, max_depth);
            _swatches.sort ((c1, c2) => {
                return c2.population - c1.population;
            });

            if (_swatches.size > 0) {
                dominant_swatch = _swatches[0];
            }

            max_population = int.MIN;
            foreach (var swatch in _swatches) {
                if (swatch.population > max_population) {
                    max_population = swatch.population;
                }
            }

            create_swatch_targets ();
        }

        public void generate_sync () {
            var loop = new MainLoop ();
            generate_async.begin (() => loop.quit ());
            loop.run ();
        }

        private Gee.ArrayList<Swatch> convert_pixels_to_rgb (uint8[] pixels, bool has_alpha) {
            var list = new Gee.ArrayList<Swatch> ();

            int factor;
            if (has_alpha) {
                factor = 4;
            } else {
                factor = 3;
            }

            int i = 0;
            int inc = MAX_QUALITY + MIN_QUALITY - quality;

            int count = pixels.length / factor;
            while (i < count) {
                int offset = i * factor;
                uint8 red = pixels[offset];
                uint8 green = pixels[offset + 1];
                uint8 blue = pixels[offset + 2];

                var color = new Swatch (red, green, blue, 0);
                int rgb = color.to_rgb ();
                if (histogram.has_key (rgb)) {
                    histogram[rgb] = histogram[rgb] + 1;
                } else {
                    histogram[rgb] = 1;
                }

                i += inc;
            }

            histogram.@foreach ((entry) => {
                var color = entry.key;
                list.add (new Swatch.from_rgb (color));
                return true;
            });

            return list;
        }


        private SwatchComponent find_biggest_range (Gee.List<Swatch> pixels) {
            int r_min = int.MIN;
            int r_max = int.MAX;
            int g_min = int.MIN;
            int g_max = int.MAX;
            int b_min = int.MIN;
            int b_max = int.MAX;

            foreach (var pixel in pixels) {
                r_min = int.min (r_min, pixel.red);
                r_max = int.max (r_max, pixel.red);
                g_min = int.min (g_min, pixel.green);
                g_max = int.max (g_max, pixel.green);
                b_min = int.min (b_min, pixel.blue);
                b_max = int.max (b_max, pixel.blue);
            }

            int r_range = r_max - r_min;
            int g_range = g_max - g_min;
            int b_range = b_max - b_min;

            if (r_range >= g_range && r_range >= b_range) {
                return SwatchComponent.RED;
            } else if (g_range >= r_range && g_range >= b_range) {
                return SwatchComponent.GREEN;
            } else {
                return SwatchComponent.BLUE;
            }
        }

        private async Gee.List<Swatch> quantize (Gee.List<Swatch> pixels, uint8 depth = 0, uint8 max_depth = 32) {
            if (depth == max_depth) {
                int r = 0, g = 0, b = 0;
                int population = 0;

                int red_sum = 0;
                int green_sum = 0;
                int blue_sum = 0;

                foreach (var pixel in pixels) {
                    int color_pop = histogram[pixel.to_rgb ()];

                    red_sum += color_pop * pixel.red;
                    green_sum += color_pop * pixel.green;
                    blue_sum += color_pop * pixel.blue;

                    population += color_pop;
                }

                r = (int)Math.round (red_sum / (float)population);
                g = (int)Math.round (green_sum / (float)population);
                b = (int)Math.round (blue_sum / (float)population);

                var color = new Swatch ((uint8)r, (uint8)g, (uint8)b, population);

                var list = new Gee.ArrayList<Swatch> ();
                list.add (color);
                return list;
            }

            SwatchComponent component = find_biggest_range (pixels);
            pixels.sort ((c1, c2) => {
                return c1.get_component (component) - c2.get_component (component);
            });

            int mid = pixels.size / 2;

            var swatches = new Gee.ArrayList<Swatch> ();

            var first = yield quantize (pixels.slice (0, mid), depth + 1, max_depth);
            swatches.add_all (first);

            if (mid + 1 < pixels.size - 1) {
                var second = yield quantize (pixels.slice (mid + 1, pixels.size - 1), depth + 1, max_depth);
                swatches.add_all (second);
            }

            return swatches;
        }

        private void create_swatch_targets () {
            vibrant_swatch = find_color_variation (TARGET_NORMAL_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
            light_vibrant_swatch = find_color_variation (TARGET_LIGHT_LUMA, MIN_LIGHT_LUMA, 1, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
            dark_vibrant_swatch = find_color_variation (TARGET_DARK_LUMA, 0, MAX_DARK_LUMA, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
            muted_swatch = find_color_variation (TARGET_NORMAL_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_MUTED_SATURATION, 0, MAX_MUTED_SATURATION);
            light_muted_swatch = find_color_variation (TARGET_LIGHT_LUMA, MIN_LIGHT_LUMA, 1, TARGET_MUTED_SATURATION, 0, MAX_MUTED_SATURATION);
            dark_muted_swatch = find_color_variation (0.5, 0, 1, 0.5, 0, 0.66);
            body_swatch = find_color_variation (TARGET_LIGHT_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, MAX_MUTED_SATURATION);
            dominant_swatch = find_color_variation (TARGET_NORMAL_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_MUTED_SATURATION, MIN_VIBRANT_SATURATION, TARGET_VIBRANT_SATURATION);
        }

        private static double get_saturation (Swatch color) {
            double max = double.MAX;
            if (color.R > color.G && color.R > color.B) {
                max = color.R;
            } else if (color.G > color.R && color.G > color.B) {
                max = color.G;
            } else {
                max = color.B;
            }

            double min = double.MIN;
            if (color.R < color.G && color.R < color.B) {
                min = color.R;
            } else if (color.G < color.R && color.G < color.B) {
                min = color.G;
            } else {
                min = color.B;
            }

            double s = 0;
            double l = (max + min) / 2;
            double chroma = max - min;
            if (chroma == 0) {
                s = 0;
            } else {
                if (l <= 0.5) {
                    s = chroma / (2 * l);
                } else {
                    s = chroma / (2 - 2 *l);
                }
            }

            return s;
        }

        private static double get_luminance (Swatch color) {
            double max = double.MAX;
            if (color.R > color.G && color.R > color.B) {
                max = color.R;
            } else if (color.G > color.R && color.G > color.B) {
                max = color.G;
            } else {
                max = color.B;
            }

            double min = double.MIN;
            if (color.R < color.G && color.R < color.B) {
                min = color.R;
            } else if (color.G < color.R && color.G < color.B) {
                min = color.G;
            } else {
                min = color.B;
            }

            return (max + min) / 2;
        }

        private Swatch? find_color_variation (double target_luma,
                                            double min_luma,
                                            double max_luma,
                                            double target_saturation,
                                            double min_saturation,
                                            double max_saturation) {
            Swatch? max = null;
            double max_value = double.MIN;
            foreach (var swatch in _swatches) {
                double sat = get_saturation (swatch);
                double luma = get_luminance (swatch);
                if (sat >= min_saturation && sat <= max_saturation && luma >= min_luma && luma <= max_luma && !is_already_selected_color (swatch)) {
                    double value = create_comparison_value (sat, target_saturation, luma, target_luma, swatch.population, max_population);
                    if (max == null || value > max_value) {
                        max = swatch;
                        max_value = value;
                    }
                }
            }

            return max;
        }

        private static double create_comparison_value (double saturation,
                                                double target_saturation,
                                                double luma,
                                                double target_luma,
                                                double population,
                                                double max_population) {
            double[] vals = new double[6];
            vals[0] = invert_diff (saturation, target_saturation);
            vals[1] = WEIGHT_SATURATION;
            vals[2] = invert_diff (luma, target_luma);
            vals[3] = WEIGHT_LUMA;
            vals[4] = population / max_population;
            vals[5] = WEIGHT_POPULATION;

            return weighted_mean (vals);
        }

        private bool is_already_selected_color (Swatch swatch) {
            return swatch == vibrant_swatch || swatch == light_vibrant_swatch ||
                swatch == dark_vibrant_swatch || swatch == muted_swatch || swatch == light_muted_swatch || swatch == dark_muted_swatch;
        }

        private static double invert_diff (double value, double target_value) {
            return 1.0f - Math.fabs (value - target_value);
        }

        private static double weighted_mean (double[] values) {
            double score = 0.0;
            for (int i = 0; i < values.length; i += 2) {
                score += values[i] * values[i + 1];
            }

            return score;
        }
    }
}