const fs = require("fs");

async function updateNFTOwnership(sender, txid) {
    try {
        let nftOwners = JSON.parse(fs.readFileSync("nft_owners.json", "utf8"));

        const purchasedNFT = nftOwners.pending[txid];
        if (!purchasedNFT) {
            console.log(`⚠️ No se encontró NFT pendiente para la transacción ${txid}`);
            return;
        }

        nftOwners.owned[sender] = nftOwners.owned[sender] || [];
        nftOwners.owned[sender].push(purchasedNFT);

        delete nftOwners.pending[txid];

        fs.writeFileSync("nft_owners.json", JSON.stringify(nftOwners, null, 2));

        console.log(`✅ NFT ${purchasedNFT.name} asignado a ${sender}`);
    } catch (error) {
        console.error("❌ Error actualizando propiedad del NFT:", error);
    }
}

module.exports = { updateNFTOwnership };
