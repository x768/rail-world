# charset: UTF-8


FONT_W = 6
FONT_H = 12
LINE_H = 13
STEP = 12
CIRCLE_R = 4

#----------------------------------------------

def get_length(s)
  len = 0
  s.each_codepoint do |c|
    if c < 0x3000
      len += 7
    else
      len += 12
    end
  end
  return len
end

# 駅名
def draw_stations(out, stn, stn_link)
  # 乗り換え
  for a in stn_link
    out.print '<path class="stn-link" d="M', a[0], ',', a[1], ' L', a[2], ',', a[3], '"/>', "\n"
  end
  for a in stn
    base = FONT_H / 2 - 1
    name = a[3]
    name = name.gsub('_', ' ')

    case a[0]
    when 'box'
      width = get_length(name) + 4
      out.print '<rect class="stn" x="', a[1] - width / 2, '" y="', a[2] - LINE_H / 2 - 1, '" width="', width, '" height="', LINE_H + 2, '"/>', "\n"
      out.print '<text class="stn-name" text-anchor="middle" x="', a[1], '" y="', a[2] + base, '" title="', (a[1] / STEP) - OFFSET_X, ',', (a[2] / STEP) - OFFSET_Y, '">', name, '</text>', "\n"
    when 'lbox'
      width = a[4] * FONT_W + 4
      height = a[5] * LINE_H + 2
      out.print '<rect class="stn" x="', a[1] - width / 2, '" y="', a[2] - height / 2 - 1, '" width="', width, '" height="', height, '"/>', "\n"
      out.print '<text class="stn-name" text-anchor="middle" x="', a[1], '" y="', a[2] + base, '" title="', (a[1] / STEP) - OFFSET_X, ',', (a[2] / STEP) - OFFSET_Y, '">', name, '</text>', "\n"
    when 'uc'
      text_x = a[1]
      text_y = a[2] + base
      out.print '<circle class="stn" cx="', a[1], '" cy="', a[2], '" r="', CIRCLE_R, '"/>', "\n"
      out.print '<g transform="rotate(-45,', text_x, ',', text_y, ')">'
      out.print '<text class="stn-name" text-anchor="start" x="', text_x + CIRCLE_R * 3, '" y="', text_y, '">', name, '</text></g>', "\n"
    when 'dc'
      text_x = a[1]
      text_y = a[2] + base
      out.print '<circle class="stn" cx="', a[1], '" cy="', a[2], '" r="', CIRCLE_R, '"/>', "\n"
      out.print '<g transform="rotate(45,', text_x, ',', text_y, ')">'
      out.print '<text class="stn-name" text-anchor="start" x="', text_x + CIRCLE_R, '" y="', text_y, '">', name, '</text></g>', "\n"
    when 'ur'
      text_x = a[1]
      text_y = a[2] + base
      out.print '<circle class="stn" cx="', a[1], '" cy="', a[2], '" r="', CIRCLE_R, '"/>', "\n"
      out.print '<g transform="rotate(45,', text_x, ',', text_y, ')">'
      out.print '<text class="stn-name" text-anchor="end" x="', text_x - CIRCLE_R * 3, '" y="', text_y, '">', name, '</text></g>', "\n"
    when 'dr'
      text_x = a[1]
      text_y = a[2] + base
      out.print '<circle class="stn" cx="', a[1], '" cy="', a[2], '" r="', CIRCLE_R, '"/>', "\n"
      out.print '<g transform="rotate(-45,', text_x, ',', text_y, ')">'
      out.print '<text class="stn-name" text-anchor="end" x="', text_x - CIRCLE_R, '" y="', text_y, '">', name, '</text></g>', "\n"
    end
  end
end

