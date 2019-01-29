module.exports = async (web3, depositsManager, tru, account, minDeposit) => {
    let currentBalance = (await tru.balanceOf.call(account)).toNumber()
    let currentDeposit = (await depositsManager.getDeposit.call(account)).toNumber()

    let totalAssets = currentBalance + currentDeposit

    if (totalAssets < minDeposit) {
        throw 'current account balance + current deposit is less than minimum deposit specified'
    } else {
        let difference = minDeposit - currentDeposit

        if (difference > 0) {
            // console.log("allowance", difference, incentiveLayer.address)
            await tru.approve(depositsManager.address, difference, { from: account })            
            // console.log("deposited", num.toString())
            await depositsManager.makeDeposit(difference, { from: account })
        }
    }
}
