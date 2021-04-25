//
//  CoreDataController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 11/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    // Fetched Results Controllers
    var allExhibitionsFetchedResultsController: NSFetchedResultsController<Exhibition>?
    var allPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    var exhibitionPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    
    override init() {
        // Load Persistent Container
        persistentContainer = NSPersistentContainer(name: "RBG")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        }
        
        super.init()
    }
    
    // MARK: - Core Data stack
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Failed to save to CoreData: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Database Protocol Functions
    func cleanup() {
        saveContext()
    }
    
    func addExhibition(name: String, description: String, latitude: Double, longitude: Double, icon: Data) -> Exhibition {
        let exhibition = NSEntityDescription.insertNewObject(forEntityName: "Exhibition", into: persistentContainer.viewContext) as! Exhibition
        exhibition.name = name
        exhibition.desc = description
        exhibition.latitude = latitude
        exhibition.longitude = longitude
        exhibition.icon = icon

        return exhibition
    }
    
    func editExhibition(exhibition: Exhibition, name: String, description: String, latitude: Double, longitude: Double, icon: Data) -> Exhibition {
        exhibition.setValuesForKeys([
            "name": name,
            "desc": description,
            "latitude": latitude,
            "longitude": longitude,
            "icon": icon
        ])
        return exhibition
    }
    
    func deleteExhibition(exhibition: Exhibition) {
        persistentContainer.viewContext.delete(exhibition)
    }
    
    func addPlant(name: String, sname: String, family: String, year: Int) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistentContainer.viewContext) as! Plant
        plant.name = name
        plant.sname = sname
        plant.family = family
        plant.year = Int16(year)
        
        return plant
    }
    
    func editPlant(plant: Plant, name: String, sname: String, family: String, year: Int) -> Plant {
        plant.setValuesForKeys([
            "name": name,
            "sname": sname,
            "family": family,
            "year": year
        ])
        return plant
    }
    
    func deletePlant(plant: Plant) {
        persistentContainer.viewContext.delete(plant)
    }
    
    func addPlentToExhibition(plant: Plant, exhibition: Exhibition) -> Bool {
        guard let plants = exhibition.plants, plants.contains(plant) == false else {
            return false
        }
        exhibition.addToPlants(plant)
        return true
    }
    
    func removePlentFromExhibition(plant: Plant, exhibition: Exhibition) {
        exhibition.removeFromPlants(plant)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .exhibition || listener.listenerType == .all {
            listener.onExhibitionChange(change: .update, exhibitions: fetchAllExhibitions())
        }
        
        if listener.listenerType == .plant || listener.listenerType == .all {
            listener.onPlantChange(change: .update, plants: fetchAllPlants())
            if let exhibitionName = listener.exhibition?.name {
                listener.onExhibitionPlantChange(change: .update, exhibitionPlants: fetchExhibitionPlants(exhibitionName: exhibitionName))
            }
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK: - Fetched Results Controller Protocol Functions
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allExhibitionsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .exhibition || listener.listenerType == .all {
                    listener.onExhibitionChange(change: .update, exhibitions: fetchAllExhibitions())
                }
            }
        } else if controller == allPlantsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .plant || listener.listenerType == .all {
                    listener.onPlantChange(change: .update, plants: fetchAllPlants())
                }
            }
        }
        
        listeners.invoke { (listener) in
            if let exhibitionName = listener.exhibition?.name {
                listener.onExhibitionPlantChange(change: .update, exhibitionPlants: fetchExhibitionPlants(exhibitionName: exhibitionName))
            }
        }
    }
    
    // MARK: - Core Data Fetch Requests
    func fetchAllExhibitions() -> [Exhibition] {
        if allExhibitionsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allExhibitionsFetchedResultsController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allExhibitionsFetchedResultsController?.delegate = self
            do {
                try allExhibitionsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(error)")
            }
        }
        
        var exhibitions = [Exhibition]()
        if allExhibitionsFetchedResultsController?.fetchedObjects != nil {
            exhibitions = (allExhibitionsFetchedResultsController?.fetchedObjects)!
        }
        
        return exhibitions
    }
    
    func fetchAllPlants() -> [Plant] {
        if allPlantsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allPlantsFetchedResultsController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allPlantsFetchedResultsController?.delegate = self
            do {
                try allPlantsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(error)")
            }
        }
        
        var plants = [Plant]()
        if allPlantsFetchedResultsController?.fetchedObjects != nil {
            plants = (allPlantsFetchedResultsController?.fetchedObjects)!
        }
        
        return plants
    }
    
    func fetchExhibitionPlants(exhibitionName: String) -> [Plant] {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "ANY exhibitions.name == %@", exhibitionName)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        fetchRequest.predicate = predicate
        
        exhibitionPlantsFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try exhibitionPlantsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch request failed: \(error)")
        }
        
        var plants = [Plant]()
        if exhibitionPlantsFetchedResultsController?.fetchRequest != nil {
            plants = (exhibitionPlantsFetchedResultsController?.fetchedObjects)!
        }
        
        return plants
    }
    
    // MARK: - Default Entry Generation
    func resetDefaultEntries() {
        // Delete All Data
        let allExhibitions = fetchAllExhibitions()
        for exhibition in allExhibitions {
            deleteExhibition(exhibition: exhibition)
        }
        let allPlants = fetchAllPlants()
        for plant in allPlants {
            deletePlant(plant: plant)
        }
        
        // Create Default Data
        let aridGarden = addExhibition(name: "Arid Garden", description: "The Arid Garden displays an extraordinary assortment of cacti, aloes, agaves and bromeliads that have unique adaptions to arid conditions. The collection is approximately 60 years old and comprises over 1,100 plants including 100 rare species.", latitude: -37.8320012, longitude: 144.9808739, icon: UIImage(imageLiteralResourceName: "arid_garden").pngData()!)
        let australianForestWalk = addExhibition(name: "Australian Forest Walk", description: "The Australian Forest Walk focuses on displaying a range of Australian forest species from impressive forest giants to middle- and understorey trees and shrubs.", latitude: -37.8314647, longitude: 144.9754102, icon: UIImage(imageLiteralResourceName: "australian_forest_walk").pngData()!)
        let bambooCollection = addExhibition(name: "Bamboo Collection", description: "Melbourne Gardens exhibits a broad range of Bamboo from different regions of the world across the entire site and maintains a consolidated collection within the Bamboo Collection beds. A key objective of the Bamboo collection is to highlight the significant ethnobotanical uses of bamboo and grasses and the vital role they contribute to for life on earth and highlights the threats to grass biodiversity and biomes they support.", latitude: -37.8306002, longitude: 144.9797964, icon: UIImage(imageLiteralResourceName: "bamboo_collection").pngData()!)
        let camelliaCollection = addExhibition(name: "Camellia Collection", description: "We have 950 different Camellias in our collection, made up of species and cultivars, and the best place to satisfy your Camellia craving is by going straight to the Camellia Bed!  This large bed contains a beautiful range of Camellias of all shapes and sizes.", latitude: -37.831013, longitude: 144.9770531, icon: UIImage(imageLiteralResourceName: "camellia_collection").pngData()!)
        let cycadCollection = addExhibition(name: "Cycad Collection", description: "Slow growing plants, palm like in appearance but classified in a distinct group. Plants are either female or male and produce cones containing either seed or pollen. Cycads are gymnosperms (naked seeded), i.e. their unfertilised seeds are open to the air to be directly fertilised by pollen. The bacteria in coralloid roots fix nitrogen from the air allowing good growth in poor soils. It also produce a neurotoxin which can be found in seeds. Cycads occur in tropical or subtropical parts of Japan, Pacific Islands, Australia, Central America, China, India, Madagascar and the east coast of Africa.", latitude: -37.8310034, longitude: 144.9803683, icon: UIImage(imageLiteralResourceName: "cycad_collection").pngData()!)
        
        let yuccaBrevifolia = addPlant(name: "Joshua tree", sname: "Yucca brevifolia", family: "Asparagaceae", year: 1871)
        let euphorbiaTriangularis = addPlant(name: "Tree euphorbia", sname: "Euphorbia triangularis", family: "Euphorbiaceae", year: 1906)
        let dracaenaDraco = addPlant(name: "Canary Islands dragon tree", sname: "Dracaena draco", family: "Asparagaceae", year: 1814)
        let agaveParviflora = addPlant(name: "Smallflower century plant", sname: "Agave parviflora", family: "Asparagaceae", year: 1858)
        
        let _ = addPlentToExhibition(plant: yuccaBrevifolia, exhibition: aridGarden)
        let _ = addPlentToExhibition(plant: euphorbiaTriangularis, exhibition: aridGarden)
        let _ = addPlentToExhibition(plant: dracaenaDraco, exhibition: aridGarden)
        let _ = addPlentToExhibition(plant: agaveParviflora, exhibition: aridGarden)
        
        let elaeocarpusReticulatus = addPlant(name: "Blueberry Ash", sname: "Elaeocarpus reticulatus", family: "Elaeocarpaceae", year: 1809)
        let toonaCiliata = addPlant(name: "Red Cedar", sname: "Toona ciliata", family: "Meliaceae", year: 1917)
        let banksiaSerrata = addPlant(name: "Saw Banksia", sname: "Banksia serrata", family: "Proteaceae", year: 1782)
        
        let _ = addPlentToExhibition(plant: elaeocarpusReticulatus, exhibition: australianForestWalk)
        let _ = addPlentToExhibition(plant: toonaCiliata, exhibition: australianForestWalk)
        let _ = addPlentToExhibition(plant: banksiaSerrata, exhibition: australianForestWalk)
        
        let bambusaBalcooa = addPlant(name: "Female Bamboo", sname: "Bambusa balcooa", family: "Poaceae", year: 1832)
        let phyllostachysNigra = addPlant(name: "Black Bamboo", sname: "Phyllostachys nigra", family: "Poaceae", year: 1868)
        let xanthorrhoeaAustralis = addPlant(name: "Austral grasstree", sname: "Xanthorrhoea australis", family: "Asphodelaceae", year: 1810)
        
        let _ = addPlentToExhibition(plant: bambusaBalcooa, exhibition: bambooCollection)
        let _ = addPlentToExhibition(plant: phyllostachysNigra, exhibition: bambooCollection)
        let _ = addPlentToExhibition(plant: xanthorrhoeaAustralis, exhibition: bambooCollection)
        
        let camelliaNitidissima = addPlant(name: "Yellow camellia", sname: "Camellia nitidissima", family: "Theaceae", year: 1949)
        let camelliaReticulata = addPlant(name: "Unknown", sname: "Camellia reticulata", family: "Theaceae", year: 1390)
        let camelliaTsaii = addPlant(name: "Unknown", sname: "Camellia tsaii", family: "Theaceae", year: 1938)
        
        let _ = addPlentToExhibition(plant: camelliaNitidissima, exhibition: camelliaCollection)
        let _ = addPlentToExhibition(plant: camelliaReticulata, exhibition: camelliaCollection)
        let _ = addPlentToExhibition(plant: camelliaTsaii, exhibition: camelliaCollection)
        
        let macrozamiaCommunis = addPlant(name: "Burrawong", sname: "Macrozamia communis", family: "Zamiaceae", year: 1959)
        let encephalartosAltensteinii = addPlant(name: "Prickly cycad", sname: "Encephalartos altensteinii", family: "Zamiaceae", year: 1834)
        let ceratozamiaMexicana = addPlant(name: "Cycad", sname: "Ceratozamia mexicana", family: "Zamiaceae", year: 1846)
        
        let _ = addPlentToExhibition(plant: macrozamiaCommunis, exhibition: cycadCollection)
        let _ = addPlentToExhibition(plant: encephalartosAltensteinii, exhibition: cycadCollection)
        let _ = addPlentToExhibition(plant: ceratozamiaMexicana, exhibition: cycadCollection)
    }
}
