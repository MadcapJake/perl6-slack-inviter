unit class Badge;

use XML::Writer;

constant title = 'slack';
constant color = '#E01563';
constant pad   = 8; # left/right padding
constant sep   = 4; # middle separation

has $!total;
has $!active;
has $!value;
has %!w;

submethod BUILD (:$!total, :$!active) {
  $!value = $!active ?? "$!active/$!total" !! ( ~$!total // '-');
  %!w<left>  = pad + width( title ) + sep;
  %!w<right> = sep + width($!value) + pad;
  %!w<total> = %!w<left> + %!w<right>;
}

method Str {
=for string_approach
  my ($total, $left, $right) = (%!w<total>, %!w<left>, %!w<right>);
  qq:to/END/;
  <svg xmlns="http://www.w3.org/2000/svg" width="87" height="20">
  <rect rx="3" width="$total" height="20" fill="#555"></rect>
  <rect rx="3" x="$left" width="$right" height="20" fill="{color}"></rect>
  <path d="M$left 0h{sep}v20h-{sep}z" fill="{color}"></path>
  <rect rx="3" width="$total" height="20" fill="url(#g)"></rect>
  <g text-anchor="middle" font-family="Verdana" font-size="11">
    <text fill="#010101" fill-opacity=".3" x="{($left/2).round}" y="15">{title}</text>
    <text fill="#fff" x="{($left/2).round}" y="14">{title}</text>
    <text fill="#010101" fill-opacity=".3" x="{$left+($right/2).round}" y="15">{$!value}</text>
    <text fill="#fff" x="{$left+($right/2).round}" y="14">{$!value}</text>
  </g>
  </svg>
  END

  XML::Writer.serialize(svg => [
    :xmlns("http://www.w3.org/2000/svg"), :width(%!w<total>), :height(20),
    :rect[:rx(3), :width(%!w<total>), :height(20), :fill('#555')],
    :rect[:rx(3), :x(%!w<left>), :width(%!w<right>), :height(20), :fill(color)],
    :path[:d("M%!w<left> 0h{sep}v20h-{sep}z"), :fill(color)],
    :rect[:rx(3), :width(%!w<total>), :height(20), :fill('url(#g)')],
    :g[:text-anchor('middle'), :font-family('Verdana'), :font-size(11),
      |text(:str(title),   :x((%!w<left>/2).round), :y(14)),
      |text(:str($!value), :x(%!w<left> + (%!w<right>/2).round), :y(14))
    ]
  ])

}

# generate text with 1px shadow
sub text(:$str, :$x, :$y) {[
  :text[:fill('#010101'), :fill-opacity(0.3), :$x, :y($y + 1), $str],
  :text[:fill('#fff'), :$x, :$y, $str]
]}

sub width(Str $str) { 7 * $str.chars }
