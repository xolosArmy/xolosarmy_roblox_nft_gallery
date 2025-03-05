const WebSocket = require("ws");
const axios = require("axios");

const CHRONIK_WS = "wss://chronik.be.cash/xec/ws"; 
const CHRONIK_API = "https://chronik.be.cash/xec"; 
const RECEIVING_WALLET = "ecash:qqa4zjj0mt6gkm3uh6wcmxtzdr3p6f7cky4y7vujuw"; 

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
            
            // Extraer el remitente (para asignar el NFT)
            const senderAddress = txData.inputs[0].outputScript;

            // Actualizar propiedad del NFT
            await updateNFTOwnership(senderAddress, txid);
        } else {
            console.log(`⏳ Transacción ${txid} aún no confirmada.`);
        }
    } catch (error) {
        console.error("❌ Error obteniendo detalles de la transacción:", error);
    }
}

}
