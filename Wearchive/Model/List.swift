//
//  List.swift
//  Wearchive
//
//  Created by Guo Tian on 3/7/21.
//

import Foundation

// object to take different kinds of type and size names for pickers
struct typeList {
    let id: Int
    let name: String
    let list: [String]
}

// type name lists shared through the app
class TypeList:ObservableObject {
    @Published var lists = [
        typeList(id: 0, name: "Footwear", list: ["Boots","Leather Shoes","Sandals","Sneakers"]),
        typeList(id: 1, name: "Tops", list: ["T-shirt","Knitwear","Shirts","Sweatshirt","Tank top"]),
        typeList(id: 2, name: "Outerwear", list: ["Coat","Jacket","Parka","Raincoats"]),
        typeList(id: 3, name: "Bottoms", list: ["Casual pants","Denim","Jumpsuits","Shorts","Sweatpants","Swimwear"]),
        typeList(id: 4, name: "Tailoring", list: ["Blazer","Suits","Vests","Tuxedos","Formal trousers"]),
        typeList(id: 5, name: "Accessories", list: ["Bags","Belts","Gloves","Hats","Jewelry","Scarves","Sunglasses","Ties","Wallets","Watches"]),
        typeList(id: 6, name: "Colors", list: ["Checked","Beige","Black","Blue","Brown","Floral","Green","Grey","Houndstooth","Leopard","Pink","Purple","Red","Stripe","White","Yellow"]),
        typeList(id: 7, name: "Types", list: ["Footwear","Tops","Outerwear","Bottoms","Tailoring","Accessories"]),
        typeList(id: 8, name: "Size", list: ["One size","XSmall","Small","Medium","Large","XLarge","XXLarge"]),
        typeList(id: 9, name: "Shoe Size", list: ["36","37","38","39","40","41","42","43","44","45"]),
        typeList(id: 10, name: "Materials", list: ["Cashmere","Cotton","Leather","Linen","Polyster","Silk","Wool"])
    ]
    // return the corresponding sub type names according to the main type
    func returnList(name:String) -> [String] {
        if let location = lists.firstIndex(where: { $0.name == name }) {
            return lists[location].list
        }
        return [""]
    }
    
    func returnSize(typeName:String) -> [String] {
        if typeName == "Footwear" {
            return lists[9].list
        }
        return lists[8].list
    }
}
