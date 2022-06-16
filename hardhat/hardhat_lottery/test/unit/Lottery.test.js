const { assert, expect } = require("chai")
const { getNamedAccounts, deployments, ethers, network } = require("hardhat")
const { developmentChains, networkConfig } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Lottery Unit Test", async () => {
          let lottery, deployer, vrfCoordinatorV2Mock
          const chainId = network.config.chainId
          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              lottery = await ethers.getContract("Lottery", deployer)
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
          })

          // 测试构造函数
          describe("constructor", async () => {
              it("Initializes the lottery contract correctly", async () => {
                  const lotteryState = await lottery.getLotteryState()
                  const interval = await lottery.getInterval()
                  assert.equal(lotteryState.toString(), "0")
                  assert.equal(interval.toString(), networkConfig[chainId]["interval"])
              })
          })

          // 测试 enterLottery
          describe("enterLottery", async () => {
              // 测试准入校验
              it("Revert when you don't pay enough", async () => {
                  await expect(lottery.enterLottery({ value: 0 })).to.be.revertedWith(
                      "Lottery__NotEnoughEntranceFee"
                  )
              })

              // 测试玩家记录
              it("It records players when they enter", async () => {
                  await lottery.enterLottery({ value: ethers.utils.parseEther("0.2") })
                  const player = await lottery.getPlayers(0)
                  const numberOfPlayers = await lottery.getNumberOfPlayers()
                  assert.equal(numberOfPlayers.toString(), "1")
                  assert.equal(player, deployer)
              })
          })
      })
