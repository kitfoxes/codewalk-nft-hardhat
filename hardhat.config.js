require("@nomicfoundation/hardhat-toolbox");
const dotenv = require("dotenv")
dotenv.config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.23",
  defaultNetwork: "ganache",
  networks: {
    ganache: {
      url: "HTTP://127.0.0.1:7545",
      chainId: 1337,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
