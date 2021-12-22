#!/bin/bash
for filename in temp/android/*.jar; do
  if [[ "${filename##*/}" != "libAirFacebook.jar" ]];then
    echo "<packagedDependency>${filename##*/}</packagedDependency>"
  fi


done