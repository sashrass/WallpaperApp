import Foundation
import UIKit

struct PhotosApiFetcher {
    
    private let clientId = "hU9N-jVL8vW6KjYQEsyqJHKYHtXL8ugG6u4J2T-FY3s"
    static let imageCache: NSCache<NSString, UIImage> = {
        let nsCache = NSCache<NSString, UIImage>()
        nsCache.countLimit = 50
        
        return nsCache
    }()
    
    func isImageinCache(url: String) -> Bool {
        if let _ = PhotosApiFetcher.imageCache.object(forKey: url as NSString) {
            return true
        } else {
            return false
        }
    }
    
    private func getData(from url: String) async -> Data? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        do {
            let data = try await URLSession.shared.data(from: url)
            return data.0
        }
        catch {
            return nil
        }
    }
    
    
    private func constructURL(path: String, queryItems: [URLQueryItem]) -> String? {
        var url = URLComponents()
        url.scheme = "https"
        url.host = "api.unsplash.com"
        url.path = path
        url.queryItems = queryItems
        
        print("url constructed")
        return url.url?.absoluteString
    }
    
    func fetchListOfPhotos(page: Int) async -> [PhotoListApiResponse]? {
//        let url = "https://api.unsplash.com/photos/?page=1&per_page=30&client_id=hU9N-jVL8vW6KjYQEsyqJHKYHtXL8ugG6u4J2T-FY3s"
        
        guard let url = constructURL(path: "/photos/", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "client_id", value: clientId)
        ]) else {
            return nil
        }
        
        guard let data = await getData(from: url) else {
            return nil
        }
        
        print("data ok")
        
        do {
            print(data)
            let photoList = try JSONDecoder().decode([PhotoListApiResponse].self, from: data)
            print("data decoded")
            return photoList
        }
        catch {
            print("catched")
            return nil
        }
    }
    
    func getImageBy(url: String) async -> UIImage? {
        if isImageinCache(url: url) {
            let image = PhotosApiFetcher.imageCache.object(forKey: url as NSString)
            print("fetched from cache")
            return image
        } else {
            let data = await getData(from: url)
            guard let data = data, let image = UIImage(data: data) else {
                return nil
            }

            PhotosApiFetcher.imageCache.setObject(image, forKey: url as NSString)
            print("image downloaded")
            return image
        }
    }
    
    func fetchImageFromApiBy(id: String) async -> PhotoListApiResponse? {
        guard let url = constructURL(path: "/photos/" + id, queryItems: [
            URLQueryItem(name: "client_id", value: clientId)
        ]) else {
            return nil
        }
        
        guard let data = await getData(from: url) else {
            return nil
        }
        
        print("got data for id")
        
        do{
            let photoList = try JSONDecoder().decode(PhotoListApiResponse.self, from: data)
            guard photoList.id == id else {
                return nil
            }
            
            print("return image by id")
            return photoList
        }
        catch{
            return nil
        }
    }
    
}
