//
//  Item.swift
//  Wearchive
//
//  Created by Guo Tian on 3/6/21.
//

import SwiftUI

// object to handle input and update info and generate keywords variable
struct Item {
    var name: String
    var brand: String
    var color: String
    var type: String
    var subType: String
    var size: String
    var fabric: String
    var detail: String
    
    func config() ->String {
        let keywords = "\(name) \(brand) \(color) \(type) \(subType) \(size) \(fabric) \(detail)"
        return keywords
    }
    
    
}
