#!bin/bash
src=(
    "Main.js"
    "WidgetCanvas.js"
    )

cd elm
sh compile.sh -n

printf "Copying JS-compiled Elm files to site folders...\n"

cd ../

for f in ${src[*]} 
do
    inputFile="elm\\output\\${f}"
    outputFile="nodejs\\site\\static\\src\\elm\\${f}"
    printf "Copying $inputFile to $outputFile..."
    cp $inputFile $outputFile
    if [ $? -eq 0 ]
    then
        printf "Done!\n"
    else
        printf "\nFailed.\n"
    fi
done

printf "Process done! Enjoy!\n"
read -p "Press [Enter] to exit."