#!/bin/bash

knsregistry_location="$HOME/.local/share/knewstuff3/"

for knsregistry_file in $knsregistry_location*; do
  knsregistry=$(basename ${knsregistry_file%.*})

  providers=($(grep -oP "<providerid>\K\S+(?=<)" $knsregistry_file))
  items_ids=($(grep -oP "<id>\K\S+(?=<)" $knsregistry_file))
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

    url="kns://$knsregistry.knsrc/$item_provider/$item_id"
    /usr/libexec/kf6/kpackagehandlers/knshandler $url

    # To avoid error 429 (too many requests)
    sleep 1s
  done

done
