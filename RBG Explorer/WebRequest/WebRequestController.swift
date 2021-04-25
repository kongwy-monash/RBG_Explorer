//
//  WebRequestController.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 17/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import Foundation

class WebRequestController: NSObject {
    
    let searchURI = "https://trefle.io/api/v1/plants/search"
    let token = ""
    
    var delegate: WebRequestDelegate?
    
    override init() {
        super.init()
    }
    
    func fetchPlants(keyword: String) {
        var searchURLComponents = URLComponents(string: searchURI)!
        searchURLComponents.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "q", value: keyword)
        ]
        
        let requestPlants = URLSession.shared.dataTask(with: searchURLComponents.url!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let rootData = try decoder.decode(RootData.self, from: data!)
                if let plantsData = rootData.plants {
                    DispatchQueue.main.async {
                        self.delegate?.plantsDataDidFetched(plantsData: plantsData)
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        
        requestPlants.resume()
    }
    
    func fetchPlantImage(plantData: PlantData, indexPath: IndexPath) -> URLSessionDataTask? {
        guard let imageURI = plantData.imageURI else {
            return nil
        }
        let plantimageURL = URL(string: imageURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let requestImageTask = URLSession.shared.dataTask(with: plantimageURL!) { (imageData, imageResponse, imageError) in
            if let imageError = imageError {
                print(imageError.localizedDescription)
                return
            }
            
            if imageData != nil {
                DispatchQueue.main.async {
                    self.delegate?.plantImageDataDidFetched(plantData: plantData, imageData: imageData!, indexPath: indexPath)
                }
            }
        }
        requestImageTask.resume()
        return requestImageTask
    }
    
    func fetchPlantImage(plant: Plant, indexPath: IndexPath?) -> URLSessionDataTask? {
        var searchURLComponents = URLComponents(string: searchURI)!
        searchURLComponents.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "q", value: plant.sname!)
        ]
        
        let requestImageURLTask = URLSession.shared.dataTask(with: searchURLComponents.url!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            do {
                let decoder = JSONDecoder()
                let rootData = try decoder.decode(RootData.self, from: data!)
                if rootData.plants!.count >= 1 {
                    let firstPlantData = rootData.plants![0]
                    let plantimageURL = URL(string: firstPlantData.imageURI!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    
                    let requestImageTask = URLSession.shared.dataTask(with: plantimageURL!) { (imageData, imageResponse, imageError) in
                        if let imageError = imageError {
                            print(imageError.localizedDescription)
                            return
                        }
                        
                        if imageData != nil {
                            DispatchQueue.main.async {
                                self.delegate?.plantImageDataDidFetched(plant: plant, imageData: imageData!, indexPath: indexPath)
                            }
                        }
                    }
                    requestImageTask.resume()
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        requestImageURLTask.resume()
        return requestImageURLTask
    }
}
