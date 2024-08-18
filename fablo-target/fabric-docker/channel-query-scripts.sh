#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "peternak" ] && [ "$3" = "peer0" ]; then

    peerChannelList "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041"

  elif
    [ "$1" = "list" ] && [ "$2" = "admin" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.admin.peternakan.com" "peer0.admin.peternakan.com:7061"

  elif
    [ "$1" = "list" ] && [ "$2" = "dkpp" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.dkpp.peternakan.com" "peer0.dkpp.peternakan.com:7081"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "ternak-channel" ] && [ "$3" = "peternak" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "ternak-channel" "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "ternak-channel" ] && [ "$4" = "peternak" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "ternak-channel" "cli.peternak.peternakan.com" "$TARGET_FILE" "peer0.peternak.peternakan.com:7041"

  elif [ "$1" = "fetch" ] && [ "$3" = "ternak-channel" ] && [ "$4" = "peternak" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "ternak-channel" "cli.peternak.peternakan.com" "${BLOCK_NAME}" "peer0.peternak.peternakan.com:7041" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list peternak peer0"
  echo -e "\t List channels on 'peer0' of 'Peternak'".
  echo ""

  echo "fablo channel list admin peer0"
  echo -e "\t List channels on 'peer0' of 'Admin'".
  echo ""

  echo "fablo channel list dkpp peer0"
  echo -e "\t List channels on 'peer0' of 'DKPP'".
  echo ""

  echo "fablo channel getinfo ternak-channel peternak peer0"
  echo -e "\t Get channel info on 'peer0' of 'Peternak'".
  echo ""
  echo "fablo channel fetch config ternak-channel peternak peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Peternak'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> ternak-channel peternak peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Peternak'".
  echo ""

}
