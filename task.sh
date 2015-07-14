#!/bin/sh

tmp=" $(ps -ef | grep http.server | awk '{print $2}' )"
eval tmp_arr=$(tmp)
pid=${tmp_arr[1]}
kill -s INT pid
pushd ../afra #Later load path from config file maybe
rake export\[data/Solenopsis_invicta/Si_gnF.gff\] > ../RubyDAS/data/
popd
rake import
rake run\[signf.db\]
