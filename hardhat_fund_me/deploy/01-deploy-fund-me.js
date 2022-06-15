// 模板 1
// // 定义部署方法
// function deployFunc(hre) {
//     console.log("Deploying fund me...")
// }

// // 设置默认部署方法
// module.exports.default = deployFunc

// 模板 2
// module.exports = async (hre) => {
//     // 提取 hre 中需要用的方法
//     const { getNamedAccounts, deployments } = hre
// }

// const helperConfig = require("./helper-hardhat-config")
// networkConfig = helperConfig.networkConfig
const { networkConfig, developmentChain } = require("../helper-hardhat-config")
const { network } = require("hardhat")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let ethUsdPriceFeedAddress
    if (developmentChain.includes(network.name)) {
        // 本地测试时我们可以使用 mock 数据
        const ethUsdAggregator = await get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        // 非本地环境读取 helper 变量值
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [
            /* price feed addresses */
            ethUsdPriceFeedAddress,
        ],
        log: true,
    })
}

module.exports.tags = ["all", "fundme"]
