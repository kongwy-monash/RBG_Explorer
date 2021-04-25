//
//  MapViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 7/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    var rbgmLocation = CLLocationCoordinate2D(latitude: -37.8303689, longitude: 144.9796056)
    
    var currentLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var rbgmCLRegion: CLCircularRegion?
    
    var databseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibition
    var exhibition: Exhibition?     // Ignore, for Database Controller
    var exhibitions: [Exhibition] = [Exhibition]()
    var exhibitionAnnotations: [ExhibitionMapAnnotation] = [ExhibitionMapAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databseController = appDelegate.databaseController
        
        // Init Map View
        let rbgmMKRegion = MKCoordinateRegion(center: self.rbgmLocation, latitudinalMeters: 1200, longitudinalMeters: 1200)
        mapView.setRegion(rbgmMKRegion, animated: true)
        mapView.delegate = self
        
        // Init Location Manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        rbgmCLRegion = CLCircularRegion(center: self.rbgmLocation, radius: 1500, identifier: "Royal Botanic Gardens Victoria Melbourne Gardens")
        rbgmCLRegion?.notifyOnEntry = true
        rbgmCLRegion?.notifyOnExit = true
        
        databseController?.addListener(listener: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let authorisationStatus = CLLocationManager.authorizationStatus()
        switch authorisationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.startMonitoring(for: rbgmCLRegion!)
            break
        default:
            inViewNotification(message: "Location permission hasn't been granted.")
            break
        }
    }
    
    func updateExhibitionAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        for exhibitionItem in exhibitions {
            let annotation = ExhibitionMapAnnotation(exhibition: exhibitionItem)
            exhibitionAnnotations.append(annotation)
        }
        mapView.addAnnotations(exhibitionAnnotations)
    }
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func inViewNotification(message: String) {
        self.notificationLabel.text = message
        let showAnimator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 1) {
            self.notificationViewYConstraint.constant += 44
            self.view.layoutIfNeeded()
        }
        self.view.layoutIfNeeded()
        showAnimator.startAnimation()
        let closeAnimator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 1) {
            self.notificationViewYConstraint.constant -= 44
            self.view.layoutIfNeeded()
        }
        self.view.layoutIfNeeded()
        closeAnimator.startAnimation(afterDelay: 5)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAllSegue" {
            let destination = segue.destination as! AllExhibitionViewController
            destination.delegate = self
        }
    }

}

// MARK: - Location Manager Delegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("status changed")
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            inViewNotification(message: "Location permission hasn't been granted.")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        currentLocation = location.coordinate
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if rbgmCLRegion?.contains(location.coordinate) ?? false {
                mapView.showsUserLocation = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        mapView.showsUserLocation = true
        inViewNotification(message: "Welcome to RBGV!")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        mapView.showsUserLocation = false
        inViewNotification(message: "See you next time!")
    }
    
}

// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotation = annotation as! ExhibitionMapAnnotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        annotationView?.annotation = annotation
        annotationView?.image = UIImage(named: "annotation")
        
        annotationView?.canShowCallout = true
        
        let calloutImageView = UIImageView(image: annotation.icon)
        calloutImageView.frame = CGRect(x: calloutImageView.frame.origin.x, y: calloutImageView.frame.origin.y, width: 40, height: 40)
        calloutImageView.contentMode = .scaleAspectFill
        calloutImageView.layer.cornerRadius = 5
        calloutImageView.layer.masksToBounds = true
        annotationView?.leftCalloutAccessoryView = calloutImageView
        
        let calloutDetailDescription = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        calloutDetailDescription.font = calloutDetailDescription.font.withSize(12)
        calloutDetailDescription.text = annotation.exhibition?.desc
        annotationView?.detailCalloutAccessoryView = calloutDetailDescription
        
        let calloutDetailButton = MapExhibitionButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        calloutDetailButton.exhibition = annotation.exhibition
        calloutDetailButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        calloutDetailButton.addTarget(self, action: #selector(presentExhibition), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = calloutDetailButton
        
        return annotationView
    }
    
    @objc func presentExhibition(sender: MapExhibitionButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let exhibitionViewController = storyboard.instantiateViewController(identifier: "ExhibitionTableView") as ExhibitionTableViewController
        exhibitionViewController.exhibition = sender.exhibition!
        navigationController?.pushViewController(exhibitionViewController, animated: true)
    }
    
}

class MapExhibitionButton: UIButton {
    var exhibition: Exhibition?
}

// MARK: - All Exhibition Delegate

extension MapViewController: AllExhibitionDelegate {
    func didSelectExhibition(exhibition: Exhibition, indexPath: IndexPath) {
        mapView.selectAnnotation(exhibitionAnnotations[indexPath.row], animated: true)
        let exhibitionLocation = CLLocationCoordinate2D(latitude: exhibition.latitude, longitude: exhibition.longitude)
        let exhibitionRegion = MKCoordinateRegion(center: exhibitionLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(exhibitionRegion, animated: true)
    }
}

// MARK: - Core Data Supports

extension MapViewController: DatabaseListener {
    
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        self.exhibitions = exhibitions
        updateExhibitionAnnotation()
    }
    
    func onPlantChange(change: DatabaseChange, plants: [Plant]) {
        // PASS
    }
    
    func onExhibitionPlantChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // PASS
    }
    
}
