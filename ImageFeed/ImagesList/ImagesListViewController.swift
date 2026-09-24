//
//  ViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 3/6/26.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [PhotoViewModel] = []
    
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    let imageListService = ImageListService.shared
    
    private let singleImageSegueIdentifier = "ShowSingleImage"
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        imageListService.fetchPhotosNextPage()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == singleImageSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        
        viewController.image = UIImage(named: photos[indexPath.row].largeImageURL)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i , section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: UIImage(named: "placeholder")
        )
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "like_btn_active") : UIImage(named: "like_btn_no_active")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: singleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = photos[indexPath.row].size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / size.width
        let cellHeight = size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}
