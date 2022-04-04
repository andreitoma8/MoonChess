from brownie import MoonChessCollection, MoonChessGame, MoonChessToken, accounts, config


def main():
    account = accounts.add(config["wallets"]["from_key"])
    d1 = MoonChessCollection.deploy({"from": account}, publish_source=True)
    d2 = MoonChessToken.deploy({"from": account}, publish_source=True)
    d1_address = d1.address
    d2_address = d1.address
    d3 = MoonChessGame.deploy(
        d1_address, d2_address, {"from": account}, publish_source=True
    )
