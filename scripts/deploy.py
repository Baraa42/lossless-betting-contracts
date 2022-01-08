from brownie import network, config, interface, AaveLossless
from scripts.helpful_scripts import get_account
from scripts.get_weth import get_weth
from web3 import Web3
import time

# 0.1
AMOUNT = Web3.toWei(0.5, "ether")


def main():
    account = get_account()
    account_1 = get_account(index=1)
    account_2 = get_account(index=2)
    account_3 = get_account(index=3)
    account_4 = get_account(index=4)
    account_5 = get_account(index=5)
    account_6 = get_account(index=6)
    erc20_address = config["networks"][network.show_active()]["weth_token"]
    ierc20 = interface.IERC20(erc20_address)
    if network.show_active() in ["mainnet-fork"]:
        get_weth()
    lending_pool = get_lending_pool()
    start_block = 13967665
    finish_block = start_block + 50
    lossless_aave = AaveLossless.deploy(
        erc20_address,
        lending_pool.address,
        start_block,
        finish_block,
        {"from": account},
    )
    print(f"Lossless_Aave Deployed at {lossless_aave}")
    print("Approving the sponsoring amount")
    tx_approve = approve_erc20(AMOUNT, lossless_aave.address, erc20_address, account)
    tx_approve.wait(1)
    print("Approved! now sponsoring the Lossless contract")
    tx_sponsor = lossless_aave.sponsor(AMOUNT, {"from": account})
    tx_sponsor.wait(1)
    total_deposits = lossless_aave.totalDeposits()
    print(f"Total deposits in the contract : {total_deposits/10**18} Weth")
    fund_accounts()
    place_bets(lossless_aave)
    print("setting winner")
    for _ in range(80):
        tx = account.transfer(account_1, "0.01 ether")
        tx.wait(1)
    tx_set_winner = lossless_aave.setMatchWinnerAndWithdrawFromPool(
        3, {"from": account}
    )
    tx_set_winner.wait(1)
    print(f"Winner is {lossless_aave.winner()}")
    print(f"balance of {account} is {lossless_aave.playerBalance(account)}")
    print(f"balance of {account_1} is {lossless_aave.playerBalance(account_1)}")
    print(f"balance of {account_2} is {lossless_aave.playerBalance(account_2)}")
    print(f"balance of {account_3} is {lossless_aave.playerBalance(account_3)}")
    print(f"balance of {account_4} is {lossless_aave.playerBalance(account_4)}")
    print(f"balance of {account_5} is {lossless_aave.playerBalance(account_5)}")
    print(f"balance of {account_6} is {lossless_aave.playerBalance(account_6)}")
    print(f"balance of contract in weth is {ierc20.balanceOf(lossless_aave)}")

    tx_withdraw = lossless_aave.withdraw({"from": account})
    tx_withdraw.wait(1)
    tx_withdraw1 = lossless_aave.withdraw({"from": account_1})
    tx_withdraw1.wait(1)
    tx_withdraw2 = lossless_aave.withdraw({"from": account_2})
    tx_withdraw2.wait(1)
    tx_withdraw3 = lossless_aave.withdraw({"from": account_3})
    tx_withdraw3.wait(1)
    tx_withdraw4 = lossless_aave.withdraw({"from": account_4})
    tx_withdraw4.wait(1)
    tx_withdraw5 = lossless_aave.withdraw({"from": account_5})
    tx_withdraw5.wait(1)
    tx_withdraw6 = lossless_aave.withdraw({"from": account_6})
    tx_withdraw6.wait(1)

    print(f"balance of {account} is {lossless_aave.playerBalance(account)}")
    print(f"balance of {account_1} is {lossless_aave.playerBalance(account_1)}")
    print(f"balance of {account_2} is {lossless_aave.playerBalance(account_2)}")
    print(f"balance of {account_3} is {lossless_aave.playerBalance(account_3)}")
    print(f"balance of {account_4} is {lossless_aave.playerBalance(account_4)}")
    print(f"balance of {account_5} is {lossless_aave.playerBalance(account_5)}")
    print(f"balance of {account_6} is {lossless_aave.playerBalance(account_6)}")

    print(f"balance of contract in weth is {ierc20.balanceOf(lossless_aave)}")

    print(f"token balance of {account} is {ierc20.balanceOf(account)}")
    print(f"token balance of {account_1} is {ierc20.balanceOf(account_1)}")
    print(f"token balance of {account_2} is {ierc20.balanceOf(account_2)}")
    print(f"token balance of {account_3} is {ierc20.balanceOf(account_3)}")
    print(f"token balance of {account_4} is {ierc20.balanceOf(account_4)}")
    print(f"token balance of {account_5} is {ierc20.balanceOf(account_5)}")
    print(f"token balance of {account_6} is {ierc20.balanceOf(account_6)}")


def approve_erc20(amount, spender, erc20_address, account):
    print("Approving ERC20 token...")
    erc20 = interface.IERC20(erc20_address)
    tx = erc20.approve(spender, amount, {"from": account})
    tx.wait(1)
    print("Approved!")
    return tx


