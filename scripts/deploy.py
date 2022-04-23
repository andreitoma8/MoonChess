from brownie import MoonChessCollection, MoonChessGame, MoonChessToken, accounts, config


def main():
    account = accounts.add(config["wallets"]["from_key"])
    d1 = MoonChessToken.deploy({"from": account})
    d1_address = d1.address
    d2 = MoonChessCollection.deploy(d1_address, {"from": account})
    d2_address = d2.address
    d3 = MoonChessGame.deploy(d2_address, d1_address, {"from": account})
    d1.approve(d3.address, 1000 * 10 ** 18, {"from": account})
