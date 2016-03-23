#!/bin/bash

rspec

time ./color_tree -bte \
     -n test_files/db_seqs.name_map \
     -p test_files/db_seqs.patterns \
     test_files/db_seqs.tre > /dev/null
echo

time ./color_tree -bt \
     -n test_files/db_seqs.name_map \
     -p test_files/db_seqs.patterns_with_name_map \
     test_files/db_seqs.tre > /dev/null
echo

time ./color_tree -bte \
     -p test_files/db_seqs.patterns \
     test_files/db_seqs.tre > /dev/null
echo

time ./color_tree -bte \
     -p test_files/db_seqs.patterns \
     test_files/db_seqs.tre > /dev/null
echo
