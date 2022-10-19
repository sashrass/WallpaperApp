//
//  DetailedWallpaperScreenViewController.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 08.05.2022.
//

import UIKit

class DetailedWallpaperScreen: UITableViewController  {
    
    let imageManager = ImageManager()
    
    var addToFavoriteButton: UIBarButtonItem!
    var saveToGalleryButton: UIBarButtonItem!
    
    var fullImageURL: String = ""
    var authorUsername: String = ""
    var isFavorite: Bool!
    var imageId: String = ""

    private let fullImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.frame = .zero

        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addToFavoriteButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(addToFavorite))
        saveToGalleryButton = UIBarButtonItem(image: UIImage(systemName: "arrow.down.circle"), style: .plain, target: self, action: #selector(saveToGallery))
        saveToGalleryButton.isEnabled = false
        
        self.navigationItem.rightBarButtonItems = [
           addToFavoriteButton,
           saveToGalleryButton
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFavorite = StorageManager.favoriteImagesIds.contains(imageId)
        
        addToFavoriteButton.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
    }
    
    @objc func addToFavorite() {
        if isFavorite {
            StorageManager.favoriteImagesIds.remove(imageId)
            addToFavoriteButton.image = UIImage(systemName: "heart")
            isFavorite = false
        }
        else {
            StorageManager.favoriteImagesIds.insert(imageId)
            addToFavoriteButton.image = UIImage(systemName: "heart.fill")
            isFavorite = true
        }
        
        NotificationCenter.default.post(name: .favoritePhotosListDidChange, object: nil)
    }
    
    @objc func saveToGallery() {

        UIImageWriteToSavedPhotosAlbum(fullImageView.image!, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        guard error == nil else {
            let alert = UIAlertController(title: "Не удалось сохранить", message: "Разрешите приложению доступ к галерее в системных настройках", preferredStyle: .alert)
            
            let goToSettingsButton = UIAlertAction(title: "Перейти в настройки", style: .default){_ in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
            }
            let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(goToSettingsButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        saveToGalleryButton.image = UIImage(systemName: "arrow.down.circle.fill")
        saveToGalleryButton.isEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.row {
        case 0:
            cell = UITableViewCell()
            Task.init { [weak self] in
                let photo = await self?.imageManager.fetchImageBy(url: self?.fullImageURL ?? "")
                guard let photo = photo else {
                    print("return")
                    return
                }
                
                self?.fullImageView.image = photo
                self?.saveToGalleryButton.isEnabled = true
            }
            
            fullImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat(view.bounds.height - ((self.tabBarController?.tabBar.frame.height)!) - (self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.height))
            cell.addSubview(self.fullImageView)
        case 1:
            cell = UITableViewCell()
            let label = UILabel(frame: CGRect(x: 5, y: 5, width: Int(view.bounds.width) - 5, height: 40))
            label.text = authorUsername
            cell.addSubview(label)
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row{
        case 0:
            return CGFloat(view.bounds.height - ((self.tabBarController?.tabBar.frame.height)!) - (self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.height)
        case 1:
            return CGFloat(50)
        default:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
    }
    
    deinit {
        imageManager.dataTasks.forEach { $0.cancel() }
    }

}
