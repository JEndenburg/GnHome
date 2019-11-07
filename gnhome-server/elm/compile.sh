#!bin/bash
files=(
    "Main"
    )

for f in ${files[*]} 
do
    inputFile="src\\${f}.elm"
    outputFile="output\\${f}.js"
    printf "Compiling \"${inputFile}\" to \"${outputFile}\".....\n"
    elm make $inputFile --output $outputFile
done

printf "Project compiled."