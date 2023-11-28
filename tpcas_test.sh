##!/bin/bash
if test -e log; then
	rm log
fi

for file in test/good/*; do
	echo $file >> log
	echo "" >> log
	bin/tpcas < $file 2>> log
	cat $file >> log
	echo "" >> log
done

for file in test/syn-err/*; do
	echo $file >> log
	echo "" >> log
	bin/tpcas < $file 2>> log
	cat $file >> log
	echo "" >> log
done

vim -R log
