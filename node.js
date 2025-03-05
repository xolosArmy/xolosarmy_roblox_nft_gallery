const WebSocket = require("ws");
const axios = require("axios");

const CHRONIK_WS = "wss://chronik.be.cash/xec/ws"; // WebSocket for eCash blockchain
const CHRONIK_API = "https://chronik.be.cash/xec"; // Chronik REST API
const RECEIVING_WALLET = "ecash:qqa4zjj0mt6gkm3uh6wcmxtzdr3p6f7cky4y7vujuw"; // Replace with your actual wallet

const ws = new WebSocket(CHRONIK_WS);

ws.on("open", () => {
    console.log("Connected to Chronik WebSocket");

    // Subscribe to transactions for the receiving wallet address
    ws.send(JSON.stringify({
        type: "subscribeScript",
        scriptType: "p2pkh",
        scriptPayload: Buffer.from(RECEIVING_WALLET, "utf8").toString("hex")
    }));
});

ws.on("message", async (data) => {
    const message = JSON.parse(data);

    if (message.type === "transaction") {
        console.log("New transaction detected:", message.txid);

        // Check transaction confirmations
        await checkConfirmations(message.txid);
    }
});

ws.on("error", (err) => {
    console.error("WebSocket error:", err);
});

ws.on("close", () => {
    console.log("WebSocket connection closed");
});
