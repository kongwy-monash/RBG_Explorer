//
//  WebRequestDelegate.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 17/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import Foundation

protocol WebRequestDelegate {
    func plantsDataDidFetched(plantsData: [PlantData])
    func plantImageDataDidFetched(plantData: PlantData, imageData: Data, indexPath: IndexPath?)
    func plantImageDataDidFetched(plant: Plant, imageData: Data, indexPath: IndexPath?)
}
