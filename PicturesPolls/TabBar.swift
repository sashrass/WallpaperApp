//
//  TabBar.swift
//  PicturesPolls
//
//  Created by Александр Рассохин on 22.04.2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let allPhotosItem = UITabBarItem(title: "All photos", image: UIImage(systemName: "trash.square.fill"), selectedImage: UIImage(systemName: "trash.fill"))
        let favouritePhotosItem = UITabBarItem(title: "Favorite photos", image: UIImage(systemName: "pencil"), selectedImage: UIImage(systemName: "pencil.slash"))
        
    }

}
