//
//  PlantData.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 19/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class PlantData: NSObject, Decodable {
    var sname: String?
    var name: String?
    var year: Int?
    var family: String?
    var imageURI: String?
    
    private enum CodingKeys: String, CodingKey {
        case sname = "scientific_name"
        case name = "common_name"
        case year
        case family
        case imageURI = "image_url"
    }
    
}
