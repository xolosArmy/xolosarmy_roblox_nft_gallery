const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./database");
const NFT = require("./models/NFT");

dotenv.config();
connectDB();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const CASH_TAB_URL = "https://cashtab.com/send";
const RECEIVING_WALLET = "your-xec-wallet-address"; // Reemplaza con tu dirección eCash

// Generar enlace de pago y guardar en BD
app.post("/generate-payment", async (req, res) => {
    const { player, nft, price } = req.body;

    if (!player || !nft || !price) {
        return res.status(400).json({ error: "Datos inválidos" });
    }

    try {
        const paymentLink = `${CASH_TAB_URL}?to=${RECEIVING_WALLET}&amount=${price}`;

        console.log(`✅ Pago generado: ${paymentLink}`);
        
        res.json({ payment_link: paymentLink });

    } catch (error) {
        console.error("❌ Error generando el pago:", error);
        res.status(500).json({ error: "No se pudo generar el enlace de pago" });
    }
});

// Obtener NFTs de un usuario
app.get("/nfts/:wallet", async (req, res) => {
    try {
        const nfts = await NFT.find({ owner: req.params.wallet });
        res.json(nfts);
    } catch (error) {
        res.status(500).json({ error: "Error al obtener NFTs" });
    }
});

// Iniciar el servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor ejecutándose en el puerto ${PORT}`);
});
