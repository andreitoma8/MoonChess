from brownie import MoonChessCollection, MoonChessToken, MoonChessGame, accounts

DECIMALS = 10 ** 18


def test_main():
    # Set up accounts
    owner = accounts[0]
    user = accounts[1]
    gameWallet = accounts[9]
    # Set up smart contracts
    token = MoonChessToken.deploy({"from": owner})
    collection = MoonChessCollection.deploy(token.address, {"from": owner})
    game = MoonChessGame.deploy(
        token.address, collection.address, gameWallet.address, {"from": owner}
    )
    # Mint ERC20 and approve
    token.mint(100, {"from": user})
    token.approve(collection.address, 100 * DECIMALS, {"from": user})
    # Mint ERC1155 and approve
    collection.mint(1, 5, {"from": user})
    tx = collection.setApprovalForAll(game.address, True, {"from": user})
    tx.wait(1)
    # Check if Collection SC gets paiment for mint
    assert token.balanceOf(collection.address, {"from": user}) == 5 * DECIMALS * 5
    # Check balance of user after mint payment
    assert token.balanceOf(user.address, {"from": user}) == 75 * DECIMALS
    # Withdraw funds from owner
    owner_balance_one = token.balanceOf(owner.address, {"from": owner})
    collection.withdraw(10 * DECIMALS, {"from": owner})
    owner_balance_two = token.balanceOf(owner.address, {"from": owner})
    # Assert if owner recieved payment
    assert owner_balance_one == owner_balance_two - (10 * DECIMALS)
