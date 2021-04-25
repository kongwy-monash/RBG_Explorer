//
//  DatabaseProtocol.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 10/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case exhibition
    case plant
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    var exhibition: Exhibition? {get}
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition])
    func onPlantChange(change: DatabaseChange, plants: [Plant])
    func onExhibitionPlantChange(change: DatabaseChange, exhibitionPlants: [Plant])
}

protocol DatabaseProtocol: AnyObject {
    var listeners: MulticastDelegate<DatabaseListener> {get}
    
    func cleanup()
    func resetDefaultEntries()
    
    func addExhibition(name: String, description: String, latitude: Double, longitude: Double, icon: Data) -> Exhibition
    func editExhibition(exhibition: Exhibition, name: String, description: String, latitude: Double, longitude: Double, icon: Data) -> Exhibition
    func deleteExhibition(exhibition: Exhibition)
    
    func addPlant(name: String, sname: String, family: String, year: Int) -> Plant
    func editPlant(plant: Plant, name: String, sname: String, family: String, year: Int) -> Plant
    func deletePlant(plant: Plant)
    
    func addPlentToExhibition(plant: Plant, exhibition: Exhibition) -> Bool
    func removePlentFromExhibition(plant: Plant, exhibition: Exhibition)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
