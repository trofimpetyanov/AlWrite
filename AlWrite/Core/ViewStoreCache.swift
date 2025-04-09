import Foundation

final class ViewStoreCache {
    private var cache: [ObjectIdentifier: AnyObject]
    private var trackedKeys: Set<ObjectIdentifier>

    init(
        cache: [ObjectIdentifier: AnyObject] = [:],
        trackedKeys: Set<ObjectIdentifier> = []
    ) {
        self.cache = cache
        self.trackedKeys = trackedKeys
    }

    func viewStore<VS, VE, S: Store>(
        for store: S,
        factory: (S) -> ViewStore<VS, VE>
    ) -> ViewStore<VS, VE> {
        let key = ObjectIdentifier(store)
        trackedKeys.insert(key)
        guard let cached = cache[key] as? ViewStore<VS, VE> else {
            let viewStore = factory(store)
            cache[key] = viewStore
            return viewStore
        }
        return cached
    }

    func cleanupUntrackedViewStores() {
        guard !trackedKeys.isEmpty else { return }
        cache = cache.filter { key, _ in trackedKeys.contains(key) }
        trackedKeys = []
    }
}
