//
//  MapAnnotation.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 9/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import MapKit

class ExhibitionMapAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var icon: UIImage?
    var exhibition: Exhibition?
    
    init(title: String?, subtitle: String?, latitude: Double, longitude: Double, icon: UIImage?) {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.icon = icon
        
        super.init()
    }
    
    init(exhibition: Exhibition) {
        self.exhibition = exhibition
        self.title = exhibition.name
        self.coordinate = CLLocationCoordinate2D(latitude: exhibition.latitude, longitude: exhibition.longitude)
        if let icon = exhibition.icon {
            self.icon = UIImage(data: icon)
        } else {
            self.icon = UIImage(named: "exhibition_placeholder")
        }
        
        super.init()
    }
    
}
