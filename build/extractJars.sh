#!/bin/bash

libs_collection_path="../android/build/intermediates/exploded-aar/"
internal_jar_path="/jars/classes.jar"

find ${libs_collection_path}* -name "*.jar" | while read file_path
do
    echo "copying $file_path"

    extricated_of_collection_path=${file_path#$libs_collection_path}

    if [[ $file_path == *"classes.jar"* ]]; then

        extricated_of_jar_path=${extricated_of_collection_path%$internal_jar_path}
        extracted_lib_path=${extricated_of_jar_path#*/}
        lib_name=${extracted_lib_path////-}

        cp $file_path "temp/android/$lib_name.jar"
    else
        cp $file_path "temp/android/"
    fi
done