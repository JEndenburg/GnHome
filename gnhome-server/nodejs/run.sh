#!bin/bash
printf "Starting app...\n"
restart=true

while ($restart)
do
    node ./app.js
    endVal=$?
    printf "App ended with code %d\n" $endVal
    if [ $endVal -eq 55 ]
    then
        restart=true
        printf "Restarting app...\n"
    else
        restart=false
    fi
done