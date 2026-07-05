import DoomKitCore
import Foundation
import Testing

@Test
func processSubscriptionMinimumTimeout() {
    let subscription = ProcessSubscription(
        id: UUID(),
        timeout: 30,
        refresh: { _ in }
    )
    #expect(subscription.timeout == 60)
}

@Test
func processSubscriptionPendingAndReset() {
    var subscription = ProcessSubscription(
        id: UUID(),
        timeout: 120,
        refresh: { _ in }
    )
    subscription.update(tick: 60)
    #expect(subscription.isPending() == false)
    subscription.update(tick: 60)
    #expect(subscription.isPending() == true)
    subscription.reset()
    #expect(subscription.isPending() == false)
}

@Test
func processMetadataStringLookup() {
    let metadata = ProcessMetadata(["icon": "atom"])
    #expect(metadata.string(for: "icon") == "atom")
}
