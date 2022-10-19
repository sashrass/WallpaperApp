import Foundation

struct StorageManager {
    
    private static let storageKey = "favoritePhotos"
    
    static var favoriteImagesIds = Set(UserDefaults.standard.object(forKey: storageKey) as? Array<String> ?? []){
        didSet {
            UserDefaults.standard.set(Array<String>(favoriteImagesIds), forKey: storageKey)
            print(favoriteImagesIds.count)
        }
    }
    
    
}
