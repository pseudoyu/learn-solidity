const { deployments, ethers, getNamedAccounts } = require("hardhat")
const { assert } = require("chai")

describe("FundMe", async () => {
    let fundMe, deployer, MockV3Aggregator
    beforeEach(async () => {
        // 使用 hardhat-deploy 部署合约
        // const { accounts } = await ethers.getSigners()
        // const accountZero = accounts[0]
        deployer = (await getNamedAccounts()).deployer
        await deployments.fixture(["all"])
        fundMe = await ethers.getContract("FundMe", deployer)
        MockV3Aggregator = await ethers.getContract(
            "MockV3Aggregator",
            deployer
        )
    })

    // 测试构造函数
    describe("constructor", async () => {
        it("Should set the aggregator addresses correctly", async () => {
            const response = await fundMe.priceFeed()
            assert.equal(response, MockV3Aggregator.address)
        })
    })
})
