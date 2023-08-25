import "NonFungibleToken"

import "CapabilityFactory"

pub fun main(address: Address): Bool {
    
    let managerRef = getAuthAccount(address).borrow<&CapabilityFactory.Manager>(from: CapabilityFactory.StoragePath)
        ?? panic("CapabilityFactory Manager not found")

    let providerFactory = managerRef.getFactory(Type<&{NonFungibleToken.Provider}>())

    return providerFactory != nil
}