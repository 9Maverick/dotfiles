#!/bin/bash

knsregistry_location="$HOME/.local/share/knewstuff3/"

alternative_linkid_items=$(chezmoi execute-template '{{ range .knewstuff.alternativeLinkIds -}}
{{ . }}
{{ end -}}
')

for knsregistry_file in $knsregistry_location*; do
  knsregistry=$(basename ${knsregistry_file%.*})

  count=$(xmllint --xpath 'count(//hotnewstuffregistry/stuff)' $knsregistry_file)

  for ((i = 0; i < $count; i++)); do
    item_name=$(xmllint --xpath "//hotnewstuffregistry/stuff[$i+1]/name/text()" $knsregistry_file)
    item_installedfiles=($(xmllint --xpath "//hotnewstuffregistry/stuff[$i+1]/installedfile/text()" $knsregistry_file))

    for ((j = 0; j < ${#item_installedfiles[@]}; j++)); do
      if [ -e ${item_installedfiles[j]} ]; then
        continue 2
      fi
    done

    echo
    echo ">>> $item_name not found, proceeding to install"
    echo

    item_provider=$(xmllint --xpath "//hotnewstuffregistry/stuff[$i+1]/providerid/text()" $knsregistry_file)
    item_id=$(xmllint --xpath "//hotnewstuffregistry/stuff[$i+1]/id/text()" $knsregistry_file)

    link_id_result=$(echo $alternative_linkid_items | grep -oP "${items_names[i]}:\K\S+")
    link_id=${link_id_result:-1}

    url="kns://$knsregistry.knsrc/$item_provider/$item_id?linkid=$link_id"
    /usr/libexec/kf6/kpackagehandlers/knshandler $url

    # To avoid error 429 (too many requests)
    sleep 3s
  done

done
