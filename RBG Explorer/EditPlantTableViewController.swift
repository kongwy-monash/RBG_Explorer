//
//  EditPlantTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 19/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class EditPlantTableViewController: UITableViewController {
    
    var databaseController: DatabaseProtocol?
    var plant: Plant?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var snameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = plant?.name
        snameTextField.text = plant?.sname
        if let year = plant?.year {
            yearTextField.text = "\(year)"
        }
        familyTextField.text = plant?.family
        
        databaseController = CoreDataController()
    }
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        guard let sname = snameTextField.text else {
            let saveAlert = UIAlertController(title: "Missing Fields", message: "Plant's scientific name must be added.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            saveAlert.addAction(okAlertAction)
            present(saveAlert, animated: true, completion: nil)
            return
        }
        let _ = databaseController?.editPlant(plant: plant!, name: nameTextField.text ?? "", sname: sname, family: familyTextField.text ?? "", year: Int(yearTextField.text!) ?? 0)
        navigationController?.popViewController(animated: true)
    }

}
