#!/usr/bin/env ruby

if ARGV.count != 1
  abort("Error: Provide a fasta alignment file")
end

if !File.exist? ARGV[0]
  abort("Error: #{ARGV[0]} doesn't exist")
end

Signal.trap("PIPE", "EXIT")

require 'parse_fasta'

num_seqs = 0
len = nil
FastaFile.open(ARGV.first).each_record do |head, seq|
  num_seqs += 1

  if len && seq.length != len
    abort("Error: alignments are not the same length")
  end

  len ||= seq.length
end

printf "%s %s\n", num_seqs, len

num = 0
FastaFile.open(ARGV.first).each_record do |head, seq|
  printf "%-10.10s%s\n", num, seq

  $stderr.printf "%s\t%s\n", num, head

  num += 1
end
