class PhotoListApiResponse: Codable {
    let id: String
    let urls: PhotoURLs
    let user: User
}

class User: Codable {
    let username: String
}

class PhotoURLs: Codable {
    let raw: String
    let full: String
    let thumb: String
}
