//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Adilkhan on 4/7/26.
//

import UIKit
import Kingfisher

enum FeedCellImageState {
    case loading
    case error
    case finished(UIImage)
}

final class ImagesListCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupLoadingView()
    }

    static let reuseIdentifier = "ImagesListCell"

    weak var delegate: ImagesListCellDelegate?

    private let loadingView = GradientLoadingView()

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        loadingView.stopAnimating()
    }

    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_btn_active") : UIImage(named: "like_btn_no_active")
        likeButton.setImage(likeImage,for: .normal)
    }

    func setImageState(_ state: FeedCellImageState) {
        switch state {
        case .loading:
            cellImage.image = nil
            loadingView.startAnimating()
        case .error:
            loadingView.stopAnimating()
            cellImage.contentMode = .center
            cellImage.image = UIImage(named: "placeholder")
        case .finished(let image):
            loadingView.stopAnimating()
            cellImage.contentMode = .scaleAspectFill
            cellImage.image = image
        }
    }

    private func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        cellImage.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: cellImage.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor)
        ])
    }


    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!


    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
