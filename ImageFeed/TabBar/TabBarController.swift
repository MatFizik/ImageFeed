//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Adilkhan on 22/9/26.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
    
}
