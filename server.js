const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const CASH_TAB_URL = "https://cashtab.com/send";
const RECEIVING_WALLET = "ecash:qqa4zjj0mt6gkm3uh6wcmxtzdr3p6f7cky4y7vujuw"; // Reemplaza con tu dirección eCash

// API para generar un enlace de pago en Cashtab
app.post("/generate-payment", (req, res) => {
    const { player, nft, price } = req.body;

    if (!player || !nft || !price) {
        return res.status(400).json({ error: "Datos inválidos" });
    }

    try {
        // Generar el enlace de pago
        const paymentLink = `${CASH_TAB_URL}?to=${RECEIVING_WALLET}&amount=${price}`;

        console.log(`✅ Pago generado: ${paymentLink}`);
        
        res.json({ payment_link: paymentLink });

    } catch (error) {
        console.error("❌ Error generando el pago:", error);
        res.status(500).json({ error: "No se pudo generar el enlace de pago" });
    }
});

// Iniciar el servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor ejecutándose en el puerto ${PORT}`);
});
