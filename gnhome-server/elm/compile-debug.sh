#!bin/bash
files=(
    "Main"
    "WidgetCanvas"
    "Widgets\\Weather\\Main"
    "Widgets\\Weather\\Mock"
    "Widgets\\Chat\\Main"
    )

for f in ${files[*]} 
do
    inputFile="src\\${f}.elm"
    outputFile="output\\${f}.js"
    printf "Compiling \"${inputFile}\" to \"${outputFile}\".....\n"
    elm make $inputFile --output $outputFile
done

printf "Project compiled.\n"

if [ "$1" != "-n" ]
then
    read -p "Press [Enter] to exit."
fi