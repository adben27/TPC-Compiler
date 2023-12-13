#!/bin/bash

if test -e log; then
	rm log
fi

for file in test/good/*; do
	echo $file >> log
	bin/tpcas < $file 2>> log
	echo "" >> log
	cat $file >> log
	echo -e "\n" >> log
done

echo -e "\n---------------------------------------------" >> log
echo -e "\nSyntax error tests\n" >> log

for file in test/syn-err/*; do
	echo $file >> log
	echo "" >> log
	bin/tpcas < $file 2>> log
	echo "" >> log
	cat $file >> log
	echo -e "\n" >> log
done

less log
