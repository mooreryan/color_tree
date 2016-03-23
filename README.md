# color_tree #

A command line script for editing Newick phylogenetic tree
files. Color branches and edit stuff. Outputs a nexus file for use in
FigTree.

**NOTE**: If the program doesn't work, first try the fix here
[Line endings](#line-endings)

## Set up ##

### Install dependencies ###

- Ruby 1.9 or newer

Ruby is a requirement. You probably have ruby already, but if not, I
recommend installing with
[Ruby Version Manager](https://rvm.io/). Actually, I recommend
[RVM](https://rvm.io/) even if you already have ruby installed.

Check if Ruby is installed by typing `which ruby` in the terminal. If
you get something like `/Users/moorer/.rvm/rubies/ruby-2.3.0/bin/ruby`
or `/usr/bin/ruby` then you have ruby.

- [RubyGems](https://rubygems.org/pages/download)

Package management framework for Ruby. It is sort of like `CPAN` for
perl or `CRAN` for R.

Check if [RubyGems](https://rubygems.org/pages/download) is installed by typing `which gem` in the terminal.

- Gems

Install the dependencies with

    gem install bio trollop parse_fasta abort_if

### Option 1: Downloading source code ###

1. Click on the `Releases` link on the main page of the github repo
   (or just go here
   `https://github.com/mooreryan/color_tree/releases`.
2. Pick the version you want -- probably the latest ;)
3. Download that.
4. Unzip/untar it.

        tar xzf ~/Downloads/color_tree-0.5.tar.gz

5. Move the source tree to a cool location.

        mv ~/Downloads/color_tree-0.5 ~/Software

At this point you can use `color_tree` by typing

    ~/Software/color_tree/color_tree --help

### Option 2: Get source with git ###

Clone the repo to your favorite local folder.

	git clone https://github.com/mooreryan/color_tree.git

#### To update ####

1. Enter the `color_tree` source directory.
2. Type the command `git pull`.
3. Copy the color_tree executable script to somewhere on your path
   (preferably where the old version was copied to).

### Adding color_tree to PATH ###

If you want to add `color_tree` to your path....

1. Add the color tree source directory to your `PATH` environment
   variable. There are different places to put this but `~/.profile`
   should be a good one. Add this to your `~/.profile`...

        $PATH=$PATH:"$HOME/Software"
        export PATH

2. Type `source ~/.profile`.

**Note**: You must leave the `color_tree` source directory structure
  intact for `color_tree` to work properly.

## Usage ##

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

If no color is specified, (e.g., that column is blank for that row),
the default will be black.

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

You shouldn't use any symbols that are not compatible with
newick/nexus in your new names. `color_tree` will take care of this
for you, however, by converting any non-alphanumeric or non-underscore
character into an underscore.

### Example ###

    1a	Silly apple phage
    2a	Mariprofundus seanii

## Notes ##

### Line endings ###

If the program doesn't appear to be working, make sure the line
endings of the input files are correct and re-run it.

You can do this by running

    convert_line_endings.py input_file.txt

which is provided in the `bin` directory.

### Cleaning headers ###

If you want, you can use `clean_headers` to clean the headers of your
fasta file. It uses the same rules as `color_tree` for header
cleaning, so it shouldn't be necessary. However, it might be useful
more generally.

	clean_headers sequences.fa > seqs.clean.fa

This won't help you after you've made your tree though ;)

### Coloring issues ###

Occasionally FigTree will color things when you haven't specifically
asked it to do so. This is likely due to you having colored branches
or taxa names with similar rules in the same session. Regardless,
restart FigTree and try again.

### Importing into FigTree ###

**IMPORTANT**

When opening the nexus file in FigTree, make sure to leave the label
name as `label`, so the bootstrap labels will be colored black and not
match the color of the branches.

## Versions ##

0.6 -- Much faster. "Installing" is a bit different.

0.5 -- If color is not specified, defaults to black. Fixed bug where
names were not being properly cleaned.

0.4 -- update docs, provide `convert_line_endings.py` script

0.2 -- added exact pattern matching
