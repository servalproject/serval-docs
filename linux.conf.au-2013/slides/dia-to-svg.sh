#!/bin/sh

if [ $# -eq 0 ]; then
   echo "Usage: ${0##*/} [options] foo.dia bar.svg"
   echo "       ${0##*/} [options] foo.dia ..."
   echo "       ${0##*/} [options] foo.dia ... dir"
   echo "Options:"
   echo "   -n, --dry-run    Print but do not execute"
   exit 1
fi

dir="${0%/*}"
exec "${dir:-.}/dia-export.sh" --format=svg "$@"
