const WebSocket = require("ws");
const axios = require("axios");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const NFT = require("./models/NFT");

dotenv.config();
mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });

const CHRONIK_WS = "wss://chronik.be.cash/xec/ws"; 
const CHRONIK_API = "https://chronik.be.cash/xec"; 
const RECEIVING_WALLET = "your-xec-wallet-address"; 

const ws = new WebSocket(CHRONIK_WS);

ws.on("open", () => {
    console.log("🔗 Conectado a Chronik WebSocket");

    ws.send(JSON.stringify({
        type: "subscribeScript",
        scriptType: "p2pkh",
        scriptPayload: Buffer.from(RECEIVING_WALLET, "utf8").toString("hex")
    }));
});

ws.on("message", async (data) => {
    const message = JSON.parse(data);

    if (message.type === "transaction") {
        console.log("📥 Transacción detectada:", message.txid);

        // Verificar confirmaciones
        await checkConfirmations(message.txid);
    }
});

async function checkConfirmations(txid) {
    try {
        const response = await axios.get(`${CHRONIK_API}/tx/${txid}`);
        const txData = response.data;

        if (txData.confirmations > 0) {
            console.log(`✅ Transacción ${txid} confirmada con ${txData.confirmations} bloques.`);
            
            const senderAddress = txData.inputs[0].outputScript;

            // Guardar en BD
            const nftPurchased = new NFT({
                nftName: "NFT Comprado",
                price: 100,  // Puedes mejorarlo con la data del NFT específico
                owner: senderAddress,
                txid: txid
            });

            await nftPurchased.save();
            console.log(`✅ NFT guardado en la base de datos para ${senderAddress}`);
        } else {
            console.log(`⏳ Transacción ${txid} aún no confirmada.`);
        }
    } catch (error) {
        console.error("❌ Error obteniendo detalles de la transacción:", error);
    }
}
