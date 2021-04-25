//
//  PlantTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 19/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class PlantTableViewController: UITableViewController {
    
    var webRequestController: WebRequestController?
    
    var plant: Plant?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var snameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        title = plant?.sname
        nameLabel.text = plant?.name ?? "Unknown"
        snameLabel.text = plant?.sname
        if let year = plant?.year {
            yearLabel.text = "\(year)"
        } else {
            yearLabel.text = "Unknown"
        }
        familyLabel.text = plant?.family ?? "Unknown"
        
        if let image = plant?.image {
            imageView.image = image
        } else {
            imageView.image = UIImage(imageLiteralResourceName: "plant_placeholder")
            webRequestController = WebRequestController()
            webRequestController!.delegate = self
            let _ = webRequestController!.fetchPlantImage(plant: plant!, indexPath: nil)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            // TODO
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlantSegue" {
            let destination = segue.destination as! EditPlantTableViewController
            destination.plant = plant
        }
    }

}

extension PlantTableViewController: WebRequestDelegate {
    func plantsDataDidFetched(plantsData: [PlantData]) {
        // PASS
    }
    
    func plantImageDataDidFetched(plantData: PlantData, imageData: Data, indexPath: IndexPath?) {
        // PASS
    }
    
    func plantImageDataDidFetched(plant: Plant, imageData: Data, indexPath: IndexPath?) {
        imageView.image = UIImage(data: imageData)
    }
}
