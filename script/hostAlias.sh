#!/bin/bash
echo "[$1]" >> $4/script/file/hosts
echo "$2 ansible_host=$3" >> $4/script/file/hosts 
echo "" >> $4/script/file/hosts
