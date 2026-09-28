//
//  Untitled.swift
//  ImageFeed
//
//  Created by Adilkhan on 28/9/26.
//

import ImageFeed
import Foundation

@MainActor
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    
    func code(from url: URL) -> String? {
        return nil
    }
}
