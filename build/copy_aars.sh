#!/bin/bash

libs_collection_path="../android/build/intermediates/exploded-aar"
internal_jar_path="/jars/classes.jar"

find ${libs_collection_path}/* -name "classes.jar" | while read file_path
do
    extricated_of_jar_path=${file_path%$internal_jar_path}
    extricated_of_collection_path=${extricated_of_jar_path#$libs_collection_path}
    extracted_lib_path=${extricated_of_collection_path#*/}
    lib_name=${extracted_lib_path////-}

    echo copying $lib_name
    cp $file_path "temp/android/$lib_name.jar"
done