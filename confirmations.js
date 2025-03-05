async function checkConfirmations(txid) {
    try {
        const response = await axios.get(`${CHRONIK_API}/tx/${txid}`);
        const txData = response.data;

        if (txData.confirmations > 0) {
            console.log(`Transaction ${txid} confirmed with ${txData.confirmations} blocks.`);
            
            // Extract the sender address (for ownership updates)
            const senderAddress = txData.inputs[0].outputScript;

            // Call function to update NFT ownership
            await updateNFTOwnership(senderAddress, txid);
        } else {
            console.log(`Transaction ${txid} is still unconfirmed.`);
        }
    } catch (error) {
        console.error("Error fetching transaction details:", error);
    }
}
