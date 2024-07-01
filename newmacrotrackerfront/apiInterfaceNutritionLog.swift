//
//  apiInterfaceNutritionLog.swift
//  newmacrotrackerfront
//
//  Created by Cole Price on 6/28/24.
//

import Foundation


struct DailyRecord: Identifiable, Codable {
    var id: String
    var userId: String
    var date: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var foods: [DailyFood]
    var drinks: [DailyDrink]
}

struct DailyFood: Identifiable, Codable {
    var id: String
    var name: String
    var servings: Float
    var weight: DailyWeight
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct DailyWeight: Codable {
    var value: Int
    var unit: String
}

struct DailyDrink: Identifiable, Codable {
    var id: String
    var name: String
    var servings: Float
    var volume: DailyVolume
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct DailyVolume: Codable {
    var value: Int
    var unit: String
}


// Get Current Daily Record
func getCurrentDaily(_ completion: @escaping (Result<DailyRecord, Error>) -> Void) {
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/dailyRecords/currentDailyRecord")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Received JSON: \(json)") // Debug print
                
                // Parse DailyRecord
                if let id = json["_id"] as? String,
                   let userId = json["userId"] as? String,
                   let date = json["date"] as? String,
                   let calories = json["calories"] as? Int,
                   let protein = json["protein"] as? Int,
                   let carbs = json["carbs"] as? Int,
                   let fat = json["fat"] as? Int,
                   let foodArray = json["foods"] as? [[String: Any]],
                   let drinkArray = json["drinks"] as? [[String: Any]] {
                    
                    var foods: [DailyFood] = []
                    var drinks: [DailyDrink] = []
                    
                    // Parse foods
                    for foodWrapper in foodArray {
                        print("Parsing food: \(foodWrapper)") // Debug print
                        if let food = foodWrapper["food"] as? [String: Any],
                           let id = foodWrapper["_id"] as? String, // Grabbing id of the entry rather than the specific food
                           let name = food["name"] as? String,
                           let servings = foodWrapper["servings"] as? Float,
                           let weightDict = food["weight"] as? [String: Any],
                           let weightValue = weightDict["value"] as? Int,
                           let weightUnit = weightDict["unit"] as? String,
                           let calories = food["calories"] as? Int,
                           let protein = food["protein"] as? Int,
                           let carbs = food["carbs"] as? Int,
                           let fat = food["fat"] as? Int {
                            
                            let weight = DailyWeight(value: weightValue, unit: weightUnit)
                            let dailyFood = DailyFood(id: id, name: name, servings: servings, weight: weight, calories: calories, protein: protein, carbs: carbs, fat: fat)
                            foods.append(dailyFood)
                        }
                    }
                    
                    // Parse drinks
                    for drinkWrapper in drinkArray {
                        print("Parsing drink: \(drinkWrapper)") // Debug print
                        if let drink = drinkWrapper["drink"] as? [String: Any],
                           let id = drinkWrapper["_id"] as? String, // Grabbing id of the entry rather than the specific drink
                           let name = drink["name"] as? String,
                           let servings = drinkWrapper["servings"] as? Float,
                           let volumeDict = drink["volume"] as? [String: Any],
                           let volumeValue = volumeDict["value"] as? Int,
                           let volumeUnit = volumeDict["unit"] as? String,
                           let calories = drink["calories"] as? Int,
                           let protein = drink["protein"] as? Int,
                           let carbs = drink["carbs"] as? Int,
                           let fat = drink["fat"] as? Int {
                            
                            let volume = DailyVolume(value: volumeValue, unit: volumeUnit)
                            let dailyDrink = DailyDrink(id: id, name: name, servings: servings, volume: volume, calories: calories, protein: protein, carbs: carbs, fat: fat)
                            drinks.append(dailyDrink)
                        }
                    }
                    
                    let dailyRecord = DailyRecord(id: id, userId: userId, date: date, calories: calories, protein: protein, carbs: carbs, fat: fat, foods: foods, drinks: drinks)
                    completion(.success(dailyRecord))
                } else {
                    print("Failed to parse DailyRecord")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse DailyRecord"])))
                }
            }
        } catch {
            print("Failed to parse JSON: \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}






// Add Food to DailyRecord
func addFoodToDaily(_id: String, name: String, servings: Float, weightValue: Int, weightUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int) {
    guard let url = URL(string: "http://localhost:3000/dailyRecords/addFood") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: Any] = [
        "_id": _id,
        "name": name,
        "servings": servings,
        "weight": [
            "value": weightValue,
            "unit": weightUnit
        ],
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fats
    ]
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

// Add Drink to DailyRecord
func addDrinkToDaily(_id: String, name: String, servings: Float, volumeValue: Int, volumeUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int) {
    guard let url = URL(string: "http://localhost:3000/dailyRecords/addDrink") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: Any] = [
        "_id": _id,
        "name": name,
        "servings": servings,
        "volume": [
            "value": volumeValue,
            "unit": volumeUnit
        ],
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fats
    ]
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
