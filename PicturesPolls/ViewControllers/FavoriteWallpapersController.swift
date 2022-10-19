//
//  FavoriteWallpapersController.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 22.04.2022.
//

import UIKit

class FavoriteWallpapersController: AllWallpapersViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
    }
    
    override func fetchPhotos() async {
        var imagesFromAPI = [PhotoListApiResponse]()
        
        for id in StorageManager.favoriteImagesIds {
            guard let image = await imageManager.fetchImageBy(id: id) else {
                continue
            }
            imagesFromAPI.append(image)
        }
        images.append(contentsOf: imagesFromAPI)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.indentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureImageForCell(indexPath: indexPath, cell: cell)

        return cell
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPhotosCollectionView), name: .favoritePhotosListDidChange, object: nil)
    }
    
    @objc private func reloadPhotosCollectionView() {
        numberOfElements = 0
        images = []
        collectionView?.reloadData()
        
        Task.init {
            await fetchPhotos()
        }
    }
}
