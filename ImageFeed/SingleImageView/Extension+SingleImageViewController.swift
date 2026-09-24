//
//  Extension+SingleImageViewController.swift
//  ImageFeed
//
//  Created by Adilkhan on 2/9/26.
//

import UIKit

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
