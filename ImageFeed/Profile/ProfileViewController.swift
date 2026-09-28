//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 1/9/26.
//
import UIKit
import Kingfisher
import Logging

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfileDetails(name: String, login: String, bio: String?)
    func updateAvatar(url: URL)
    func switchToSplashScreen()
}


final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol?
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    private lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = .ypGray
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginLabel
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        return button
    }()
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "test_profile_image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        addSubviews()
        setupConstraints()
        
        presenter?.viewDidLoad()
    }
    
    @objc private func didTapExitButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Да", style: .default, handler: { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        }))
        alert.addAction(.init(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func updateProfileDetails(name: String, login: String, bio: String?) {
        nameLabel.text = name
        loginLabel.text = login
        descriptionLabel.text = bio
    }
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared
            .connectedScenes
            .compactMap({($0 as? UIWindowScene)?.keyWindow}).first else { return }
        window.rootViewController = SplashViewController()
    }
    
    func updateAvatar(url imageUrl: URL) {
        AppLogger.info("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                
                switch result {
                case .success(let value):
                    print(value.image)
                    
                    print(value.cacheType)
                    
                    print(value.source)
                    
                case .failure(let error):
                    AppLogger.error("Ошибка получения аватарки",
                                    metadata: ["from":"updateAvatar",
                                               "error": "\(error.localizedDescription)"])
                }
            }
    }
    
    
    private func addSubviews() {
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)
        view.addSubview(avatarImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
}
