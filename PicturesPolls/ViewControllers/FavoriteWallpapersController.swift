//
//  FavoriteWallpapersController.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 22.04.2022.
//

import UIKit

class FavoriteWallpapersController: AllWallpapersViewController {
    
    var isJustLoaded = true
    
    override func viewWillAppear(_ animated: Bool) {
        if isJustLoaded {
            isJustLoaded = false
            return
        }
        
        if imagesFromAPIresponse.count != FavoritePhotosManager.favoriteImagesIds.count{
            numberOfElements = 0
            collectionView?.reloadData()
            imagesFromAPIresponse = []
            fetchPhotos()
        }

    }
    
    override func fetchPhotos() {
        Task.init(priority: .high) { [unowned self] in
            var imagesFromAPI = [PhotoListApiResponse]()
            let photoAPIfetcher = PhotosApiFetcher()
            for id in FavoritePhotosManager.favoriteImagesIds{
                guard let image = await photoAPIfetcher.fetchImageFromApiBy(id: id) else{
                    continue
                }
                imagesFromAPI.append(image)
            }
            imagesFromAPIresponse.append(contentsOf: imagesFromAPI)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.indentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureImageForCell(indexPath: indexPath, cell: cell)

        return cell
    }
}
