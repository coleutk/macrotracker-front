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
    var carbs: Int?
    var fat: Int?
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
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "\(baseURL)/drinks/")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
                       // For pulling volume object values
                       let volumeDict = currDrink["volume"] as? [String: Any],
                       let value = volumeDict["value"] as? Int,
                       let unit = volumeDict["unit"] as? String,
                       let volumeUnit = VolumeUnit(rawValue: unit),
                       let calories = currDrink["calories"] as? Int,
                       let protein = currDrink["protein"] as? Int {
                        
                        
                        let carbs = currDrink["carbs"] as? Int
                        let fat = currDrink["fat"] as? Int
                        
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

// Edit Drink
func editDrink(_ drink: Drink, completion: @escaping (Result<Drink, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "\(baseURL)/drinks/\(drink.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "PATCH"
    
    // Create the array of objects as expected by the backend
    var updateOps: [[String: Any]] = [
        ["propName": "name", "value": drink.name],
        ["propName": "volume", "value": ["value": drink.volume.value, "unit": drink.volume.unit.rawValue]],
        ["propName": "calories", "value": drink.calories],
        ["propName": "protein", "value": drink.protein]
    ]
    
    if let carbs = drink.carbs {
        updateOps.append(["propName": "carbs", "value": carbs])
    } else {
        updateOps.append(["propName": "carbs", "value": NSNull()])
    }
    
    if let fat = drink.fat {
        updateOps.append(["propName": "fat", "value": fat])
    } else {
        updateOps.append(["propName": "fat", "value": NSNull()])
    }
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: updateOps, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding drink data: \(error)")
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NSError(domain: "ResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            completion(.failure(error))
            return
        }
        
        if httpResponse.statusCode == 200 {
            completion(.success((drink)))  // Indicate success without a message
        } else {
            let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error with code \(httpResponse.statusCode)"])
            completion(.failure(error))
        }
    }
    
    task.resume()
}

// Delete Drink
func deleteDrink(_ drink: Drink, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/drinks/\(drink.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let error = NSError(domain: "HTTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])
            print("Unexpected response")
            completion(.failure(error))
            return
        }
        
        completion(.success(()))
    }
    
    task.resume()
}

// Add Drink
func addDrink(name: String, volumeValue: Int, volumeUnit: String, calories: Int, protein: Int, carbs: Int?, fats: Int?, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "\(baseURL)/drinks") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    var body: [String: Any] = [
        "name": name,
        "volume": [
            "value": volumeValue,
            "unit": volumeUnit
        ],
        "calories": calories,
        "protein": protein
    ]
    
    if let carbs = carbs {
        body["carbs"] = carbs
    } else {
        body["carbs"] = NSNull()
    }
    
    if let fats = fats {
        body["fat"] = fats
    } else {
        body["fat"] = NSNull()
    }
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        do {
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("SUCCESS: \(response)")
        } catch {
            print(error)
        }
    }
    
    task.resume()
}

