#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

def clean name
  name.gsub(/[-():,;\[\] ]+/, "_")
end

FastaFile.open(ARGV.first).each_record do |head, seq|
  printf ">%s\n", clean(head)
  puts seq
end
