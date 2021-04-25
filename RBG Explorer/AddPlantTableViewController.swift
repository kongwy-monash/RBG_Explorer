//
//  AddPlantTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 17/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

protocol AddPlantDelegate {
    func didSelectExistingPlant(plant: Plant)
    func didSelectPlant(plantData: PlantData, image: UIImage)
}

class AddPlantTableViewController: UITableViewController {
    
    let RESULT_SECTION = 0
    
    var webRequestController = WebRequestController()
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .plant
    var exhibition: Exhibition?
    
    var delegate: AddPlantDelegate?
    var indicator = UIActivityIndicatorView()
    var ongoingDataTask = [URLSessionDataTask?]()
    
    var isSearchOffline = true
    var allPlants: [Plant] = [Plant]()
    var filteredPlants: [Plant] = [Plant]()
    var resultPlantsData = [PlantData]()
    var resultImages = [PlantData: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRequestController.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Plants"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        filteredPlants = allPlants
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case RESULT_SECTION:
            if !isSearchOffline {
                return resultPlantsData.count
            } else {
                return filteredPlants.count
            }
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case RESULT_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! ExhibitionTableViewCell
            if !isSearchOffline {
                let plantData = resultPlantsData[indexPath.row]
                
                cell.nameLabel.text = plantData.sname
                cell.descLabel.text = plantData.name
                
                if let image = resultImages[plantData] {
                    cell.iconImageView.image = image
                } else {
                    cell.iconImageView.image = UIImage(imageLiteralResourceName: "plant_placeholder")
                    let newDataTask = webRequestController.fetchPlantImage(plantData: plantData, indexPath: indexPath)
                    ongoingDataTask.append(newDataTask)
                }
            } else {
                let plant = filteredPlants[indexPath.row]
                
                cell.nameLabel.text = plant.sname
                cell.descLabel.text = plant.name
                
                if let image = plant.image {
                    cell.iconImageView.image = image
                } else {
                    cell.iconImageView.image = UIImage(imageLiteralResourceName: "plant_placeholder")
                    let newDataTask = webRequestController.fetchPlantImage(plant: plant, indexPath: indexPath)
                    ongoingDataTask.append(newDataTask)
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearchOffline {
            delegate?.didSelectExistingPlant(plant: filteredPlants[indexPath.row])
        } else {
            delegate?.didSelectPlant(plantData: resultPlantsData[indexPath.row], image: resultImages[resultPlantsData[indexPath.row]] ?? UIImage(imageLiteralResourceName: "plant_placeholder"))
        }
        
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - Core Data Supports

extension AddPlantTableViewController: DatabaseListener {
    
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // PASS
    }
    
    func onPlantChange(change: DatabaseChange, plants: [Plant]) {
        allPlants = plants
        searchBarSearchButtonClicked(navigationItem.searchController!.searchBar)
        tableView.reloadData()
    }
    
    func onExhibitionPlantChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // PASS
    }
    
}

// MARK: - Search Bar Delegate

extension AddPlantTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        for dataTask in ongoingDataTask {
            dataTask?.cancel()
        }
        
        if searchText.count == 0 {
            isSearchOffline = true
            filteredPlants = allPlants
            tableView.reloadData()
            return
        }
        
        filteredPlants = allPlants.filter({ (plant: Plant) -> Bool in
            guard let sname = plant.sname else {
                return false
            }
            return sname.lowercased().contains(searchText.lowercased())
        })
        
        if filteredPlants.count > 0 {
            isSearchOffline = true
            tableView.reloadData()
        } else {
            isSearchOffline = false
            indicator.startAnimating()
            indicator.backgroundColor = UIColor.clear
            webRequestController.fetchPlants(keyword: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        for dataTask in ongoingDataTask {
            dataTask?.cancel()
        }
        
        isSearchOffline = true
        filteredPlants = allPlants
        tableView.reloadData()
    }
    
}

// MARK: - Web Request Delegate

extension AddPlantTableViewController: WebRequestDelegate {
    
    func plantsDataDidFetched(plantsData: [PlantData]) {
        resultPlantsData = plantsData
        tableView.reloadData()
        indicator.stopAnimating()
    }
    
    func plantImageDataDidFetched(plantData: PlantData, imageData: Data, indexPath: IndexPath?) {
        resultImages[plantData] = UIImage(data: imageData)
        tableView.reloadRows(at: [indexPath!], with: .automatic)
    }
    
    func plantImageDataDidFetched(plant: Plant, imageData: Data, indexPath: IndexPath?) {
        plant.image = UIImage(data: imageData)
        tableView.reloadRows(at: [indexPath!], with: .automatic)
    }
    
}
