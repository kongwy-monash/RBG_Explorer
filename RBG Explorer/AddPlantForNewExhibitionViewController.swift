//
//  AddPlantForNewExhibitionViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 19/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

protocol AddPlantForNewExhibitionDelegate {
    var plantsOfNewExhibition: [Plant] {get set}
    var plantsDataOfNewExhibition: [PlantData] {get set}
    var imagesOfPlantsData: [PlantData: UIImage] {get set}
}

class AddPlantForNewExhibitionViewController: UIViewController {
    
    var delegate: AddPlantForNewExhibitionDelegate?
    
    let LOCAL_PLANT_SECTION = 0
    let REMOTE_PLANT_SECTION = 1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var messageBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func addPlantButtonDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addPlantTableViewController = storyboard.instantiateViewController(identifier: "AddPlantTableView") as AddPlantTableViewController
        addPlantTableViewController.delegate = self
        navigationController?.pushViewController(addPlantTableViewController, animated: true)
    }
    
    @IBAction func editButtonDidTapped(_ sender: Any) {
        if tableView.isEditing == false {
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
            editButton.style = .done
            return
        }
        
        tableView.setEditing(false, animated: true)
        editButton.title = "Edit"
        editButton.style = .plain
        return
    }
    
    func meetsRequirement() -> Int {
        let count = delegate!.plantsOfNewExhibition.count + delegate!.plantsDataOfNewExhibition.count
        if count < 3 {
            messageBarItem.title = "\(count) / 3 at least added"
        } else {
            messageBarItem.image = UIImage(systemName: "checkmark.circle.fill")
        }
        return count
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

// MARK: - Table View Supports

extension AddPlantForNewExhibitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if meetsRequirement() == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if meetsRequirement() == 0 {
            return 1
        }
        
        switch section {
        case LOCAL_PLANT_SECTION:
            return delegate!.plantsOfNewExhibition.count
        case REMOTE_PLANT_SECTION:
            return delegate!.plantsDataOfNewExhibition.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if meetsRequirement() == 0 {
            return nil
        }
        
        switch section {
        case LOCAL_PLANT_SECTION:
            return "From Local"
        case REMOTE_PLANT_SECTION:
            return "From Remote"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if meetsRequirement() == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
            cell.textLabel?.text = "Tap + to add plants for the new exhibition."
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! ExhibitionTableViewCell
        
        switch indexPath.section {
        case LOCAL_PLANT_SECTION:
            let plant = delegate!.plantsOfNewExhibition[indexPath.row]
            cell.nameLabel.text = plant.sname
            cell.descLabel.text = plant.name
            cell.iconImageView.image = plant.image
            return cell
        case REMOTE_PLANT_SECTION:
            let plantData = delegate!.plantsDataOfNewExhibition[indexPath.row]
            cell.nameLabel.text = plantData.sname
            cell.descLabel.text = plantData.name
            cell.iconImageView.image = delegate!.imagesOfPlantsData[plantData]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if meetsRequirement() == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case LOCAL_PLANT_SECTION:
                delegate?.plantsOfNewExhibition.remove(at: indexPath.row)
            case REMOTE_PLANT_SECTION:
                delegate?.plantsDataOfNewExhibition.remove(at: indexPath.row)
            default:
                return
            }
            tableView.reloadData()
        }
    }
    
}

// MARK: - Add Plant Delegate

extension AddPlantForNewExhibitionViewController: AddPlantDelegate {
    
    func didSelectExistingPlant(plant: Plant) {
        if delegate!.plantsOfNewExhibition.contains(plant) {
            let alert = UIAlertController(title: "Existing Plant", message: "Cannot add a duplicate plant.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        delegate!.plantsOfNewExhibition.append(plant)
        tableView.reloadData()
    }
    
    func didSelectPlant(plantData: PlantData, image: UIImage) {
        for addedPlantData in delegate!.plantsDataOfNewExhibition {
            if plantData.sname == addedPlantData.sname {
                let alert = UIAlertController(title: "Existing Plant", message: "Cannot add a duplicate plant.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        delegate!.plantsDataOfNewExhibition.append(plantData)
        delegate!.imagesOfPlantsData[plantData] = image
        tableView.reloadData()
    }
    
}
