#!/bin/bash

libs_collection_path="../android/lib/build/intermediates/exploded-aar/"
internal_jar_path="/jars/**"

find ${libs_collection_path}* -name "*.jar" | while read file_path
do
    echo "copying $file_path"

    extricated_of_collection_path=${file_path#$libs_collection_path}
    extricated_of_jar_path=${extricated_of_collection_path%%$internal_jar_path}

    if [[ $extricated_of_collection_path == *"jars/libs/internal_impl"* ]]; then
        extricated_of_jar_path+="-internal"
    fi

    extracted_lib_path=${extricated_of_jar_path#*/}
    lib_name=${extracted_lib_path////-}

    cp $file_path "temp/android/$lib_name.jar"
done