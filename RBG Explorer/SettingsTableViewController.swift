//
//  SettingsTableViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 20/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutLabel.text = """
        RBG Explorer is an assignment project for FIT5140 from Monash University.
        
        Developed by Davis Weiyi Kong.
        """
    }
    
    @IBAction func doneButtonDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let alert = UIAlertController(title: "Erase Data", message: "Resetting data will delete all existing data and replace with default data. Are you sure to continue?", preferredStyle: .alert)
            let confirmAlertAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let databaseController = appDelegate.databaseController
                databaseController?.resetDefaultEntries()
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(confirmAlertAction)
            alert.addAction(cancelAlertAction)
            present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
