#!/bin/bash


cd /Volumes/Data/Code/ARK/econ-ark-tools/configurator/results
group='All'
echo "../$group/dir-base"

rm -Rf "../$group/dir-base"
rm -Rf "../$group/base-dir"

[[ ! -e "../$group/dir-base" ]] && mkdir -p "../$group/dir-base" && 
[[ ! -e "../$group/base-dir" ]] && mkdir -p "../$group/base-dir" && 


for dir in figure_Parameters_1940s_shocks figure_Parameters_base figure_equity_0p02 figure_equity_0p04 figure_short_career; do
    dir="${dir%*/}"
#    echo "$dir"
    dirBase="$(basename $dir)"
    echo "$dirBase"
    dirsize="${dirBase:(-6)}"
    echo $dirsize
    cd "$dir"
    for f in RShare_Means.png; do
	base="$(basename -s .png "$f")"
	dirsize_base="$dirsize-$base.png"
	base_dirsize="$base-$dirsize.png"
	cp ./$base.png ../../$group/dir-base/"$dirsize_base" 
	cp ./$base.png ../../$group/base-dir/"$base_dirsize"
    done
    cd ..
done

#open "../$group/dir-base"
open "../$group/base-dir"
