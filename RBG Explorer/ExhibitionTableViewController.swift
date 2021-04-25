//
//  ExhibitionTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 14/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExhibitionTableViewController: UITableViewController {
    
    let BASIC_SECTION = 0
    let PLANTS_SECTION = 1
    let DESCRIPTION_SECTION = 2
    let ACTION_SECTION = 3
    
    var webRequestController = WebRequestController()
    weak var databseController: DatabaseProtocol?
    var listenerType: ListenerType = .plant
    
    var exhibition: Exhibition?
    var plantsInExhibition: [Plant]?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRequestController.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databseController = appDelegate.databaseController

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = exhibition?.name
        
        let exhibitionLocationCoordinate = CLLocationCoordinate2D(latitude: exhibition!.latitude, longitude: exhibition!.longitude)
        let exhibitionCoordinateRegion = MKCoordinateRegion(center: exhibitionLocationCoordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        let exhibitionAnnotation = MKPointAnnotation()
        exhibitionAnnotation.coordinate = exhibitionLocationCoordinate
        mapView.setRegion(exhibitionCoordinateRegion, animated: true)
        mapView.setCenter(exhibitionLocationCoordinate, animated: true)
        mapView.addAnnotation(exhibitionAnnotation)
        
        iconImageView.image = UIImage(data: (exhibition?.icon)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        databseController?.addListener(listener: self)
        self.navigationItem.title = exhibition?.name
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case BASIC_SECTION:
            return 1
        case PLANTS_SECTION:
            return (plantsInExhibition?.count ?? 0) + 1
        case DESCRIPTION_SECTION:
            return 1
        case ACTION_SECTION:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case PLANTS_SECTION:
            return "Plants"
        case DESCRIPTION_SECTION:
            return "Description"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case BASIC_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicTableViewCell", for: indexPath)
            cell.textLabel!.text = "Name"
            cell.detailTextLabel!.text = exhibition?.name
            return cell
        case PLANTS_SECTION:
            // Add New Plant Cell
            if indexPath.row == plantsInExhibition?.count ?? 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addPlantTableViewCell", for: indexPath)
                return cell
            }
            
            // Plant Cell
            let plant = plantsInExhibition![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! ExhibitionTableViewCell
            cell.nameLabel.text = plant.sname
            cell.descLabel.text = plant.name
            
            if let image = plant.image {
                cell.iconImageView.image = image
            } else {
                cell.iconImageView.image = UIImage(imageLiteralResourceName: "plant_placeholder")
                let _ = webRequestController.fetchPlantImage(plant: plant, indexPath: indexPath)
            }
            
            return cell
        case DESCRIPTION_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionTableViewCell", for: indexPath)
            cell.textLabel!.text = exhibition?.desc
            return cell
        case ACTION_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionTableViewCell", for: indexPath)
            cell.textLabel!.text = "Edit Exhibition"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == PLANTS_SECTION {
            if indexPath.row == plantsInExhibition?.count ?? 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let addPlantViewController = storyboard.instantiateViewController(identifier: "AddPlantTableView") as AddPlantTableViewController
                addPlantViewController.delegate = self
                navigationController?.pushViewController(addPlantViewController, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let plantTableViewController = storyboard.instantiateViewController(identifier: "PlantTableView") as PlantTableViewController
                plantTableViewController.plant = plantsInExhibition![indexPath.row]
                navigationController?.pushViewController(plantTableViewController, animated: true)
            }
        }
        
        if indexPath.section == ACTION_SECTION && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addExhibitionViewController = storyboard.instantiateViewController(identifier: "AddExhibitionTableView") as AddExhibitonTableViewController
            addExhibitionViewController.existingExhibition = exhibition
            navigationController?.pushViewController(addExhibitionViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == PLANTS_SECTION && indexPath.row != plantsInExhibition?.count ?? 0 {
            return true
        }
        return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databseController?.removePlentFromExhibition(plant: plantsInExhibition![indexPath.row], exhibition: exhibition!)
        }
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

// MARK: - Web Request Delegate

extension ExhibitionTableViewController: WebRequestDelegate {
    
    func plantsDataDidFetched(plantsData: [PlantData]) {
        // PASS
    }
    
    func plantImageDataDidFetched(plantData: PlantData, imageData: Data, indexPath: IndexPath?) {
        // PASS
    }
    
    func plantImageDataDidFetched(plant: Plant, imageData: Data, indexPath: IndexPath?) {
        plant.image = UIImage(data: imageData)
        self.tableView.reloadRows(at: [indexPath!], with: .automatic)
    }
    
}

// MARK: - Add Plant Delegate

extension ExhibitionTableViewController: AddPlantDelegate {
    
    func didSelectExistingPlant(plant: Plant) {
        if plantsInExhibition?.contains(plant) ?? false {
            let alert = UIAlertController(title: "Existing Plant", message: "Cannot add a duplicate plant.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let _ = databseController?.addPlentToExhibition(plant: plant, exhibition: exhibition!)
    }
    
    func didSelectPlant(plantData: PlantData, image: UIImage) {
        if let newPlant = databseController?.addPlant(name: plantData.name ?? "Unknown", sname: plantData.sname!, family: plantData.family ?? "Unknown", year: plantData.year ?? Int()) {
            guard let _ = databseController?.addPlentToExhibition(plant: newPlant, exhibition: exhibition!) else {
                print("Faild to add new plant to exhibition.")
                return
            }
        } else {
            print("Faild to add new plant.")
        }
    }
    
}

// MARK: - Core Data Supports

extension ExhibitionTableViewController: DatabaseListener {
    
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // PASS
    }
    
    func onPlantChange(change: DatabaseChange, plants: [Plant]) {
        // PASS 
    }
    
    func onExhibitionPlantChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        plantsInExhibition = exhibitionPlants
        tableView.reloadData()
    }
    
}
