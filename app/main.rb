require 'lib/dragon_object.rb'

class Solid
  def clicked?
    (@x..(@x + @w)).include?($gtk.args.mouse.x) && (@y..(@y + @h)).include?($gtk.args.mouse.y)
  end
end

def generate_pad_row(row, y)
  row.map.with_index do |e, i|
    color = e.zero? ? [127, 0, 0] : [255, 0, 0]
    Solid.new(x: 200 + i * 50, y: y, h: 40, w: 40, color: color)
  end
end

$bpm = 85
$step_count = 0
$lights = 16.times.map { |i| Solid.new(x: 200 + i * 50, y: 200, w: 20, h: 20, color: [127, 0,0]) }
$lit = Solid.new(x: 200, y: 200, w: 20, h: 20, color: [255, 0,0])
$kicks = [1,0,0,1,1,0,0,0,1,0,0,1,0,0,1,0]
$kick_pads = generate_pad_row($kicks, 600)
$snares = [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0]
$snare_pads = generate_pad_row($snares, 500)
$hats = [1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1]
$hat_pads = generate_pad_row($hats, 400)
$cb = [0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0]
$cb_pads = generate_pad_row($cb, 300)
$up = Solid.new(x: 1100, y: 650, w: 75, h: 30, color: [127,127,127] )
$down = Solid.new(x: 1100, y: 570, w: 75, h: 30, color: [127,127,127] )
def tick args
  args.outputs.solids << [$lights, $lit, $up, $down]
  args.outputs.solids << [$kick_pads, $snare_pads, $hat_pads, $cb_pads]
  args.outputs.labels << [[50,650, "BD", 12], [50,550, "SN", 12], [50,450, "HH", 12], [50,350, "CB",12]]
  args.outputs.labels << [1100, 650, $bpm, 12 ]
  if args.state.tick_count % step == 0
    args.outputs.sounds << "sounds/volca1.wav" if $kicks[$step_count % 16] == 1
    args.outputs.sounds << "sounds/snare.wav" if $snares[$step_count % 16] == 1
    args.outputs.sounds << "sounds/hihat.wav" if $hats[$step_count % 16] == 1
    args.outputs.sounds << "sounds/cowbell.wav" if $cb[$step_count % 16] == 1
    $lit.x = 200 + ($step_count % 16) * 50
    $step_count += 1
  end
  return unless args.inputs.mouse.click
  check_pads($kick_pads, $kicks)
  check_pads($snare_pads, $snares)
  check_pads($hat_pads, $hats)
  check_pads($cb_pads, $cb)
  $bpm += 1 if $up.clicked?
  $bpm -= 1 if $down.clicked?
end

def step
  ((60.0 / $bpm * 60) / 4).to_i
end

def check_pads(pads, sequence)
  pads.each.with_index do |e,i|
    if e.clicked?
      sequence[i] = sequence[i].zero? ? 1 : 0
      e.color = sequence[i].zero? ? [127,0,0] : [255,0,0]
    end
  end
end
