from brownie import network, accounts, config, MockV3Aggregator

from web3 import Web3

DECIMALS = 8
STARTING_PRICE = 200000000000

def get_account():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print(f"Deploying the mocks!")
    MockV3Aggregator.deploy(
        DECIMALS, 
        STARTING_PRICE, 
        {"from": get_account()}
    )
    print(f"Mocks Deployed!")
