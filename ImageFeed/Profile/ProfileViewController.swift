//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 1/9/26.
//
import UIKit
import Kingfisher
import Logging

final class ProfileViewController: UIViewController {
    
    let profileService = ProfileService.shared
    
    var profileViewModel: ProfileViewModel?
    
    let profileLogoutService = ProfileLogoutService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?

    private var animationLayers: [CALayer] = []

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
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        addSubviews()
        setupConstraints()
        showLoadingAnimation()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    @objc private func didTapExitButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Да", style: .default, handler: { _ in
            self.profileLogoutService.logout()
            
            guard let window = UIApplication.shared
                .connectedScenes
                .compactMap({($0 as? UIWindowScene)?.keyWindow}).first else { return }
            window.rootViewController = SplashViewController()

        }))
        alert.addAction(.init(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        AppLogger.info("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { [weak self] result in
                self?.finishLoading()

                if case .failure(let error) = result {
                    AppLogger.error("Ошибка получения аватарки",
                                    metadata: ["from":"updateAvatar",
                                               "error": "\(error.localizedDescription)"])
                }
            }
    }

    // MARK: -Loading animation
    private func addGradient(to view: UIView, size: CGSize, cornerRadius: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")

        view.layer.addSublayer(gradient)
        animationLayers.append(gradient)
    }

    private func showLoadingAnimation() {
        addGradient(to: avatarImageView, size: CGSize(width: 70, height: 70), cornerRadius: 35)
        addGradient(to: nameLabel, size: CGSize(width: 223, height: 18), cornerRadius: 9)
        addGradient(to: loginLabel, size: CGSize(width: 89, height: 18), cornerRadius: 9)
        addGradient(to: descriptionLabel, size: CGSize(width: 67, height: 18), cornerRadius: 9)
    }

    private func removeLoadingAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }

    private func finishLoading() {
        removeLoadingAnimation()
        requestForProfile()
    }

    
    private func requestForProfile() {
        if let profile = ProfileService.shared.profileViewModel {
            self.nameLabel.text = profile.name
            self.descriptionLabel.text = profile.bio
            self.loginLabel.text = profile.login
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
            nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),

            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18)
        ])
    }
}
