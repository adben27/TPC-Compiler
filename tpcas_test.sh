#!/bin/bash

if test -e log; then
	rm log
fi

if [ ! -e bin/tpcas ]; then
	echo -e "L'exécutable doit être compilé !\nSortie du script"
	exit
fi

for file in test/good/*; do
	echo $file >> log
	echo "" >> log
	bin/tpcas -t < $file >> log 2>&1
	echo "" >> log
	cat -n $file >> log
	echo -e "\n" >> log
done

echo -e "\n---------------------------------------------" >> log
echo -e "\nSyntax error tests\n" >> log

for file in test/syn-err/*; do
	echo $file >> log
	echo "" >> log
	bin/tpcas < $file 2>> log
	echo "" >> log
	cat -n $file >> log
	echo -e "\n" >> log
done

gedit -s log &
