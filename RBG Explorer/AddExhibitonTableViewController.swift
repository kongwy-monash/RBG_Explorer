//
//  AddExhibitonTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 12/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import CoreLocation

class AddExhibitonTableViewController: UITableViewController, AddPlantForNewExhibitionDelegate {
    
    let iconPickerController: UIImagePickerController = UIImagePickerController()
    weak var databaseController: DatabaseProtocol?
    
    var existingExhibition: Exhibition?
    
    @IBOutlet weak var iconStackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var plantsCell: UITableViewCell!
    @IBOutlet weak var plantsLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var plantsOfNewExhibition = [Plant]()
    var plantsDataOfNewExhibition = [PlantData]()
    var imagesOfPlantsData = [PlantData: UIImage]()
    
    var locationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        iconPickerController.delegate = self
        iconPickerController.allowsEditing = true
        iconPickerController.mediaTypes = ["public.image"]
        
        iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.displayIconActionAlert)))
        iconImageView.isUserInteractionEnabled = true
        
        locationLabel.text = nil
        
        if let exhibition = existingExhibition {
            title = "Edit Exhibition"
            iconImageView.image = UIImage(data: (exhibition.icon)!)
            iconButton.setTitle("Edit Icon", for: .normal)
            nameTextField.text = exhibition.name
            locationCoordinate = CLLocationCoordinate2D(latitude: exhibition.latitude, longitude: exhibition.longitude)
            locationLabel.text = "Located"
            plantsCell.isUserInteractionEnabled = false
            plantsCell.accessoryType = .none
            plantsLabel.text = "Cannot Modify Here"
            descriptionTextView.text = exhibition.desc
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let count = plantsOfNewExhibition.count + plantsDataOfNewExhibition.count
        if existingExhibition == nil {
            plantsLabel.text = "\(count) of 3 at least added"
        }
    }
    
    @IBAction func iconButtonDidTapped(_ sender: Any) {
        self.displayIconActionAlert()
    }
    
    @objc func displayIconActionAlert() {
        let iconActionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let setIconAction = UIAlertAction(title: "Open Gallery", style: .default) { (action) in
            self.iconPickerController.sourceType = .photoLibrary
            self.present(self.iconPickerController, animated: true, completion: nil)
        }
        iconActionAlertController.addAction(setIconAction)
        let takeIconAction = UIAlertAction(title: "Take a Photo", style: .default) { (action) in
            self.iconPickerController.sourceType = .camera
            self.present(self.iconPickerController, animated: true, completion: nil)
        }
        iconActionAlertController.addAction(takeIconAction)
        
        if iconImageView.image != nil {
            let removeIconAction = UIAlertAction(title: "Remove Icon", style: .destructive) { (action) in
                self.iconImageView.image = nil
                self.iconButton.setTitle("Add Icon", for: .normal)
            }
            iconActionAlertController.addAction(removeIconAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        iconActionAlertController.addAction(cancelAction)
        
        present(iconActionAlertController, animated: true, completion: nil)
    }
    
    // MARK: Save Process
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        guard nameTextField.text != nil && nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && locationCoordinate != nil else {
            let saveAlert = UIAlertController(title: "Missing Fields", message: "Exhibition's name and location must be added.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            saveAlert.addAction(okAlertAction)
            present(saveAlert, animated: true, completion: nil)
            return
        }
        
        let iconImage: UIImage = iconImageView.image ?? UIImage(imageLiteralResourceName: "exhibition_placeholder")
        
        if let exhibition = existingExhibition {
            let _ = databaseController?.editExhibition(exhibition: exhibition, name: nameTextField.text!, description: descriptionTextView.text, latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude, icon: iconImage.pngData()!)
        } else {
            if plantsOfNewExhibition.count + plantsDataOfNewExhibition.count < 3 {
                let saveAlert = UIAlertController(title: "Insufficient Plants", message: "Must select at least 3 plants to add a exhibition.", preferredStyle: .alert)
                let okAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                saveAlert.addAction(okAlertAction)
                present(saveAlert, animated: true, completion: nil)
                return
            }
            
            if let newExhibition = databaseController?.addExhibition(name: nameTextField.text!, description: descriptionTextView.text, latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude, icon: iconImage.pngData()!) {
            
                for plant in plantsOfNewExhibition {
                    let _ = databaseController?.addPlentToExhibition(plant: plant, exhibition: newExhibition)
                }
                for plantData in plantsDataOfNewExhibition {
                    if let newPlant = databaseController?.addPlant(name: plantData.name ?? "", sname: plantData.sname!, family: plantData.family ?? "", year: plantData.year ?? 0) {
                        let _ = databaseController?.addPlentToExhibition(plant: newPlant, exhibition: newExhibition)
                    }
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectLocationSegue" {
            let destination = segue.destination as! LocationSelectorViewController
            destination.delegate = self
            if self.locationCoordinate != nil {
                destination.location = CLLocation(latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude)
            }
        }
        
        if segue.identifier == "editPlantsOfNewExhibitionSegue" {
            let destination = segue.destination as! AddPlantForNewExhibitionViewController
            destination.delegate = self
        }
    }
    
}

// MARK: - Image Picker Supports

extension AddExhibitonTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        iconImageView.image = (info[.editedImage] as! UIImage)
        iconButton.setTitle("Edit Icon", for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Location Selector Supports

extension AddExhibitonTableViewController: LocationSelectorDelegate {
    func didSelectedLocation(location: CLLocation) {
        print(location)
        self.locationCoordinate = location.coordinate
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                self.locationLabel.text = placemarks?[0].name
            } else {
                self.locationLabel.text = "Located"
            }
        }
    }
}
