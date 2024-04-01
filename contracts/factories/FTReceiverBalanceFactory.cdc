import "CapabilityFactory"
import "FungibleToken"

access(all) contract FTReceiverBalanceFactory {
    access(all) struct Factory: CapabilityFactory.Factory {
        access(Capabilities) view fun getCapability(acct: auth(Capabilities) &Account, controllerID: UInt64): Capability? {
            if let con = acct.capabilities.storage.getController(byCapabilityID: controllerID) {
                if !con.capability.check<&{FungibleToken.Receiver, FungibleToken.Balance}>() {
                    return nil
                }

                return con.capability as! Capability<&{FungibleToken.Receiver, FungibleToken.Balance}>
            }

            return nil
        }

        access(all) view fun getPublicCapability(acct: auth(Capabilities) &Account, path: PublicPath): Capability? {
            return acct.capabilities.get<&{FungibleToken.Receiver, FungibleToken.Balance}>(path)
        }
    }
}