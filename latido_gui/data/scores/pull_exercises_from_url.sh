#!/bin/bash

for i in `seq $2`
do
	num=$(printf "%03d" $i+1)
	wget "$1""$num".gif
done
