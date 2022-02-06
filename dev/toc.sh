#!/usr/bin/env sh

## Produces Table of Contents (ToC) for simple markdown files

red="\033[31m"
#nocolor="\033[0m"

error_msg(){ printf %s"${red}ERROR: ${1}\n" >&2; exit 1; }

test -f "${1}" || error_msg "file '${1}' doesn't exist"

grep "^#" "${1}" | while IFS="$(printf '\n')" read -r line; do
  ## empty header should not exist
  [ -z "${line}" ] && error_msg "Empty header"
  ## clean header that have link reference
  line_md="$(printf '%s\n' "${line}" | sed "s|](.*||;s|\[||")"
  ## set header indentation
  line_md="$(printf '%s\n' "${line_md}" | sed "s|######|            -|;s|#####|         -|;s|####|      -|;s|###|    -|;s|##|  -|;s|#|-|")"
  ## set link content
  line_content="$(printf '%s\n' "${line_md}" | sed "s/.*- /#/;s| |-|g;s|'||" | tr "[:upper:]" "[:lower:]")"
  ## set link reference
  line_md="$(printf '%s\n' "${line_md}" | sed "s|- |- [|;s|$|](${line_content})|")"
  ## print header
  printf '%s\n' "${line_md}"
  ## check if header was already printed before
  printf '%s\n' "${cache_line}" | grep -q -- "${line}" && error_msg "Header \"${line}\" is repeated"
  ## save header to cache to check later if it was already printed
  # shellcheck disable=SC2030
  cache_line="$(printf '%s\n%s\n' "${cache_line}" "${line}")"
done
