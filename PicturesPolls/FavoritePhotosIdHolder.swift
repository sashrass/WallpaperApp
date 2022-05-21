import Foundation

class FavoritePhotosManager{
    
    private static var storageKey = "photos"
    
    static var favoriteImagesIds = Set(UserDefaults.standard.object(forKey: storageKey) as? Array<String> ?? []){
        didSet{
            UserDefaults.standard.set(Array<String>(favoriteImagesIds), forKey: storageKey)
            print(favoriteImagesIds.count)
        }
    }
}
