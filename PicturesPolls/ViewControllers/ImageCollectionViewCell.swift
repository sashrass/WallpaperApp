import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let indentifier = "ImageCollectionViewCell"
    
    var currentImageURL = ""
    let photosAPIFetcher = PhotosApiFetcher()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reusing cell")
        imageView.image = nil
    }
    
    func configure(with url: String) {
        Task.init(priority: .background) { [weak self] in
            self?.currentImageURL = url
            guard let image = await self?.photosAPIFetcher.getImageBy(url: url) else {
                return
            }
            
            if url == currentImageURL {
                self?.imageView.image = image
            }
        }
    }
    
    deinit {
        print("cell destroyed")
    }
}
