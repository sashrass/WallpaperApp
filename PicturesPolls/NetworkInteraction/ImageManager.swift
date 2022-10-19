import Foundation
import UIKit

class ImageManager {
    
    var dataTasks: [URLSessionDataTask] = []
    
    private let clientId = "hU9N-jVL8vW6KjYQEsyqJHKYHtXL8ugG6u4J2T-FY3s"
    private static let imageCache: NSCache<NSString, UIImage> = {
        let nsCache = NSCache<NSString, UIImage>()
        nsCache.countLimit = 100
        
        return nsCache
    }()
        
    private func fetchData(from url: String) async -> Data? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        let data: Data? = await withCheckedContinuation { [weak self] continuation in
            
            let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
                continuation.resume(returning: data)
            }
            
            self?.dataTasks.append(dataTask)
            dataTask.resume()
        }
        
        return data
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
        
        guard let data = await fetchData(from: url) else {
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
    
    func fetchImageBy(url: String) async -> UIImage? {
        print("downloading \(url)")
        if let image = ImageManager.imageCache.object(forKey: url as NSString) {
            print("fetched from cache")
            return image
        } else {
            let data = await fetchData(from: url)
            guard let data = data, let image = UIImage(data: data) else {
                return nil
            }

            ImageManager.imageCache.setObject(image, forKey: url as NSString)
            print("image downloaded")
            return image
        }
    }
    
    func fetchImageBy(id: String) async -> PhotoListApiResponse? {
        guard let url = constructURL(path: "/photos/" + id, queryItems: [
            URLQueryItem(name: "client_id", value: clientId)
        ]) else {
            return nil
        }
        
        guard let data = await fetchData(from: url) else {
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
    
    private func constructURL(path: String, queryItems: [URLQueryItem]) -> String? {
        var url = URLComponents()
        url.scheme = "https"
        url.host = "api.unsplash.com"
        url.path = path
        url.queryItems = queryItems
        
        print("url constructed")
        return url.url?.absoluteString
    }
}
