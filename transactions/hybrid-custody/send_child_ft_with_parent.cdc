import "FungibleToken"
import "FlowToken"

import "HybridCustody"

transaction(amount: UFix64, to: Address, child: Address) {

    // The Vault resource that holds the tokens that are being transferred
    let paymentVault: @FungibleToken.Vault

    prepare(signer: AuthAccount) {
        // signer is the parent account
        // get the manager resource and borrow proxyAccount
        let m = signer.borrow<&HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath)
            ?? panic("manager does not exist")
        let childAcct = m.borrowAccount(addr: child) ?? panic("child account not found")
        
        //get Ft cap from child account
        let cap = childAcct.getCapability(path: /private/ftProvider, type: Type<&{FungibleToken.Provider}>()) ?? panic("no cap found")
        let providerCap = cap as! Capability<&{FungibleToken.Provider}>

        if providerCap == nil {
        return
        }
        
        // Get a reference to the child's stored vault
        let vaultRef = providerCap.borrow()!

        // Withdraw tokens from the signer's stored vault
        self.paymentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {

        // Get the recipient's public account object
        let recipient = getAccount(to)

        // Get a reference to the recipient's Receiver
        let receiverRef = recipient.getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
			?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiverRef.deposit(from: <-self.paymentVault)
    }
}