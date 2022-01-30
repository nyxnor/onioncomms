#!/usr/bin/env sh

## Produces Table of Contents (ToC) for simple markdown files

red="\033[31m"
nocolor="\033[0m"

error_msg(){ printf %s"${red}ERROR: ${1}\n" >&2; exit 1; }

test -f "${1}" || error_msg "file '${1}' doesn't exist"

grep "^#" "${1}" | while IFS="$(printf '\n')" read -r line; do
  [ -z "${line}" ] && return
  line_md="$(printf '%s\n' "${line}" | sed "s|######|            -|;s|#####|         -|;s|####|      -|;s|###|    -|;s|##|  -|;s|#|-|")"
  line_content="$(printf '%s\n' "${line_md}" | sed "s/.*- /#/;s| |-|g;s|'||" | tr "[:upper:]" "[:lower:]")"
  line_md="$(printf '%s\n' "${line_md}" | sed "s|- |- [|;s|$|](${line_content})|")"
  printf '%s\n' "${line_md}"
  printf '%s\n' "${cache_line}" | grep -q -- "${line}" && error_msg "Header \"${line}\" is repeated"
  # shellcheck disable=SC2030
  cache_line="$(printf '%s\n%s\n' "${cache_line}" "${line}")"
done
