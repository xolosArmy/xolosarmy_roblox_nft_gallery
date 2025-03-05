const fs = require("fs"); // Example for local storage, replace with DB if needed

async function updateNFTOwnership(sender, txid) {
    try {
        // Read NFT ownership file (You can replace this with MongoDB, Firebase, MySQL, etc.)
        let nftOwners = JSON.parse(fs.readFileSync("nft_owners.json", "utf8"));

        // Assume the NFT bought is stored in a temporary cache (must be linked to txid)
        const purchasedNFT = nftOwners.pending[txid];
        if (!purchasedNFT) {
            console.log(`No pending NFT found for transaction ${txid}`);
            return;
        }

        // Update ownership
        nftOwners.owned[sender] = nftOwners.owned[sender] || [];
        nftOwners.owned[sender].push(purchasedNFT);

        // Remove from pending transactions
        delete nftOwners.pending[txid];

        // Save changes
        fs.writeFileSync("nft_owners.json", JSON.stringify(nftOwners, null, 2));

        console.log(`NFT ${purchasedNFT.name} successfully assigned to ${sender}`);
    } catch (error) {
        console.error("Error updating NFT ownership:", error);
    }
}
