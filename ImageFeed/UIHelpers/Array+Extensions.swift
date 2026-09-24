//
//  Array+Extensions.swift
//  ImageFeed
//
//  Created by Adilkhan on 25/9/26.
//

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
