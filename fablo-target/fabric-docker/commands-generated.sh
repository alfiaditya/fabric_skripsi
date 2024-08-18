#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for PeternakanOrderer" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-peternakanorderer.yaml" "peerOrganizations/orderer.peternakan.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Peternak" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-peternak.yaml" "peerOrganizations/peternak.peternakan.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Admin" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-admin.yaml" "peerOrganizations/admin.peternakan.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for DKPP" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-dkpp.yaml" "peerOrganizations/dkpp.peternakan.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group peternakan-ordeerer-group" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "Peternakan-ordeerer-groupGenesis"

  # Create directory for chaincode packages to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'ternak-channel'" "U1F913"
  createChannelTx "ternak-channel" "$FABLO_NETWORK_ROOT/fabric-config" "TernakChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'ternak-channel' on Peternak/peer0" "U1F63B"
  docker exec -i cli.peternak.peternakan.com bash -c "source scripts/channel_fns.sh; createChannelAndJoin 'ternak-channel' 'PeternakMSP' 'peer0.peternak.peternakan.com:7041' 'crypto/users/Admin@peternak.peternakan.com/msp' 'orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030';"

}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode")" ]; then
    local version="1.0.0"
    printHeadline "Packaging chaincode 'ternak-chaincode'" "U1F60E"
    chaincodeBuild "ternak-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode" "16"
    chaincodePackage "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" "node" printHeadline "Installing 'ternak-chaincode' for Peternak" "U1F60E"
    chaincodeInstall "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" ""
    chaincodeApprove "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" ""
    printItalics "Committing chaincode 'ternak-chaincode' on channel 'ternak-channel' as 'Peternak'" "U1F618"
    chaincodeCommit "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" "peer0.peternak.peternakan.com:7041" "" ""
  else
    echo "Warning! Skipping chaincode 'ternak-chaincode' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "ternak-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode")" ]; then
      printHeadline "Packaging chaincode 'ternak-chaincode'" "U1F60E"
      chaincodeBuild "ternak-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode" "16"
      chaincodePackage "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" "node" printHeadline "Installing 'ternak-chaincode' for Peternak" "U1F60E"
      chaincodeInstall "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" ""
      chaincodeApprove "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" ""
      printItalics "Committing chaincode 'ternak-chaincode' on channel 'ternak-channel' as 'Peternak'" "U1F618"
      chaincodeCommit "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" "peer0.peternak.peternakan.com:7041" "" ""

    else
      echo "Warning! Skipping chaincode 'ternak-chaincode' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "ternak-chaincode" ]; then
    local version="1.0.0"
    printHeadline "Approving 'ternak-chaincode' for Peternak (dev mode)" "U1F60E"
    chaincodeApprove "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "1.0.0" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" ""
    printItalics "Committing chaincode 'ternak-chaincode' on channel 'ternak-channel' as 'Peternak' (dev mode)" "U1F618"
    chaincodeCommit "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "1.0.0" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" "peer0.peternak.peternakan.com:7041" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "ternak-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode")" ]; then
      printHeadline "Packaging chaincode 'ternak-chaincode'" "U1F60E"
      chaincodeBuild "ternak-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode" "16"
      chaincodePackage "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" "node" printHeadline "Installing 'ternak-chaincode' for Peternak" "U1F60E"
      chaincodeInstall "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-chaincode" "$version" ""
      chaincodeApprove "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" ""
      printItalics "Committing chaincode 'ternak-chaincode' on channel 'ternak-channel' as 'Peternak'" "U1F618"
      chaincodeCommit "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com:7041" "ternak-channel" "ternak-chaincode" "$version" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030" "" "false" "" "peer0.peternak.peternakan.com:7041" "" ""

    else
      echo "Warning! Skipping chaincode 'ternak-chaincode' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/ternak-chaincode'"
    fi
  fi
}

notifyOrgsAboutChannels() {
  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "ternak-channel" "PeternakMSP" "TernakChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannel "ternak-channel" "PeternakMSP" "cli.peternak.peternakan.com" "peer0.peternak.peternakan.com" "orderer0.peternakan-ordeerer-group.orderer.peternakan.com:7030"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "ternak-channel" "PeternakMSP" "cli.peternak.peternakan.com"
}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose down)

  printf "Removing chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.peternak.peternakan.com-ternak-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.peternak.peternakan.com-ternak-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "Removing generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
