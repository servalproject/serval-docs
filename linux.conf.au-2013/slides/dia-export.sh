#!/bin/sh

set -e

tmpdir="${TMPDIR:-/tmp}"
tmphome="$tmpdir/${USER?}"
mkdir -p "$tmphome"

if [ $# -eq 0 ]; then
   echo "Usage: ${0##*/} [options] foo.dia bar.svg"
   echo "       ${0##*/} [options] foo.dia bar.png"
   echo "       ${0##*/} -F svg|png [options] foo.dia ..."
   echo "       ${0##*/} -F svg|png [options] foo.dia ... dir"
   echo "Options:"
   echo "   -n, --dry-run     Print but do not execute"
   echo "   -F, --format=FMT  Convert Dia files to FMT (svg or png)"
   exit 1
fi

set_format() {
   case "$1" in
   svg) format=svg; options=; ext=svg;;
   png) format=png; options="--size=1280x"; ext=png;;
   *) echo "${0##*/}: unsupported format '$1'" >&2; exit 1;;
   esac
}

check_format() {
   if [ "$format" = "" ]; then
      echo "${0##*/}: missing --format option" >&2
      exit 1
   fi
}

dry_run=false
unset format
while [ $# -ne 0 ]; do
   case "$1" in
   -n|--dry-run) dry_run=true; shift;;
   -F|--format) shift; set_format "${1?}"; shift;;
   --format=*) set_format "${1#*=}"; shift;;
   -*) echo "${0##*/}: unsupported option: $1" >&2; exit 1;;
   *) break;;
   esac
done

convert() {
   check_format
   set -- dia --filter="$format" $options --export="$2" "$1"
   for arg; do
      case "$arg" in
      '' | *[!A-Za-z_0-9.,:=+\/-]* ) echo -n "'$(echo "$arg" | sed "s/'/'\\''/g")' ";;
      *) echo -n "$arg ";;
      esac
   done
   echo
   if ! $dry_run; then
      HOME="$tmphone" "$@"
   fi
}

eval dir=\"\$$#\"
if [ -d "$dir" ]; then
   check_format
   while [ $# -gt 1 ]; do
      base="${1##*/}"
      convert "$1" "$dir/${base%.dia}.$ext"
      shift
   done
   exit 0
fi

if [ $# -eq 2 -a "${2%.*}" != "$2" -a "${2%.dia}" = "$2" ]; then
   set_format "${2##*.}"
   convert "$1" "$2"
   exit 0
fi

check_format
for arg; do
   convert "$arg" "${arg%.dia}.$ext"
done
exit 0
