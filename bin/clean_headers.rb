#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

def clean str
  str.gsub(/[^\p{Alnum}_]+/, "_").gsub(/_+/, "_")
end

FastaFile.open(ARGV.first).each_record do |head, seq|
  printf ">%s\n", clean(head)
  puts seq
end
