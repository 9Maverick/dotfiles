#!/bin/bash

knsregistry_location="$HOME/.local/share/knewstuff3/"

alternative_linkid_items=$(chezmoi execute-template '{{ range .knewstuff.alternativeLinkIds -}}
{{ . }}
{{ end -}}
')

for knsregistry_file in $knsregistry_location*; do
  knsregistry=$(basename ${knsregistry_file%.*})

  providers=($(grep -oP "<providerid>\K\S+(?=<)" $knsregistry_file))
  items_ids=($(grep -oP "<id>\K\S+(?=<)" $knsregistry_file))
  mapfile -t items_names <<<$(grep -oP "<name>\K(\S|\s)+(?=<)" $knsregistry_file)
  if [[ ${#providers[@]} != ${#items_ids[@]} ]]; then
    echo ">>> ERROR: mismatch of providers and ids number:"
    echo ">>> providers count: ${#providers[@]}"
    echo ">>> providers items:" "${providers[@]}"
    echo ">>> ids count: ${#items_ids[@]}"
    echo ">>> ids items:" "${items_ids[@]}"
    echo ">>> filename: $knsregistry_file"
  fi
  count=${#items_ids[@]}

  for ((i = 0; i < $count; i++)); do
    item_provider=${providers[i]}
    item_id=${items_ids[i]}

    link_id_result=$(echo $alternative_linkid_items | grep -oP "${items_names[i]}:\K\S+")
    link_id=${link_id_result:-1}

    url="kns://$knsregistry.knsrc/$item_provider/$item_id?linkid=$link_id"
    /usr/libexec/kf6/kpackagehandlers/knshandler $url

    # To avoid error 429 (too many requests)
    sleep 3s
  done

done
