//
//  apiInterface.swift
//  macrotracker
//
//  Created by Cole Price on 6/16/24.
//

import Foundation

struct Food: Decodable {
    let id: String
    let name: String
    let weight: Weight
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

struct Weight: Decodable {
    let value: Int
    let unit: WeightUnit
}

enum WeightUnit: String, Decodable {
    case g
    case kg
    case oz
    case mg
}

func getAllFoods(_ completion: @escaping (Result<[Food], Error>) -> Void) {
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/foods/")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    
    // Container for fetched foods
    var foods: [Food] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any],
           let foodArray = json["foods"] as? [Any] {
            
            print("Data received and parsed")
            
            // Try to parse out the food items
            for object in foodArray {
                if let currFood = object as? [AnyHashable: Any] {
                    if let id = currFood["_id"] as? String,
                       let name = currFood["name"] as? String,
                       // For pulling weight object values
                       let weightDict = currFood["weight"] as? [String: Any],
                       let value = weightDict["value"] as? Int,
                       let unit = weightDict["unit"] as? String,
                       let weightUnit = WeightUnit(rawValue: unit),
                       let calories = currFood["calories"] as? Int,
                        let protein = currFood["protein"] as? Int,
                    let carbs = currFood["carbs"] as? Int,
                       let fat = currFood["fat"] as? Int
                    {
                        
                        let weight = Weight(value: value, unit: weightUnit)
                        foods.append(Food(
                            id: id,
                            name: name,
                            weight: weight,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat
                            
                        ))
                        
                    } else {
                        print("Failed to parse food item: \(currFood)")
                    }
                }
            }
            print("Foods parsed: \(foods)")
            completion(.success(foods))
        } else if let error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}


//weight: Weight(
//    value: (currFood["weight"] as! [String: Any])["value"] as! Int,
//    unit: WeightUnit(rawValue: (currFood["weight"] as! [String: Any])["unit"] as! String)!
//),
//calories: foodDict["calories"] as! Int,
//protein: foodDict["protein"] as! Int,
//carbs: foodDict["carbs"] as! Int,
//fats: foodDict["fats"] as! Int


