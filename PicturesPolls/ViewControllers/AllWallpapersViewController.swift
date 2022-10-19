//
//  ViewController.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 15.04.2022.
//

import UIKit

class AllWallpapersViewController: UIViewController {
    
    let imageManager = ImageManager()
    
    var collectionView: UICollectionView?
    var numberOfElements = 0
    
    var images: [PhotoListApiResponse] = [] {
        didSet {
            for var i in images.count - 30...images.count - 1 {
                if i < 0 {
                    i = 0
                    continue
                }
                numberOfElements += 1
                self.collectionView?.insertItems(at: [IndexPath(row: i, section: 0)])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        Task.init {
            await fetchPhotos()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func fetchPhotos() async {
        guard let images = await self.imageManager.fetchListOfPhotos(page: Int.random(in: 1...1000)) else {
            return
        }
        self.images.append(contentsOf: images)
    }
    
    deinit {
        print("destroyed")
    }
    
}

extension AllWallpapersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.indentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        configureImageForCell(indexPath: indexPath, cell: cell)
        
        if indexPath.row == images.count - 1 {
            print("fetching new photos")
            
            Task.init {
                await fetchPhotos()
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        let detailedWallpaperScreen = DetailedWallpaperScreen()
        detailedWallpaperScreen.authorUsername = self.images[indexPath.row].user.username
        detailedWallpaperScreen.fullImageURL = self.images[indexPath.row].urls.full
        detailedWallpaperScreen.imageId = self.images[indexPath.row].id
        
        navigationController?.pushViewController(detailedWallpaperScreen, animated: true)
    }
    
    func configureImageForCell(indexPath: IndexPath, cell: ImageCollectionViewCell) {
        while indexPath.row > self.images.count - 1 {
            continue
        }
        
        let imageURLString = self.images[indexPath.row].urls.thumb

        Task.init {
            await cell.configure(with: imageURLString)
        }
        
    }
}



