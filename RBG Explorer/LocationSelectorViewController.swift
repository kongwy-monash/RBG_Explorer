//
//  LocationSelectorViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 13/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol LocationSelectorDelegate {
    func didSelectedLocation(location: CLLocation)
}

class LocationSelectorViewController: UIViewController {
    
    var location: CLLocation?
    var delegate: LocationSelectorDelegate?
    
    @IBOutlet weak var selectorMapView: MKMapView!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rbgmCoordinate = CLLocationCoordinate2D(latitude: -37.8303689, longitude: 144.9796056)
        var mapRegion = MKCoordinateRegion(center: rbgmCoordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
        
        if let existingCoordinate = location?.coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = existingCoordinate
            selectorMapView.addAnnotation(annotation)
            mapRegion = MKCoordinateRegion(center: existingCoordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        }
        
        selectorMapView.setRegion(mapRegion, animated: true)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapDidTapped))
        selectorMapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func mapDidTapped(gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: selectorMapView)
        let coordinate = selectorMapView.convert(tappedLocation, toCoordinateFrom: selectorMapView)
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        selectorMapView.removeAnnotations(selectorMapView.annotations)
        selectorMapView.addAnnotation(annotation)
        doneBarButtonItem.isEnabled = true
    }
    
    @IBAction func doneButtonDidTapped(_ sender: Any) {
        let _ = delegate?.didSelectedLocation(location: location!)
        navigationController?.popViewController(animated: true)
        return
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