open("src/size.txt", "r") do |f|
  f.each_line do|line|
    line.chomp!
    next if line.empty? || line.match(/^#/)
    a = line.split(" ")
    if a.size >= 3
      if a[0] == "offset"
        OFFSET_X = a[1].to_i
        OFFSET_Y = a[2].to_i
      elsif a[0] == "size"
        WIDTH = a[1].to_i
        HEIGHT = a[2].to_i
      end
    end
  end
end

x = 0
y = 0
prev_dst = nil
stn = []
stn_link_name = {}
stn_link = []

open("map.html", "w") do |out|
  out.print <<EOS
<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>rail-world</title>
<style type="text/css">
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}
svg {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  font-family: 'Noto Sans CJK';
}
.land {
  fill: #ddf;
  stroke-width: 2px;
  stroke: #88a
}
.sea {
  fill: white;
}
.rail-l {
  stroke-width: 4px;
  fill: none;
}
.rail {
  stroke-width: 8px;
  fill: none;
}
.rail-h {
  stroke-width: 12px;
  fill: none;
}
/*
.not-used {
  stroke-opacity: 0.25;
}
*/
.stn {
  fill: white;
}
.stn-name {
  font-size: 12px;
  fill: black;
  cursor: default;
}
.stn-name-p {
  font-size: 12px;
  fill: gray;
}
.stn-link {
  stroke-width: 8px;
  stroke: white;
}
EOS

  # 路線ごとに色分け
  open("src/line-color.txt", "r") do |f|
    f.each_line do |line|
      line.chomp!
      next if line.empty? || line.match(/^#/)

      a = line.split(" ")
      if a.size >= 3 && a[2] == "*"
        out.print ".", a[0], " {\n  stroke: ", a[1], "; stroke-dasharray: 2, 2;\n}\n"
      elsif a.size >= 2
        out.print ".", a[0], " {\n  stroke: ", a[1], ";\n}\n"
      end
    end
    out.print ".others {\n  stroke: #808080;\n}\n"
  end

  out.print <<EOS
</style>
<script src="map.js"></script>
</head>
<body>
EOS

  out.print '<svg width="', WIDTH * STEP, '" height="', HEIGHT * STEP, '">', "\n"

  out.print <<EOS
<g id="main">
EOS

  # 海
  out.print '<g id="layer-sea">', "\n"
  out.print '<rect x="0" y="0" width="', WIDTH * STEP, '" height="', HEIGHT * STEP, '" class="sea"/>', "\n"
  out.print '</g>', "\n"
  # 陸地
  first = false
  output = false
  out.print '<g id="layer-land">', "\n"
  open("src/land.txt", "r") do |f|
    f.each_line do |line|
      line.chomp!
      next if line.empty? || line.match(/^#/)

      a = line.split(" ")
      case a[0]
      when 'begin'
        out.print '<path class="land" d="'
        first = true
      when 'end'
        out.print ' Z" />', "\n"
      when 'm'
        dx = a[1]
        if dx.match?(/^-?\d+$/) || dx == '<' || dx == '>'
          if dx == '<'
            x = 0
          elsif dx == '>'
            x = WIDTH * STEP
          else
            x = (dx.to_i + OFFSET_X) * STEP
          end
          dy = a[2]
          if dy == '^'
            y = 0
          elsif dy == '_'
            y = HEIGHT * STEP
          else
            y = (dy.to_i + OFFSET_Y) * STEP
          end
        else
          if stn_link_name.has_key?(dx)
            b = stn_link_name[dx]
            x = b[0]
            y = b[1]
            if a.size >= 4
              x += a[2].to_i * STEP
              y += a[3].to_i * STEP
            end
          else
            raise "Station name #{a[1]} not found"
          end
        end
        output = true;
      when 'pos'
        stn_link_name[a[1]] = [x, y]
#print a[1], "=", (x/STEP)-OFFSET_X, ",", (y/STEP)-OFFSET_Y, "\n"
      when 'n'
        if a[1] == '*'
          y = 0
        else
          y -= a[1].to_i * STEP
        end
        output = true;
      when 's'
        if a[1] == '*'
          y = HEIGHT * STEP
        else
          y += a[1].to_i * STEP
        end
        output = true;
      when 'w'
        if a[1] == '*'
          x = 0
        else
          x -= a[1].to_i * STEP
        end
        output = true;
      when 'e'
        if a[1] == '*'
          x = WIDTH * STEP
        else
          x += a[1].to_i * STEP
        end
        output = true;
      when 'ne'
        x += a[1].to_i * STEP
        y -= a[1].to_i * STEP
        output = true;
      when 'nw'
        x -= a[1].to_i * STEP
        y -= a[1].to_i * STEP
        output = true;
      when 'se'
        x += a[1].to_i * STEP
        y += a[1].to_i * STEP
        output = true;
      when 'sw'
        x -= a[1].to_i * STEP
        y += a[1].to_i * STEP
        output = true;
      else
        raise "Unknown command: '#{a[0]}'"
      end
      if output
        if first
          out.print 'M', x, ',', y
          first = false
        else
          out.print ' L', x, ',', y
        end
        output = false
      end
    end
  end
  out.print '</g>', "\n"

  out.print '<g id="layer-line">', "\n"
  # 路線
  for file in ["jp-jr", "jp-west", "jp-east", "tw", "kr", "kp", "cn"] do
    open("lines/" + file + ".txt", "r") do |f|
      path_class = []
      linenum = 0
      f.each_line do |line|
        linenum += 1
        line.chomp!
        next if line.empty? || line.match(/^#/)

        a = line.split(" ")
        case a[0]
        when 'begin'
          a.shift
          path_class = a
          out.print '<path class="', path_class.join(' '), '" d="'
        when 'end'
          out.print "L", x, ",", y, '"/>', "\n"
          prev_dst = nil
        when 'm'
          if a[1].match?(/^-?\d+$/)
            x = (a[1].to_i + OFFSET_X) * STEP
            y = (a[2].to_i + OFFSET_Y) * STEP
          else
            if stn_link_name.has_key?(a[1])
              b = stn_link_name[a[1]]
              x = b[0]
              y = b[1]
              if a.size >= 4
                x += a[2].to_i * STEP
                y += a[3].to_i * STEP
              end
            else
              raise "Station name #{a[1]} not found"
            end
          end
          out.print "M", x, ",", y, " "
        when 'box', 'lbox', 'uc', 'dc', 'ur', 'dr'
          if a.size >= 5
            stn.push [a[0], x, y, a[1], a[3].to_i, a[4].to_i]
          else
            stn.push [a[0], x, y, a[1]]
          end
          if a.size >= 3
            if stn_link_name.has_key?(a[2])
              b = stn_link_name[a[2]]
              stn_link.push [x, y, b[0], b[1]]
            else
              stn_link_name[a[2]] = [x, y]
            end
          end
        when 'add'
          a.shift
          out.print "L", x, ",", y, '"/>', "\n"
          prev_dst = nil
          path_class += a
          out.print '<path class="', path_class.join(' '), '" d="M', x, ",", y, " "
        when 'del'
          a.shift
          out.print "L", x, ",", y, '"/>', "\n"
          prev_dst = nil
          path_class -= a
          out.print '<path class="', path_class.join, '" d="M', x, ",", y, " "
        when 'n', 'nw', 'ne', 's', 'sw', 'se', 'w', 'e'
          if !prev_dst || prev_dst != a[0]
            out.print "L", x, ",", y, " "
            prev_dst = a[0]
          end
          n = a[1].to_i * STEP
          case a[0]
          when 'n'
            y -= n
          when 'nw'
            x -= n
            y -= n
          when 'ne'
            x += n
            y -= n
          when 's'
            y += n
          when 'sw'
            x -= n
            y += n
          when 'se'
            x += n
            y += n
          when 'w'
            x -= n
          when 'e'
            x += n
          end
        else
          raise "Unknown command '#{a[0]}' at #{file}(#{linenum})"
        end
      end
    end
  end

  out.print '</g>', "\n"

  # 駅
  out.print '<g id="layer-station">', "\n"
  draw_stations out, stn, stn_link
  out.print '</g>', "\n"
  out.print <<EOS
</g>
</svg>
</body>
</html>
EOS
end

