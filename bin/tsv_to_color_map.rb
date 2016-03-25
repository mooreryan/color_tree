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

def color_by_abund rgb, abund
  val = abund * 100
  assert val >= 0 && val <= 100,
         "Val #{val} must be between 0 and 100"

  rgb.lighten_by (abund * 100)
end

red = Color::RGB.by_name "red"
blue = Color::RGB.by_name "blue"

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

seq_vals_norm = {}
seq_vals.each do |seq, (v1, v2)|
  v1_norm = v1 / v1_max
  v2_norm = v2 / v2_max

  v1_col = color_by_abund red, v1_norm
  v2_col = color_by_abund blue, v1_norm

  abort_if v1_norm.zero? && v2_norm.zero?,
           "v1 and v2 cannot both be zero"

  if v1_norm.zero?
    mix_col = color_by_abund blue, v2_norm
  elsif v2_norm.zero?
    mix_col = color_by_abund red, v1_norm
  elsif v1_norm >= v2_norm
    ratio = 1 / (v1_norm / v2_norm)
    orig_col_val = ratio / 2 * 100

    mix_col = blue.mix_with red, orig_col_val
  elsif v1_norm < v2_norm
    ratio = v1_norm / v2_norm
    orig_col_val = ratio / 2 * 100

    mix_col = red.mix_with blue, orig_col_val
  else
    abort_if true, "Weird error"
  end

  puts [seq, "##{mix_col.hex}"].join "\t"
end
