class Locale.Preview : He.ContentList {
  public LocaleModel locale { get; set; }

  public Preview (LocaleModel locale) {
    base ();
    this.locale = locale;

    this.title = "Preview";

    var example = get_examples_for_locale(this.locale);

    var time_label = new Gtk.Label(example.time);
    var date_label = new Gtk.Label(example.date);
    var money_label = new Gtk.Label(example.money);
    var temperature_label = new Gtk.Label(example.temperature);

    var time_block = new He.MiniContentBlock() {
      title = "Time",
      child = time_label
    };
    this.add (time_block);

    var date_block = new He.MiniContentBlock() {
      title = "Date",
      child = date_label
    };
    this.add (date_block);

    var money_block = new He.MiniContentBlock() {
      title = "Money",
      child = money_label
    };
    this.add (money_block);

    var temperature_block = new He.MiniContentBlock() {
      title = "Temperature",
      child = temperature_label
    };
    this.add (temperature_block);
  }
}
