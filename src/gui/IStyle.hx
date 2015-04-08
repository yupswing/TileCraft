package gui;

interface IStyle {
  private var _style:Style;
  public var style(get,set):Style;
  private function get_style():Style;
  private function set_style(value:Style):Style;
}
