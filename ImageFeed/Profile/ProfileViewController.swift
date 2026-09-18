//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 1/9/26.
//
import UIKit

final class ProfileViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        

        let avatarImageView = UIImageView(image: UIImage(named: "test_profile_image"))
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        let exitIconView = UIImageView(image: UIImage(named: "Exit"))
        exitIconView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitIconView)

        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let loginLabel = UILabel()
        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = .ypGray
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Hello, world!"

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            exitIconView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitIconView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitIconView.widthAnchor.constraint(equalToConstant: 24),
            exitIconView.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),

            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
}
