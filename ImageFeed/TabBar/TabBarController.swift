//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Adilkhan on 22/9/26.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    override func awakeFromNib() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        if let imagesListViewController = imageListViewController as? ImagesListViewController {
            let imagesListPresenter = ImagesListPresenter()
            imagesListViewController.presenter = imagesListPresenter
            imagesListPresenter.view = imagesListViewController
        }
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
    
}
