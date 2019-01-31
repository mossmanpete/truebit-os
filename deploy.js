
let argv = require('minimist')(process.argv.slice(2));

let host = argv.host || 'http://localhost:8545'

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider(host))
const fs = require('fs')
const getNetwork = async () => { return await web3.eth.net.getNetworkType() }

const base = './build/'

function getArtifacts(name) {
    return {
        abi: JSON.parse(fs.readFileSync(base + name + '.abi')),
        bin: fs.readFileSync(base + name + '.bin')
    }
}

async function deployContract(name, options = {}, args = []) {
    let artifacts = getArtifacts(name)
    // console.log(name, artifacts.abi, "0x"+artifacts.bin, options)
    let contract = new web3.eth.Contract(artifacts.abi)
    let res = await contract
        .deploy({ data: "0x" + artifacts.bin, arguments: args })
        .send(options)
    res.abiModel = { abi: artifacts.abi }
    return res
}

function exportContract(contract) {
    return {
        address: contract.options.address,
        abi: contract.abiModel.abi
    }
}

async function deploy() {
    let networkName = await getNetwork(web3)
    let filename = './wasm-client/' + networkName + '.json'
    console.log("Writing to", filename)

    let accounts = await web3.eth.getAccounts()

    let registry = await deployContract('TruebitRegistry', {from: accounts[0], gas: 3000000})
	    
    console.log("REGISTRY")
    let filesystem = await deployContract('Filesystem', {from: accounts[0], gas: 5500000})

    let judge = await deployContract('Judge', {from: accounts[0], gas: 5600000})
    
    let disputeResolutionLayer = await deployContract('Interactive', {from: accounts[0], gas: 5500000}, [judge.options.address])

    let tru = await deployContract('TRU', {from: accounts[0], gas: 2000000})

    console.log("TRU")

    let exchangeRateOracle = await deployContract('ExchangeRateOracle', {from: accounts[0], gas: 1000000})

    console.log("EXCHANGE")

    let jackpotManager

    if (process.env.NODE_ENV == 'production') {
	jackpotManager = await deployContract('JackpotManager', {from: accounts[0], gas: 1000000}, [tru.options.address])
    } else {
	jackpotManager = await deployContract('NeverJackpotManager', {from: accounts[0], gas: 1000000}, [tru.options.address])
	//jackpotManager = await deployContract('AlwaysJackpotManager', {from: accounts[0], gas: 500000}, [tru._address])
    }
    
    let incentiveLayer = await deployContract('IncentiveLayer', {from: accounts[0], gas: 5200000}, [registry.options.address])

    console.log("INCENTIVE")	

    let depositsManager = await deployContract('DepositsManager', {from: accounts[0], gas: 1000000}, [tru.options.address, incentiveLayer.options.address])

    console.log("DEPOSITS")

    let rewardsManager = await deployContract('RewardsManager', {from: accounts[0], gas: 3000000}, [tru.options.address])

    console.log("REWARDS")

    await registry.methods.setContracts(
	tru.options.address,
	exchangeRateOracle.options.address,
	filesystem.options.address,
	jackpotManager.options.address,
	depositsManager.options.address,
	rewardsManager.options.address,
	incentiveLayer.options.address,
	disputeResolutionLayer.options.address
    ).send({from: accounts[0], gas: 300000})
    
    // tru.methods.transferOwnership(incentiveLayer._address).send({from: accounts[0], gas: 1000000})

    let wait = 0
    if (networkName == "kovan") wait = 10000
    else if (networkName == "rinkeby") wait = 15000
    else if (networkName == "ropsten") wait = 30000

    fs.writeFileSync(filename, JSON.stringify({
        WAIT_TIME: wait,
        fileSystem: exportContract(filesystem),
        judge: exportContract(judge),
        interactive: exportContract(disputeResolutionLayer),
        tru: exportContract(tru),
        exchangeRateOracle: exportContract(exchangeRateOracle),
        incentiveLayer: exportContract(incentiveLayer),
	jackpotManager: exportContract(jackpotManager),
	depositsManager: exportContract(depositsManager),
	rewardsManager: exportContract(rewardsManager)
    }))

    // Set exchange rate oracle for testing, main net should come from external data source (dex, oraclize, etc..)
    const TRUperUSD = 2000
    await exchangeRateOracle.methods.updateExchangeRate(TRUperUSD).send({from: accounts[0]})

    // Mint tokens for testing
    accounts.forEach(async addr => {
        await tru.methods.addMinter(addr).send({from:accounts[0], gas: 300000})
        await tru.methods.mint(addr, "100000000000000000000000").send({from:addr, gas: 300000})
    })

    if (networkName == "kovan" || networkName == "rinkeby" || networkName == "ropsten" || networkName == "private") {
        tru.methods.enableFaucet().send({from:accounts[0], gas: 300000})
    }

}

deploy()
