package gui;

class Style {

    public var margin = 0;
    public var padding = 8;
    public var rounded = 8;

    public var outline_size = 3;

    public var background_color = 0xdddddd;
    public var over_background_color = 0xffffff;
    public var selected_background_color = 0xeeeeee;

    public var outline_color = 0xaaaaaa;
    public var over_outline_color = 0xffcf00;
    public var selected_outline_color = 0xcccccc;

    public function new() {
      //nothing
    }

    public static function button():Style {
      var style:Style = new Style();
      style.margin = 0;
      style.padding = 8;
      style.rounded = 8;

      style.outline_size = 3;

      style.background_color = 0xdddddd;
      style.over_background_color = 0xeeeeee;
      style.selected_background_color = 0xdddddd;

      style.outline_color = 0xaaaaaa;
      style.over_outline_color = 0xffcf00;
      style.outline_color = 0xaaaaaa;

      return style;
    }

    public static function toolbarButton():Style {
      var style:Style = button();
      style.padding = 3;
      style.outline_size = 6;

      style.outline_color = 0x242424;
      style.over_outline_color = 0xffd97d;
      style.selected_outline_color = 0xffb500;

      return style;
    }

    public static function toolbarButtonFull():Style {
      var style:Style = toolbarButton();
      style.padding = 0;
      style.background_color = style.outline_color;
      style.over_background_color = style.over_outline_color ;
      style.selected_background_color = style.selected_outline_color;
      return style;
    }

    public static function toolbar():Style {
      var style:Style = new Style();
      style.margin = 0;
      style.padding = 1;
      style.rounded = 8;

      style.outline_size = 0;
      style.background_color = 0xdddddd;

      return style;
    }

}
