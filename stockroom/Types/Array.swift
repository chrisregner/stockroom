//
//  Array.swift
//  stockroom
//
//  Created by Christopher Regner on 2/17/24.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
