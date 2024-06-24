//
//  apiInterfaceDrinks.swift
//  newmacrotrackerfront
//
//  Created by Cole Price on 6/23/24.
//

import Foundation

struct Drink: Identifiable, Codable {
    var id: String
    var name: String
    var volume: Volume
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct Volume: Codable {
    var value: Int
    var unit: VolumeUnit
}

enum VolumeUnit: String, Codable, CaseIterable {
    case mL
    case L
    case c
    case oz
}

// Get All Drinks
func getAllDrinks(_ completion: @escaping (Result<[Drink], Error>) -> Void) {
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/drinks/")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    
    // Container for fetched drinks
    var drinks: [Drink] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any],
           let drinkArray = json["drinks"] as? [Any] {
            
            print("Data received and parsed")
            
            // Try to parse out the drink items
            for object in drinkArray {
                if let currDrink = object as? [AnyHashable: Any] {
                    if let id = currDrink["_id"] as? String,
                       let name = currDrink["name"] as? String,
                       // For pulling weight object values
                       let volumeDict = currDrink["volume"] as? [String: Any],
                       let value = volumeDict["value"] as? Int,
                       let unit = volumeDict["unit"] as? String,
                       let volumeUnit = VolumeUnit(rawValue: unit),
                       let calories = currDrink["calories"] as? Int,
                       let protein = currDrink["protein"] as? Int,
                       let carbs = currDrink["carbs"] as? Int,
                       let fat = currDrink["fat"] as? Int
                    {
                        
                        let volume = Volume(value: value, unit: volumeUnit)
                        drinks.append(Drink(
                            id: id,
                            name: name,
                            volume: volume,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat
                            
                        ))
                    } else {
                        print("Failed to parse drink item: \(currDrink)")
                    }
                }
            }
            print("Drinks parsed: \(drinks)")
            completion(.success(drinks))
        } else if let error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

