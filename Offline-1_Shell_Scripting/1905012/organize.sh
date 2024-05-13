#!/bin/bash


totalArgs=$#


if [ $totalArgs -lt 4 ]
then 
	echo "Usage:"
	echo "./organize.sh <submission folder> <target folder> <test folder> <answer folder> [-v] [-noexecute]"
	echo " "
	echo "-v: verbose"
	echo "-noexecute: do not execute code files"
	kill -INT $$
fi

submissions="submissions"
tests="tests"
answers="answers"
targets="targets"


submissions=$1
targets=$2
tests=$3
answers=$4

verbosePrint="true"
executePrint="true"


if [ $totalArgs -lt 5 ]
then 
	verbosePrint="false"
	executePrint="false"
elif [ $totalArgs -eq 5 ]
then 
	if [ $5 = "-v" ]
	then
		verbosePrint="true"
		executePrint="true"
	else
		verbosePrint="false"
		executePrint="false"
	fi
elif [ $totalArgs -eq 6 ]
then 
	verbosePrint="true"
	executePrint="false"
fi

totalTests=0
cd "$tests"/
for i in *.txt;
do 	
	totalTests=`expr $totalTests + 1`
done

if [ $verbosePrint = "true" ] || [ $executePrint = "true" ]
then 
	echo "Found $totalTests test files"
fi

cd ..





mkdir -p "$targets"/
cd "$targets"/
mkdir -p C/
mkdir -p Python/
mkdir -p Java/

if [ $executePrint = "true" ]
then
	touch result.csv
	truncate -s 0 result.csv
	echo "student_id, type, matched, not_matched" >> ../"$targets"/result.csv
fi
cd ..
cd "$submissions"/
for i in *.zip;
do 	
	#echo "$i"
	tmp=$(echo "$i" | awk -F '_' '{print $5}' )
	#echo $tmp
	tmp2=$(echo "$tmp" | awk -F '.' '{print $1}' )
	#echo $tmp2
	if [ $verbosePrint = "true" ]
	then 
		echo "Organizing files of $tmp2"
	fi
	mkdir -p "$tmp2"
	unzip -qo "$i" -d "$tmp2"
	cd "$tmp2"
	typeLang="C"
	#for f in **/*\ *; do mv "$f" "${f// /_}"; done #for removing white spaces
	while read line ; do mv "$line" "${line// /}" ; done < <(find ./ -iname "* *")
	total=0
	mismatches=0

	if [ $executePrint = "true" ]
	then 
		echo "Executing files of $tmp2"
	fi

		for file in `find ./ -name '*.c'`;
		do	
			#echo $file
			typeLang="C"
			mkdir -p ../../"$targets"/C/"$tmp2"
			touch ../../"$targets"/C/"$tmp2"/main.c
			cp "$file" ../../"$targets"/C/"$tmp2"/main.c
			if [ $executePrint = "true" ]
			then
				gcc ../../"$targets"/C/"$tmp2"/main.c -o ../../"$targets"/C/"$tmp2"/main.out
				for inputFile in ../../"$tests"/*.*;
				do	
					total=`expr $total + 1`
					./../../"$targets"/C/"$tmp2"/main.out < "$inputFile" > ../../"$targets"/C/"$tmp2"/"out$total.txt"
					DIFF=$(diff ../../"$targets"/C/"$tmp2"/"out$total.txt" ../../"$answers"/"ans$total.txt") 
					if [ "$DIFF" != "" ] 
					then
						mismatches=`expr $mismatches + 1`
					fi 
				done
			fi

		done



		for file in `find ./ -name '*.py'`;
		do	
			typeLang="Python"
			mkdir -p ../../"$targets"/Python/"$tmp2"
			touch ../../"$targets"/Python/"$tmp2"/main.py
			cp "$file" ../../"$targets"/Python/"$tmp2"/main.py
			if [ $executePrint = "true" ]
			then
				for inputFile in ../../"$tests"/*.*;
				do	
					total=`expr $total + 1`
					python3 ./../../"$targets"/Python/"$tmp2"/main.py < "$inputFile" > ../../"$targets"/Python/"$tmp2"/"out$total.txt"
					#./../../"$targets"/C/"$tmp2"/main.py < "$inputFile" > ../../"$targets"/C/"$tmp2"/"out$total.txt"
					DIFF=$(diff ../../"$targets"/Python/"$tmp2"/"out$total.txt" ../../"$answers"/"ans$total.txt") 
					if [ "$DIFF" != "" ] 
					then
						mismatches=`expr $mismatches + 1`
					fi 
				done
			fi
		done
		for file in `find ./ -name '*.java'`;
		do	
			typeLang="Java"
			mkdir -p ../../"$targets"/Java/"$tmp2"
			touch ../../"$targets"/Java/"$tmp2"/Main.java
			cp "$file" ../../"$targets"/Java/"$tmp2"/Main.java

			if [ $executePrint = "true" ]
			then
				javac ../../"$targets"/Java/"$tmp2"/Main.java
				for inputFile in ../../"$tests"/*.*;
				do	
					total=`expr $total + 1`
					java -cp ./../../"$targets"/Java/"$tmp2"/ Main < "$inputFile" > ../../"$targets"/Java/"$tmp2"/"out$total.txt"
					DIFF=$(diff ../../"$targets"/Java/"$tmp2"/"out$total.txt" ../../"$answers"/"ans$total.txt") 
					if [ "$DIFF" != "" ] 
					then
						mismatches=`expr $mismatches + 1`
					fi 
				done
			fi

		done

	cd ..
	if [ $executePrint = "true" ]
	then
		matches=`expr $total - $mismatches`
		echo "$tmp2, $typeLang, $matches, $mismatches" >> ../"$targets"/result.csv
	fi

	
done