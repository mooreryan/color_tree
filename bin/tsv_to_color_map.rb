#!/usr/bin/env ruby

# TODO add log transform

# TODO coloring in this way will never get recursive branch
# coloring. Maybe color based on dominant group? Eg if higher in blue,
# color branch blue?

# TODO allow more than two groups

require "abort_if"
require "color"

include AbortIf
include AbortIf::Assert

A = 0.1
B = 0.5

# scales [min, max] to [B, A]
def scale_reverse x, min=0.0, max=1.0
  (B - ((((B - A) * (x - min)) / (max - min)) + A))
end

# scales [min, max] to [A, B]
def scale x, min=0.0, max=1.0
  ((((B - A) * (x - min)) / (max - min)) + A)
end



def color_by_abund rgb, val
  assert val >= 0 && val <= 100,
         "Val #{val} must be between 0 and 100"

  rgb.lighten_by val
end

# NOTE more abundant group blue, and less abundant group yellow seems
# to look best

color1 = Color::RGB.by_name "blue"
color2 = Color::RGB.by_name "yellow"

tsv = ARGV[0]

v1s = []
v2s = []
seq_vals = {}
File.open(tsv).each_line do |line|
  unless line.start_with? "#"
    seq, v1, v2 = line.chomp.split "\t"

    v1s << v1.to_f
    v2s << v2.to_f
    seq_vals[seq] = [v1.to_f, v2.to_f]
  end
end

v1_min = v1s.reject(&:zero?).min
v2_min = v2s.reject(&:zero?).min

v1_max = v1s.max
v2_max = v2s.max

seq_vals_norm = seq_vals.map do |seq, (v1, v2)|
  [seq, [v1 / v1_max, v2 / v2_max]]
end

$stderr.printf "%10s %6s %6s %6s %6s %6s %6s\n",
               "seq",
               "r", "b",
               "rn", "bn",
               "rs", "bs"
seq_vals_norm.each do |seq, (n1, n2)|
  $stderr.printf "%10s %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n",
                 seq,
                 seq_vals[seq][0],
                 seq_vals[seq][1],
                 n1,
                 n2,
                 scale(n1),
                 scale(n2)
end

v1_norm_min = seq_vals_norm.map { |s, (v1, v2)| v1 }.reject(&:zero?).min
v2_norm_min = seq_vals_norm.map { |s, (v1, v2)| v2 }.reject(&:zero?).min

v1_norm_max = seq_vals_norm.map { |s, (v1, v2)| v1 }.max
v2_norm_max = seq_vals_norm.map { |s, (v1, v2)| v2 }.max

seq_vals_norm.each do |seq, (v1_norm, v2_norm)|
  v1_scaled = scale v1_norm
  v2_scaled = scale v2_norm

  v1_col = color_by_abund color1, v1_scaled
  v2_col = color_by_abund color2, v2_scaled

  abort_if v1_scaled.zero? && v2_scaled.zero?,
           "v1 and v2 cannot both be zero"

  if v1_scaled.zero?
    mix_col = color_by_abund color2, v2_scaled
  elsif v2_scaled.zero?
    mix_col = color_by_abund color1, v1_scaled
  elsif v1_scaled >= v2_scaled
    ratio = 1 / (v1_scaled / v2_scaled)
    orig_col_val = ratio / 2 * 100

    mix_col = color2.mix_with color1, orig_col_val
  elsif v1_scaled < v2_scaled
    ratio = v1_scaled / v2_scaled
    orig_col_val = ratio / 2 * 100

    mix_col = color1.mix_with color2, orig_col_val
  else
    abort_if true, "Weird error"
  end

  puts [seq, "##{mix_col.hex}"].join "\t"
end
