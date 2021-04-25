//
//  LinksData.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 18/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class LinksData: NSObject, Decodable {
    var this: String?
    var first: String?
    var next: String?
    var last: String?
    
    private enum CodingKeys: String, CodingKey {
        case this = "self"
        case first
        case next
        case last
    }
}
