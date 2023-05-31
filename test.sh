#!/bin/bash

#Downloading file
curl -s -o ./test.txt https://raw.githubusercontent.com/GreatMedivack/files/master/list.out

SERVER_NAME=$HOSTNAME
DATE=`date +%D | sed 's/\//_/g'`

#Input argument validation
if [ ! -z $1 ]; then
        SERVER_NAME=$1;
fi

failed=("$SERVER_NAME"_"$DATE"_"failed.out")
running=("$SERVER_NAME"_"$DATE"_"running.out")
report=("$SERVER_NAME"_"$DATE"_"report.out")
archive=("$SERVER_NAME"_"$DATE".tar)

#Sort function
name(){
        for i in $(grep -E $1 test.txt | awk '{print $1}'); do
        if echo $i | awk -F '-' '{print $NF}' | grep -q "^[0-9]*$"; then
                echo $i | awk -F '-' 'BEGIN { OFS = FS }; NF { NF -= 1 }; 1';
        else
                echo $i | awk -F '-' 'BEGIN { OFS = FS }; NF { NF -= 2 }; 1';

        fi
done
}

name Error"|"CrashLoopBackOff  > ./$failed
name Running > ./$running

count_run=`awk 'END {print NR}' $running`
count_err=`awk 'END {print NR}' $failed`

echo Number of running services:$count_run > ./$report && chmod 444 $report
echo Number of services with errors:$count_err >> ./$report
echo System User Name:$LOGNAME >> ./$report
echo Date of:`date +%D` >> ./$report

[ -d "./archives" ] || mkdir archives
tar cvf archives/$archive $failed $running $report

rm ./$failed $running $report test.txt

#Checking the archive
tar tvf ./archives/$archive 1>/dev/null

if echo $?==0 1>/dev/null; then
    echo "Archive is good!";
else
    echo "Archive is corrupted";
fi
