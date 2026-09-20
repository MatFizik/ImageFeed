//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Adilkhan on 4/7/26.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    static let reuseIdentifier = "ImagesListCell"
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
}
