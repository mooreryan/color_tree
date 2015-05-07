#!/usr/bin/env ruby

Signal.trap("PIPE", "EXIT")

require "bio"
require "trollop"

def check_file(arg, name)
  if arg.nil?
    Trollop.die name, "You didn't provide an input file!"
  elsif !File.exists?(arg)
    Trollop.die name, "#{arg} doesn't exist!"
  end

  parse_fname(arg)
end

def check_arg(arg, name)
  Trollop.die name, "The #{name} arg is required." unless arg
end

def parse_fname(fname)
  { dir: File.dirname(fname),
    base: File.basename(fname, File.extname(fname)),
    ext: File.extname(fname) }
end

def has_color name
  name.match(/(.*)(\[&!color="#[0-9A-F]{6}"\])/)
end

def clean name
  name.gsub(/[-():,;\[\] ]+/, "_")
end

def clean_name name
  if name.nil?
    nil
  else
    match = has_color name
    if match
      name = match[1]
      color = match[2]

      clean(name) + color
    else
      clean(name)
    end
  end
end

def leaf? tree, node
  tree.children(node).empty?
end

def add_color_to_leaf_branch patterns, node
  num_matches = 0
  color = nil
  patterns.each do |pattern, this_color|
    if node.to_s.match(/#{pattern}/i)
      num_matches += 1
      color = this_color
    end
  end

  if num_matches.zero?
    nil
  elsif num_matches == 1
    color
  else
    abort("Error: non-specific pattern")
  end
end

def add_color_to_inner_branch; end

def already_checked? name
  name.match(/\[&!color="#[0-9A-F]{6}"\]/)
end

def get_color node
  begin
    node.name.match(/\[&!color="#[0-9A-F]{6}"\]/)[0]
  rescue NoMethodError => e
    nil
  end
end

$times_called = 0
def foo patterns, tree, node
  $times_called += 1
  # clean the name no matter what
  node.name = clean_name node.name

  # check if it needs color, if so set the color
  color = add_color_to_leaf_branch patterns, node

  # if its a leaf that hasnt been checked & needs color
  if leaf?(tree, node) && !already_checked?(node.name) && color
    # add color to the name
    node.name = node.name + color
  # if it isn't a leaf
  elsif !leaf?(tree, node)
    children = tree.children(node) # get the children
    children_colors = []
    children.each do |child|
      foo patterns, tree, child # recurse to color the child if needed
      children_colors << get_color(child) # add color of the child
    end

    # if all the children have the same color
    if children_colors.uniq.count == 1
      # set the branch node to only the color name
      node.name = children_colors[0]
    end
  end

  return node
end

opts = Trollop.options do
  banner <<-EOS

  Color branches and edit stuff.

  Occasionally FigTree will color things when you haven't specifically
  asked it to do so. This is likely due to you having colored branches
  or taxa names with similar rules in the same session. Regardless,
  restart FigTree and try again.

  Options:
  EOS

  opt(:color_label_names, "Color label names?", short: "-l")
  opt(:color_branches, "Color branches?", short: "-b")
end

check_file ARGV[0], :patterns
color_f = ARGV[0]

check_file ARGV[1], :newick
newick = ARGV[1]

# if passed color other than one defined, return black
black = "#000000"
red = "#FF1300"
yellow = "#FFD700"
blue = "#5311FF"
green = "#00FF2C"
color2hex = Hash.new "[&!color=\"#{black}\"]"
color2hex.merge!({
                   "black" => "#000000",
                   "red" => "[&!color=\"#{red}\"]",
                   "blue" => "[&!color=\"#{blue}\"]",
                   "yellow" => "[&!color=\"#{yellow}\"]",
                   "green" => "[&!color=\"#{green}\"]"
                 })

# get the color patterns
patterns = {}
File.open(color_f).each_line do |line|
  pattern, color = line.chomp.split

  patterns[pattern] = color2hex[color]
end

treeio = Bio::FlatFile.open(Bio::Newick, newick)

newick = treeio.next_entry
tree = newick.tree

if opts[:color_label_names]
  leaves = tree.leaves.map do |n|
    name = clean_name n.name

    if (color = add_color_to_leaf_branch(patterns, name))
      name + color
    else
      name
    end
  end
else
  leaves = tree.leaves.map { |n| clean_name n.name }
end

if opts[:color_branches]
  tree.collect_node! do |node|
    foo patterns, tree, node
  end
end

tre_str = tree.newick(indent: false).gsub(/'/, '')

fig = 'begin figtree;
	set appearance.backgroundColorAttribute="Default";
	set appearance.backgroundColour=#-1;
	set appearance.branchColorAttribute="User selection";
	set appearance.branchLineWidth=1.0;
	set appearance.branchMinLineWidth=0.0;
	set appearance.branchWidthAttribute="Fixed";
	set appearance.foregroundColour=#-16777216;
	set appearance.selectionColour=#-2144520576;
	set branchLabels.colorAttribute="User selection";
	set branchLabels.displayAttribute="Branch times";
	set branchLabels.fontName="sansserif";
	set branchLabels.fontSize=8;
	set branchLabels.fontStyle=0;
	set branchLabels.isShown=false;
	set branchLabels.significantDigits=2;
	set colour.scheme.label="label:InterpolatingContinuous{{false,false,0.0,0.0},#000000,#000000}";
	set layout.expansion=0;
	set layout.layoutType="RECTILINEAR";
	set layout.zoom=0;
	set legend.attribute=null;
	set legend.fontSize=10.0;
	set legend.isShown=false;
	set legend.significantDigits=2;
	set nodeBars.barWidth=4.0;
	set nodeBars.displayAttribute=null;
	set nodeBars.isShown=false;
	set nodeLabels.colorAttribute="label";
	set nodeLabels.displayAttribute="label";
	set nodeLabels.fontName="sansserif";
	set nodeLabels.fontSize=8;
	set nodeLabels.fontStyle=0;
	set nodeLabels.isShown=true;
	set nodeLabels.significantDigits=2;
	set nodeShape.colourAttribute=null;
	set nodeShape.isShown=false;
	set nodeShape.minSize=10.0;
	set nodeShape.scaleType=Width;
	set nodeShape.shapeType=Circle;
	set nodeShape.size=4.0;
	set nodeShape.sizeAttribute=null;
	set polarLayout.alignTipLabels=false;
	set polarLayout.angularRange=0;
	set polarLayout.rootAngle=0;
	set polarLayout.rootLength=100;
	set polarLayout.showRoot=true;
	set radialLayout.spread=0.0;
	set rectilinearLayout.alignTipLabels=false;
	set rectilinearLayout.curvature=0;
	set rectilinearLayout.rootLength=100;
	set scale.offsetAge=0.0;
	set scale.rootAge=1.0;
	set scale.scaleFactor=1.0;
	set scale.scaleRoot=false;
	set scaleAxis.automaticScale=true;
	set scaleAxis.fontSize=8.0;
	set scaleAxis.isShown=false;
	set scaleAxis.lineWidth=1.0;
	set scaleAxis.majorTicks=1.0;
	set scaleAxis.origin=0.0;
	set scaleAxis.reverseAxis=false;
	set scaleAxis.showGrid=true;
	set scaleBar.automaticScale=true;
	set scaleBar.fontSize=10.0;
	set scaleBar.isShown=true;
	set scaleBar.lineWidth=1.0;
	set scaleBar.scaleRange=0.0;
	set tipLabels.colorAttribute="User selection";
	set tipLabels.displayAttribute="Names";
	set tipLabels.fontName="sansserif";
	set tipLabels.fontSize=8;
	set tipLabels.fontStyle=0;
	set tipLabels.isShown=true;
	set tipLabels.significantDigits=2;
	set trees.order=true;
	set trees.orderType="increasing";
	set trees.rooting=false;
	set trees.rootingType="User Selection";
	set trees.transform=false;
	set trees.transformType="cladogram";
end;
'

nexus = "#NEXUS
begin taxa;
dimensions ntax=#{leaves.count};
taxlabels
#{leaves.join("\n")}
;
end;

begin trees;
  tree tree_1 = [&R] #{tre_str}
end;

#{fig}"

puts nexus
$stderr.puts $times_called
