//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 2/9/26.
//
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var largeImageUrl: String?
    
    
    @IBOutlet final var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var shareButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        showImage()
    }
    
    private func showImage() {
        guard let largeImageUrl else { return }
        shareButton.isHidden = true
        view.layoutIfNeeded()
        scrollView.zoomScale = 1
        imageView.contentMode = .center
        imageView.frame = CGRect(origin: .zero, size: scrollView.bounds.size)
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: URL(string: largeImageUrl),
                              placeholder: UIImage(named: "placeholder_icon")) {[weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                shareButton.isHidden = true
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in self?.showImage() }))
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.frame.size = image.size
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {return}
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
