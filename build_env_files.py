import json

fablo_dict = json.load(open('./fablo-config.json', 'r'))
json_config_file = {
    "port": 3003,
    "orgs": {},
    "channels": {},
    "chaincodes": fablo_dict['chaincodes']
}

# Add orgs
for i in fablo_dict['orgs']:
    org_name = i['organization']['name']
    domain = i['organization']['domain']

    connectionProfile = json.load(
        open(
            f'./fablo-target/fabric-config/connection-profiles/connection-profile-{org_name.lower()}.json',
            'r'
        )
    )

    certificate = open(
        f'./fablo-target/fabric-config/crypto-config/peerOrganizations/{domain}/users/User1@{domain}/msp/signcerts/User1@{domain}-cert.pem',
        'r'
    )

    privateKey = open(
        f'./fablo-target/fabric-config/crypto-config/peerOrganizations/{domain}/users/User1@{domain}/msp/keystore/priv-key.pem',
        'r'
    )

    json_config_file['orgs'][org_name] = {
        "msp": i['organization']['name'] + "MSP",
        "connectionProfile": json.dumps(connectionProfile),
        "certificate": str(certificate.read()),
        "privateKey": str(privateKey.read())
    }

# Add channels
for i in fablo_dict['channels']:
    json_config_file['channels'][i['name']] = {
        "acceptOrgs": [
            j['name']
            for j in i['orgs']
        ]
    }


LOCALS_TO_SAVE = [
    "./rest-api/env.json",
]

# Saving file
for local_to_save in LOCALS_TO_SAVE:
    with open(local_to_save, "w") as outfile:
        outfile.write(json.dumps(json_config_file, indent=4))
