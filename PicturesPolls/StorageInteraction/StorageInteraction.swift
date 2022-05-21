import Foundation

struct StorageInteraction {
    
    private var storage = UserDefaults.standard
    private var storageKey = "photos"
    
    func saveFavoritePhotoBy(id: String) {
        var ids = loadFavoritePhotosId()
        ids.append(id)
        storage.set(ids, forKey: storageKey)
    }
    
    func loadFavoritePhotosId() -> [String] {
        let ids = storage.object(forKey: storageKey) as? [String]
        guard let _ = ids else {
            return []
        }
        return ids!
    }
    
    
}
