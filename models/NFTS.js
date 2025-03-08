const mongoose = require("mongoose");

const NFTSchema = new mongoose.Schema({
    nftName: { type: String, required: true },
    price: { type: Number, required: true },
    owner: { type: String, required: true }, // Dirección de la wallet
    txid: { type: String, required: true, unique: true } // ID de transacción
});

module.exports = mongoose.model("NFT", NFTSchema);
