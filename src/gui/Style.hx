package gui;

typedef Property = {
  var kind : Kind;
  var value : Dynamic;

}
enum Kind {
	Int;
	Float;
  String;
}

class Style {

  public function getWidth():Int {
    return height + padding*2 + margin*2;
  }
  public function getHeight():Int {
    return width + padding*2 + margin*2;
  }

    public var margin = 0;
    public var padding = 8;
    public var rounded = 8;
    public var elements_padding = 8;

    public var width = 0;
    public var height = 0;

    public var outline_size = 3;
    public var bevel = 3;

    public var background_color = 0xdddddd;
    public var over_background_color = 0xffffff;
    public var selected_background_color = 0xeeeeee;

    public var outline_color = 0xaaaaaa;
    public var over_outline_color = 0xffcf00;
    public var selected_outline_color = 0xcccccc;

    public function copy(style:Style) {
      this.width = style.width;
      this.height = style.height;
      this.margin = style.margin;
      this.padding = style.padding;
      this.rounded = style.rounded;
      this.elements_padding = style.elements_padding;
      this.outline_size = style.outline_size;
      this.background_color = style.background_color;
      this.over_background_color = style.over_background_color;
      this.selected_background_color = style.selected_background_color;
      this.outline_color = style.outline_color;
      this.over_outline_color = style.over_outline_color;
      this.selected_outline_color = style.selected_outline_color;
    }

    public static function button():Style {
      var style:Style = new Style();
      style.margin = 0;
      style.padding = 8;
      style.rounded = 8;

      style.width = 20;
      style.height = 20;

      style.outline_size = 3;
      style.bevel = 2;

      style.background_color = 0xdddddd;
      style.over_background_color = 0xeeeeee;
      style.selected_background_color = 0xdddddd;

      style.outline_color = 0xaaaaaa;
      style.over_outline_color = 0xffcf00;
      style.outline_color = 0xaaaaaa;

      return style;
    }
    public static function miniButton():Style {
      var style:Style = button();
      style.padding = 2;
      style.outline_size = 2;
      style.bevel = 1;
      return style;
    }

    public static function toolbarButton():Style {
      var style:Style = button();
      style.padding = 3;
      style.outline_size = 6;
      style.width = 20;
      style.height = 20;

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

    public static function box():Style {
      var style:Style = new Style();
      style.margin = 0;
      style.padding = 10;
      style.rounded = 8;

      style.outline_size = 2;
      style.background_color = 0x242424;
      style.outline_color = 0xbe8600;

      return style;
    }

}
