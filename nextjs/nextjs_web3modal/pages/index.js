import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import Web3Modal from "web3modal";
import WalletConnectProvider from "@walletconnect/web3-provider";

let web3Modal;

const providerOptions = {
	walletconnect: {
		package: WalletConnectProvider,
		options: {
			rpc: { 4: process.env.RINKEBY_RPC_URL },
		},
	},
};

export default function Home() {
	async function connect() {
		web3Modal = new Web3Modal({
			cacheProvider: false,
			providerOptions: providerOptions,
		});
		const web3ModalProvider = await web3Modal.connect();
		const provider = new ethers.providers.Web3Provider(web3ModalProvider);
	}
	return (
		<div className={styles.container}>
			<button onClick={() => connect()}>Connect</button>
		</div>
	);
}
