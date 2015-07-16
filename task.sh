#!/bin/sh

kill -s INT " $(cat server.pid) "
pushd ../afra #Later load path from config file maybe
rake export\[data/Solenopsis_invicta/Si_gnF.gff\] > ../RubyDAS/data/
popd
rake import
rake run_sub\[signf.db\]

