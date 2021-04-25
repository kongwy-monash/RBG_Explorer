//
//  RootData.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 18/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class RootData: NSObject, Decodable {
    var plants: [PlantData]?
    var links: LinksData?
    var totalCount: Int?
    
    private enum RootKeys: String, CodingKey {
        case plants = "data"
        case links
        case totalCount = "meta"
    }
    
    private struct Meta: Decodable {
        var total: Int?
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        self.plants = try rootContainer.decode([PlantData].self, forKey: .plants)
        self.links = try rootContainer.decode(LinksData.self, forKey: .links)
        let meta = try rootContainer.decode(Meta.self, forKey: .totalCount)
        self.totalCount = meta.total
    }
}
