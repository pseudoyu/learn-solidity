from brownie import network, config, accounts


def get_account():
    if network.show_active() == "development":
        # 1. With local ganache accounts
        # brownie run scripts/deploy.py
        return accounts[0]
    else:
        # brownie run scripts/deploy.py --network rinkeby
        # 2. With accounts generated using commandline
        # brownie accounts new xxx
        # brownie accounts delete xxx
        # brownie accounts list

        # return accounts.load("pseudoyu")

        # 3. With environment variables
        # return os.getenv("PRIVATE_KEY")

        # 4. With brownie-config.yaml
        return accounts.add(config["wallets"]["from_key"])
