//
//  AllExhibitionViewController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 7/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

protocol AllExhibitionDelegate {
    func didSelectExhibition(exhibition: Exhibition, indexPath: IndexPath)
}

class AllExhibitionViewController: UIViewController {
    
    let SECTION_EXHIBITON = 0
    let SECTION_INFO = 1
    let CELL_EXHIBITION = "exhibitionCell"
    let CELL_INFO = "exhibitionCell"
    
    var delegate: AllExhibitionDelegate?
    
    var allExhibitions: [Exhibition] = []
    var filteredExhibitions: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibition

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var countBarItem: UIBarButtonItem!
    @IBOutlet weak var sortBarButtonItem: UIBarButtonItem!
    var sortButtonState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredExhibitions = allExhibitions
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        tableView.delegate = self
        tableView.dataSource = self
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibitions"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func editButtonDidTapped(_ sender: Any) {
        if tableView.isEditing == false {
            tableView.setEditing(true, animated: true)
            editBarButtonItem.title = "Done"
            editBarButtonItem.style = .done
            return
        }
        
        tableView.setEditing(false, animated: true)
        
        editBarButtonItem.title = "Edit"
        editBarButtonItem.style = .plain
        return
    }
    
    @IBAction func sortExhibitions(_ sender: Any) {
        switch sortButtonState {
        case false:
            sortButtonState.toggle()
            sortBarButtonItem.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        case true:
            sortButtonState.toggle()
            sortBarButtonItem.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        }
        filteredExhibitions = filteredExhibitions.reversed()
        tableView.reloadData()
    }
    
}

// MARK: - Database Update

extension AllExhibitionViewController: DatabaseListener {
    
    var exhibition: Exhibition? {
        return nil
    }
    
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitions = exhibitions
        updateSearchResults(for: navigationItem.searchController!)
        countBarItem.title = "Total: \(allExhibitions.count)"
        tableView.reloadData()
    }
    
    func onPlantChange(change: DatabaseChange, plants: [Plant]) {
        // PASS
    }
    
    func onExhibitionPlantChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // PASS
    }
    
}

// MARK: - Search Bar Support

extension AllExhibitionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        if searchText.count > 0 {
            filteredExhibitions = allExhibitions.filter({ (exhibition: Exhibition) -> Bool in
                guard let name = exhibition.name else {
                    return false
                }
                return name.contains(searchText)
            })
        } else {
            filteredExhibitions = allExhibitions
        }
        
        tableView.reloadData()
    }
}

// MARK: - Table View Support

extension AllExhibitionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectExhibition(exhibition: filteredExhibitions[indexPath.row], indexPath: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        countBarItem.title = "Total: \(allExhibitions.count)"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.deleteExhibition(exhibition: filteredExhibitions[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let exhibitionViewController = storyboard.instantiateViewController(identifier: "ExhibitionTableView") as ExhibitionTableViewController
        exhibitionViewController.exhibition = filteredExhibitions[indexPath.row]
        navigationController?.pushViewController(exhibitionViewController, animated: true)
    }
    
}

extension AllExhibitionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_EXHIBITON:
            return filteredExhibitions.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exhibitonCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXHIBITION, for: indexPath) as! ExhibitionTableViewCell
        let exhibiton = filteredExhibitions[indexPath.row]
        exhibitonCell.nameLabel.text = exhibiton.name
        exhibitonCell.descLabel.text = exhibiton.desc
        exhibitonCell.iconImageView.image = exhibiton.icon != nil ? UIImage(data: exhibiton.icon!) : UIImage(imageLiteralResourceName: "exhibition_placeholder")
        return exhibitonCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
