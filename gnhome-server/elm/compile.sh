#!bin/bash
files=(
    "Main"
    )

for f in ${files[*]} 
do
    inputFile="src\\${f}.elm"
    outputFile="output\\${f}.js"
    printf "Compiling \"${inputFile}\" to \"${outputFile}\".....\n"
    elm make $inputFile --output $outputFile --optimize
    printf "Compressing...\n"
    uglifyjs $outputFile --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters=true,keep_fargs=false,unsafe_comps=true,unsafe=true,passes=2' --output=$outputFile
    printf "Mangling...\n"
    uglifyjs $outputFile --mangle --output=$outputFile
done

printf "Project compiled.\n"
read -p "Press [Enter] to exit."