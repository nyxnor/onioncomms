#!/usr/bin/env sh

## Produces Table of Contents (ToC) for simple markdown files
## Requirement: header is set by hashtag '#'
## $1 = FILE.md

red="\033[31m"
#nocolor="\033[0m"

error_msg(){ printf %s"${red}ERROR: ${1}\n" >&2; exit 1; }

test -f "${1}" || error_msg "file '${1}' doesn't exist"

trap 'rm -f toc.tmp' EXIT INT

while IFS="$(printf '\n')" read -r line; do
  ## extract code blocks
  code="${code:-0}"
  [ "${code}" -eq 0 ] && printf '%s\n' "${line}" | grep "^#"
  case "${line}" in
    \`\`\`*)
      case "${code}" in
        1) code=0;;
        0|*) code=1;;
      esac
    ;;
  esac
done < "${1}" > toc.tmp


while IFS="$(printf '\n')" read -r line; do
  ## clean header that have link reference
  line_md="$(printf '%s\n' "${line}" | sed "s|](.*||;s|\[||;s/\]//g")"
  ## remove special characters
  #line_md="$(printf '%s\n' "${line_md}" | tr "|" "-" | tr -cd "[:alnum:] ")"
  ## set header indentation
  line_md="$(printf '%s\n' "${line_md}" | sed "s|######|            -|;s|#####|         -|;s|####|      -|;s|###|    -|;s|##|  -|;s|#|-|")"
  ## set link content
  line_content="$(printf '%s\n' "${line_md}" | sed "s/.*- /#/;s| |-|g;s|'||g;s|]||g;s/|/-/g" | tr "[:upper:]" "[:lower:]" | tr -cd "[:alnum:]-._")"
  ## set link reference
  line_md="$(printf '%s\n' "${line_md}" | sed "s|- |- [|;s|$|](#${line_content})|")"
  ## print header
  printf '%s\n' "${line_md}"
  ## check if header was already printed before
  printf '%s\n' "${cache_line}" | grep -q -- "${line}" && error_msg "Header \"${line}\" is repeated]"
  ## save header to cache to check later if it was already printed
  # shellcheck disable=SC2030
  cache_line="$(printf '%s\n%s\n' "${cache_line}" "${line}")"
done < toc.tmp
