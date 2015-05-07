# color_reads #

A command line script for editing Newick phylogenetic tree files.

## Info ##

Version: 0.0.1

Copyright 2015 Ryan Moore

Contact: moorer@udel.edu

License: GPLv3

Color branches and edit stuff. Outputs a nexus file for use in
FigTree.

Occasionally FigTree will color things when you haven't specifically
asked it to do so. This is likely due to you having colored branches
or taxa names with similar rules in the same session. Regardless,
restart FigTree and try again.

## Synopsis ##

	color_branches [-bt] [-r min_bootstrap] [-p pattern_file] [-n name_map] newick_file

## Examples ##

Remove all bootstrap values below 0.5:

	color_branches -r 0.5 tree.newick

Color branches according to patterns in patterns.txt:

	color_branches -b tree.newick patterns.txt

Color branches and taxa names:

	color_branches -bt tree.newick patterns.txt

Color taxa names and remove boostrap values < 0.5:

	color_branches -t -r 0.5 tree.newick patterns.txt

## Pattern file ##

Tab delimited, two columns -> `pattern`, `color`

pattern: a regular expression pattern

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

## Note ##

It might be a good idea to run the `clean_headers` script on your
alignment file before you make your tree.

	clean_headers sequences.fa > seqs.clean.fa
