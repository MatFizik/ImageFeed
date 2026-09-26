//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Adilkhan on 4/7/26.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = UIImage(resource: isLiked ? .likeBtnActive : .likeBtnNoActive)
        likeButton.setImage(likeImage,for: .normal)
    }
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
