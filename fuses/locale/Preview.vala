class Locale.Preview : He.ContentList {
  public LocaleModel locale { get; set; }

  construct {
    this.title = "Preview";

    var example = get_examples_for_locale(this.locale);

    var time_block = new He.MiniContentBlock() {
      title = "Time",
    };
    this.add (time_block);

    var date_block = new He.MiniContentBlock() {
      title = "Date",
    };
    this.add (date_block);

    var currency_block = new He.MiniContentBlock() {
      title = "Currency",
      subtitle = example.currency,
    };
    this.add (currency_block);

    var temperature_block = new He.MiniContentBlock() {
      title = "Temperature",
    };
    this.add (temperature_block);

    this.notify["locale"].connect (() => {
      if (this.locale == null) {
        return;
      }

      var examples = get_examples_for_locale(this.locale);

      time_block.subtitle = examples.time;
      date_block.subtitle = examples.date;
      currency_block.subtitle = examples.currency;
      temperature_block.subtitle = examples.temperature;
    });
  }
}
