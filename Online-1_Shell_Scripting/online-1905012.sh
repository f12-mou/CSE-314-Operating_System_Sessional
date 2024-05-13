#!/bin/bash

input=$1
output=$2

mkdir -p "./$output_dir"


cd "$input"

while read line ; do mv "$line" "${line// /}" ; done < <(find ./ -iname "* *")

for file in `find ./ -name '*'`;
do  
    if [ -f "$file" ]
    then
        #size=`cat $file | wc -l`
        mv "$file" "../$output/$file"
    fi
done

cd ..
cd "$output"
for file in `ls -S`;
do  
    size=`cat $file | wc -l`
    echo "$size--$file"
done