def get_lending_pool():
    lending_pool_addresses_provider = interface.ILendingPoolAddressesProvider(
        config["networks"][network.show_active()]["lending_pool_addresses_provider"]
    )
    lending_pool_address = lending_pool_addresses_provider.getLendingPool()
    lending_pool = interface.ILendingPool(lending_pool_address)
    return lending_pool


def fund_accounts():
    account = get_account()
    account_1 = get_account(index=1)
    account_2 = get_account(index=2)
    account_3 = get_account(index=3)
    account_4 = get_account(index=4)
    account_5 = get_account(index=5)
    account_6 = get_account(index=6)
    erc20_address = config["networks"][network.show_active()]["weth_token"]
    ierc20 = interface.IERC20(erc20_address)
    print("Sending Weth to other accounts!")
    print("Sending 0.1 WETH to account_1")
    tx_send1 = ierc20.transfer(account_1, AMOUNT / 5, {"from": account})
    tx_send1.wait(1)
    print("Sent to account_1")
    print("Sending 0.2 WETH to account_2")
    tx_send2 = ierc20.transfer(account_2, 2 * AMOUNT / 5, {"from": account})
    tx_send2.wait(1)
    print("Sent to account_2")
    print("Sending 0.3 WETH to account_3")
    tx_send3 = ierc20.transfer(account_3, 3 * AMOUNT / 5, {"from": account})
    tx_send3.wait(1)
    print("Sent to account_3")
    print("Sending 0.4 WETH to account_4")
    tx_send4 = ierc20.transfer(account_4, 4 * AMOUNT / 5, {"from": account})
    tx_send4.wait(1)
    print("Sent to account_4")
    print("Sending 0.2 WETH to account_5")
    tx_send5 = ierc20.transfer(account_5, 2 * AMOUNT / 5, {"from": account})
    tx_send5.wait(1)
    print("Sent to account_5")
    print("Sending 0.2 WETH to account_6")
    tx_send6 = ierc20.transfer(account_6, 2 * AMOUNT / 5, {"from": account})
    tx_send6.wait(1)
    print("Sent to account_6")


def place_bets(lossless_aave):
    account_1 = get_account(index=1)
    account_2 = get_account(index=2)
    account_3 = get_account(index=3)
    account_4 = get_account(index=4)
    account_5 = get_account(index=5)
    account_6 = get_account(index=6)
    erc20_address = config["networks"][network.show_active()]["weth_token"]

    tx_approve1 = approve_erc20(
        AMOUNT / 5, lossless_aave.address, erc20_address, account_1
    )
    tx_approve1.wait(1)
    tx_bet1 = lossless_aave.placeBet(1, AMOUNT / 5, {"from": account_1})
    tx_bet1.wait(1)
    print(f"account_1 points : {lossless_aave.playerHomePoints(account_1)}")

    tx_approve2 = approve_erc20(
        2 * AMOUNT / 5, lossless_aave.address, erc20_address, account_2
    )
    tx_approve2.wait(1)
    tx_bet2 = lossless_aave.placeBet(2, 2 * AMOUNT / 5, {"from": account_2})
    tx_bet2.wait(1)
    print(f"account_2 points : {lossless_aave.playerAwayPoints(account_2)}")

    tx_approve3 = approve_erc20(
        3 * AMOUNT / 5, lossless_aave.address, erc20_address, account_3
    )
    tx_approve3.wait(1)
    tx_bet3 = lossless_aave.placeBet(1, 3 * AMOUNT / 5, {"from": account_3})
    tx_bet3.wait(1)
    print(f"account_3 points : {lossless_aave.playerHomePoints(account_3)}")

    tx_approve4 = approve_erc20(
        4 * AMOUNT / 5, lossless_aave.address, erc20_address, account_4
    )
    tx_approve4.wait(1)
    tx_bet4 = lossless_aave.placeBet(2, 4 * AMOUNT / 5, {"from": account_4})
    tx_bet4.wait(1)
    print(f"account_4 points : {lossless_aave.playerAwayPoints(account_4)}")

    tx_approve5 = approve_erc20(
        2 * AMOUNT / 5, lossless_aave.address, erc20_address, account_5
    )
    tx_approve5.wait(1)
    tx_bet5 = lossless_aave.placeBet(3, 2 * AMOUNT / 5, {"from": account_5})
    tx_bet5.wait(1)
    print(f"account_5 points : {lossless_aave.playerAwayPoints(account_5)}")

    tx_approve6 = approve_erc20(
        2 * AMOUNT / 5, lossless_aave.address, erc20_address, account_6
    )
    tx_approve6.wait(1)
    tx_bet6 = lossless_aave.placeBet(3, 2 * AMOUNT / 5, {"from": account_6})
    tx_bet6.wait(1)
    print(f"account_6 points : {lossless_aave.playerAwayPoints(account_6)}")
