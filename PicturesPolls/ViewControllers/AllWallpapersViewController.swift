//
//  ViewController.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 15.04.2022.
//

import UIKit

class AllWallpapersViewController: UIViewController {
    
    var collectionView: UICollectionView?
    var images: [UIImage] = []
    var numberOfElements = 0
    
    var imagesFromAPIresponse: [PhotoListApiResponse] = [] {
        didSet{
            print("imagesAPIresponse count = \(imagesFromAPIresponse.count)")
            for i in imagesFromAPIresponse.count - 30...imagesFromAPIresponse.count - 1 {
                if i < 0 {
                    continue
                }
                numberOfElements += 1
                self.collectionView?.insertItems(at: [IndexPath(row: i, section: 0)])
            }
        }
    }
    
    override func viewDidLoad() {
        print(FavoritePhotosManager.favoriteImagesIds.count)
        super.viewDidLoad()
        print("in view did load")
        view.backgroundColor = .black
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (view.frame.size.width / 3) - 3, height: (view.frame.size.width / 3) - 3)
        let configuredCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        configuredCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.indentifier)
        configuredCollectionView.dataSource = self
        configuredCollectionView.delegate = self
        view.addSubview(configuredCollectionView)
        self.collectionView = configuredCollectionView
        fetchPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("all photos view controller viewWillAppear()")
    }
    
    func fetchPhotos() {
        Task.init(priority: .high) { [unowned self] in
            let photoAPIfetcher = PhotosApiFetcher()
            guard let images = await photoAPIfetcher.fetchListOfPhotos(page: Int.random(in: 1...1000)) else {
                return
            }
            imagesFromAPIresponse.append(contentsOf: images)
            
        }
    }
    
    deinit {
        print("destroyed")
    }
    
}

extension AllWallpapersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("count = \(imagesFromAPIresponse.count)")
        return numberOfElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.indentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        configureImageForCell(indexPath: indexPath, cell: cell)
        
        if indexPath.row == imagesFromAPIresponse.count - 1 {
            print("fetching new photos")
            fetchPhotos()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        let detailedWallpaperScreen = DetailedWallpaperScreen()
        detailedWallpaperScreen.authorUsername = self.imagesFromAPIresponse[indexPath.row].user.username
        detailedWallpaperScreen.fullImageURL = self.imagesFromAPIresponse[indexPath.row].urls.full
        detailedWallpaperScreen.rawImageURL = self.imagesFromAPIresponse[indexPath.row].urls.raw
        detailedWallpaperScreen.imageId = self.imagesFromAPIresponse[indexPath.row].id
        
        navigationController?.pushViewController(detailedWallpaperScreen, animated: true)
    }
    
    func configureImageForCell(indexPath: IndexPath, cell: ImageCollectionViewCell) {
        Task.init(priority: .medium) { [unowned self] in
            while indexPath.row > self.imagesFromAPIresponse.count - 1 {
                continue
            }
            
            let imageURLString = self.imagesFromAPIresponse[indexPath.row].urls.thumb
            cell.configure(with: imageURLString)
        }
    }
}



