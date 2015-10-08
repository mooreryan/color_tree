# color_tree #

A command line script for editing Newick phylogenetic tree files.

## Info ##

Version: 0.0.3

Copyright 2015 Ryan Moore

Contact: moorer@udel.edu

License: GPLv3

Color branches and edit stuff. Outputs a nexus file for use in
FigTree.

## Set up ##

Clone the repo to your favorite local folder.

	git clone https://github.com/mooreryan/color_tree.git

Copy the `color_tree` script to somewhere you enjoy putting
executable files. May I suggest `~/bin` ?

	cp color_tree/color_tree ~/bin

Assuming `~/bin` is on your path, you're ready to go!

## Dependencies ##

Requires at least Ruby 1.9.

Requires `trollop` and `bio`. If you don't have them, run:

	gem install trollop
	gem install bio

## Synopsis ##

	color_tree [-bthe] [-r min_bootstrap] [-p pattern_file] [-n name_map] newick_file

## Options ##

    Options:
      -b, --color-branches                 Color branches?
      -t, --color-taxa-names               Color label names?
      -e, --exact                          Exact pattern matching
      -r, --remove-bootstraps-below=<f>    Remove bootstrap values below given
                                           value
      -p, --patterns=<s>                   Pattern file name
      -n, --name-map=<s>                   File with name mappings
      -h, --help                           Show this message

## Examples ##

Remove all bootstrap values below 0.5:

	color_tree -r 0.5 tree.newick > tree.nexus

Color branches according to patterns in patterns.txt:

	color_tree -b -p patterns.txt tree.newick > tree.nexus

Color branches according to exact matches in patterns.txt

	color_tree -be -p patterns.txt tree.newick > tree.nexus

Color branches and taxa names:

	color_tree -bt -p patterns.txt tree.newick > tree.nexus

Color taxa names and remove boostrap values < 0.5:

	color_tree -t -r 0.5 -p patterns.txt tree.newick > tree.nexus

## Pattern file ##

Tab delimited, two columns -> `pattern`, `color`

pattern: a regular expression pattern (case insensitive)

color: one of red, blue, green, yellow, black, or a hexadecimal color
code, e.g., #000000.

If a color other than red, blue, green, yellow, black or a hex color
code is specified, the value will be black.

If a `name_map` is provided, the patterns will search against the new
names (column 2) in the name_map, not the old_names (column 1).

### Example ###

    _Bacteria	blue
    [ds]sDNA virus	#0FF0FF
    e.*coli	red

### Exact matches ###

If the `-e` flag is passed in the patterns in column 1 will be
searched against nodes as exact string matches. E.g., `bacteria` would
match `bacteria`, but not `Bacteria` or `proteobacteria`.

## Name map ##

Tab delimited, two columns -> `old_name`, `new_name`

Within each category, names must be unique.

If there are unsafe characters in the name, they will be cleaned
using the same rules as for cleaning the newick file.

Unlike the `pattern_file`, `old_name` is treating as a string and not
a regex, i.e., exact string matching is used.

### Example ###

    1a	Silly apple phage
    2a	Mariprofundus seanii

## Notes ##

### Line endings ###

If the program doesn't appear to be working, make sure the line
endings of the input files are correct and re-run it.

### Cleaning headers ###

If you want, you can use `clean_headers` to clean the headers of your
fasta file. It uses the same rules as `color_tree` for header
cleaning, so it shouldn't be necessary. However, it might be useful
more generally.

	clean_headers sequences.fa > seqs.clean.fa

### Coloring issues ###

Occasionally FigTree will color things when you haven't specifically
asked it to do so. This is likely due to you having colored branches
or taxa names with similar rules in the same session. Regardless,
restart FigTree and try again.

### Importing into FigTree ###

IMPORTANT

When opening the nexus file in FigTree, make sure to leave the label
name as `label`, so the bootstrap labels will be colored black and not
match the color of the branches.

## Versions ##

0.0.2 -- added exact pattern matching
