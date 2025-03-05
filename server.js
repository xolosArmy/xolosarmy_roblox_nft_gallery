const express = require("express");
const axios = require("axios");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const CASH_TAB_API = "https://api.cashtab.com";
const RECEIVING_WALLET = "your-xec-wallet-address"; // Replace with your eCash wallet

// Generate Cashtab Payment Link
app.post("/generate-payment", async (req, res) => {
    const { player, nft, price } = req.body;

    if (!player || !nft || !price) {
        return res.status(400).json({ error: "Invalid request data" });
    }

    try {
        // Generate payment URL
        const paymentLink = `${CASH_TAB_API}/pay?to=${RECEIVING_WALLET}&amount=${price}&token=`;

        console.log(`Generated Cashtab Link: ${paymentLink}`);
        
        res.json({ payment_link: paymentLink });

    } catch (error) {
        console.error("Error generating payment link:", error);
        res.status(500).json({ error: "Failed to generate payment link" });
    }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
