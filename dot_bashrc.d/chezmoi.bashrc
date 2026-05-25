#!/bin/bash

managed_files=$(chezmoi managed)

dotfiles-diff-excluded() {
  chezmoi execute-template '{{ range .files.diff.exclude -}}
{{ . }}
{{ end -}}'
}

diff_exclusions=$(dotfiles-diff-excluded)

dotfiles-format() {
  for file in $managed_files; do
    target=$HOME/$file
    case $file in
    *.json)
      echo "$(jq . $target)" >$target
      ;;
    *)
      continue
      ;;
    esac
  done
}

dotfiles-diff() {
  dotfiles-format

  for file in $managed_files; do

    excluded=false
    for exclusion in $diff_exclusions; do
      if [[ $file == $exclusion ]]; then
        excluded=true
      fi
    done

    if $excluded; then
      continue
    fi

    chezmoi diff "$HOME/$file" --reverse
  done
}
