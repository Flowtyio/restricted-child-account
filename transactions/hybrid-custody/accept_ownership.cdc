import "HybridCustody"

transaction(childAddress: Address) {
    prepare(acct: AuthAccount) {
        if acct.borrow<&HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath) == nil {
            let m <- HybridCustody.createManager()
            acct.save(<- m, to: HybridCustody.ManagerStoragePath)

            acct.unlink(HybridCustody.ManagerPublicPath)
            acct.unlink(HybridCustody.ManagerPrivatePath)

            acct.link<&HybridCustody.Manager{HybridCustody.ManagerPrivate, HybridCustody.ManagerPublic}>(HybridCustody.ManagerPrivatePath, target: HybridCustody.ManagerStoragePath)
            acct.link<&HybridCustody.Manager{HybridCustody.ManagerPublic}>(HybridCustody.ManagerPublicPath, target: HybridCustody.ManagerStoragePath)
        }

        let inboxName = HybridCustody.getOwnerIdentifier(acct.address) 
        let cap = acct.inbox.claim<&AnyResource{HybridCustody.Account, HybridCustody.ChildAccountPrivate}>(inboxName, provider: childAddress)
            ?? panic("proxy account cap not found")

        let manager = acct.borrow<&HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath)
            ?? panic("manager no found")

        manager.addOwnedAccount(cap)
    }
}