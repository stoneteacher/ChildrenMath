#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "Usage: ./$(basename $0) <first number range> <result number range> [count of page] [sub or add]"
  echo "Example: ./$(basename $0) 1-19 0-20 2 add"
  exit 1
fi

lx_mkdir_if_needed() {
  local path
  path="$1"
  if [[ ! -d ${path} ]]; then
    echo "Create dir path -> ${path}"
    mkdir -p "$path"
  fi
}

first_number="$1"
result_number="$2"
count="$3"
type_name="$4"

if [[ -z $count ]]; then
  count=5
else
  count=$(($count))
fi

type_arg=''
if [[ -z $type_name ]]; then
  type_name='混合'
else
  if [[ $type_name == 'add' ]]; then
    type_name='加法'
    type_arg='-a'
  elif [[ $type_name == 'sub' ]]; then
    type_name='减法'
    type_arg='-s'
  fi
fi

dir_name="${type_name}_${first_number}_${result_number}_${count}"
lx_mkdir_if_needed ${dir_name}

filename_prefix="A"
for ((i = 1; i <= $count; i++)); do
  ./bin/chmath -r ${result_number} -f ${first_number} ${type_arg} > "${dir_name}/${filename_prefix}_${i}.txt"
done

tar_filename="${dir_name}.tar.gz"
tar -zcf "${tar_filename}" "${dir_name}"
echo -e "Tar done!\nFile -> ${tar_filename}"
