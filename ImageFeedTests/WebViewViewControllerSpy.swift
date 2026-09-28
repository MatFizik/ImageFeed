//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Adilkhan on 28/9/26.
//


import ImageFeed
import Foundation

@MainActor
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
