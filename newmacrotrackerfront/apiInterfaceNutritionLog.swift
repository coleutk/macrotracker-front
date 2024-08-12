//
//  apiInterfaceNutritionLog.swift
//  newmacrotrackerfront
//
//  Created by Cole Price on 6/28/24.
//

import Foundation

struct HistoricalRecord: Identifiable, Codable {
    var id: String
    var records: [DailyRecord]
}

struct HistoricalGoal: Codable {
    var calorieGoal: Int
    var proteinGoal: Int
    var carbGoal: Int
    var fatGoal: Int
}

extension HistoricalGoal {
    func toSelectedGoal(withId id: String, name: String) -> SelectedGoal {
        return SelectedGoal(
            id: id,
            name: name,
            calorieGoal: self.calorieGoal,
            proteinGoal: self.proteinGoal,
            carbGoal: self.carbGoal,
            fatGoal: self.fatGoal
        )
    }
}

struct DailyRecord: Codable {
    var id: String
    var userId: String
    var date: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var manuals: [DailyManual]
    var foods: [DailyFood]
    var drinks: [DailyDrink]
    var goal: HistoricalGoal? // Add this line
}

struct DailyFood: Identifiable, Codable {
    var id: String
    var name: String
    var servings: Float
    var weight: DailyWeight
    var calories: Int
    var protein: Int
    var carbs: Int?
    var fat: Int?
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
    var carbs: Int?
    var fat: Int?
}

struct DailyVolume: Codable {
    var value: Int
    var unit: String
}

struct DailyManual: Identifiable, Codable {
    var id: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}




func getAllHistoricalRecords(_ completion: @escaping (Result<[DailyRecord], Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add authorization header
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(.success([])) // Treat as no data
            return
        }
        
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let recordsArray = jsonResponse["records"] as? [[String: Any]] {
                print("Received JSON: \(jsonResponse)") // Debug print
                
                var historicalRecords: [DailyRecord] = []
                
                for record in recordsArray {
                    if let id = record["_id"] as? String,
                       let userId = record["user"] as? String,
                       let date = record["date"] as? String,
                       let calories = record["calories"] as? Int,
                       let protein = record["protein"] as? Int,
                       let carbs = record["carbs"] as? Int,
                       let fat = record["fat"] as? Int,
                       let foodArray = record["foods"] as? [[String: Any]],
                       let drinkArray = record["drinks"] as? [[String: Any]],
                       let manualArray = record["manuals"] as? [[String: Any]],
                       let goalDict = record["goal"] as? [String: Any] {
                        
                        var foods: [DailyFood] = []
                        var drinks: [DailyDrink] = []
                        var manuals: [DailyManual] = []
                        
                        // Parse foods
                        for foodWrapper in foodArray {
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
                        
                        // Parse manuals
                        for manualWrapper in manualArray {
                            if let id = manualWrapper["_id"] as? String,
                               let calories = manualWrapper["calories"] as? Int,
                               let protein = manualWrapper["protein"] as? Int,
                               let carbs = manualWrapper["carbs"] as? Int,
                               let fat = manualWrapper["fat"] as? Int {
                                
                                let dailyManual = DailyManual(id: id, calories: calories, protein: protein, carbs: carbs, fat: fat)
                                manuals.append(dailyManual)
                            }
                        }
                        
                        // Parse goal
                        let goal = HistoricalGoal(
                            calorieGoal: goalDict["calorieGoal"] as? Int ?? 0,
                            proteinGoal: goalDict["proteinGoal"] as? Int ?? 0,
                            carbGoal: goalDict["carbGoal"] as? Int ?? 0,
                            fatGoal: goalDict["fatGoal"] as? Int ?? 0
                        )
                        
                        let dailyRecord = DailyRecord(id: id, userId: userId, date: date, calories: calories, protein: protein, carbs: carbs, fat: fat, manuals: manuals, foods: foods, drinks: drinks, goal: goal)
                        historicalRecords.append(dailyRecord)
                    }
                }
                
                completion(.success(historicalRecords))
            } else {
                completion(.success([]))
            }
        } catch {
            print("Failed to parse JSON: \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

// Get Current Daily Record (USER)
func getCurrentDaily(_ completion: @escaping (Result<DailyRecord?, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/dailyRecords/currentDailyRecord")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add authorization header
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
                
                if let message = json["message"] as? String, message == "No daily record found for today" {
                    completion(.success(nil)) // No record found
                    return
                }
                
                // Parse DailyRecord
                if let id = json["_id"] as? String,
                   let userId = json["user"] as? String,
                   let date = json["date"] as? String,
                   let calories = json["calories"] as? Int,
                   let protein = json["protein"] as? Int,
                   let carbs = json["carbs"] as? Int,
                   let fat = json["fat"] as? Int,
                   let foodArray = json["foods"] as? [[String: Any]],
                   let drinkArray = json["drinks"] as? [[String: Any]],
                   let manualArray = json["manuals"] as? [[String: Any]] {
                    
                    var foods: [DailyFood] = []
                    var drinks: [DailyDrink] = []
                    var manuals: [DailyManual] = []
                    
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
                    
                    for manualWrapper in manualArray {
                        print("Parsing manual: \(manualWrapper)");
                        if let id = manualWrapper["_id"] as? String,
                           let calories = manualWrapper["calories"] as? Int,
                           let protein = manualWrapper["protein"] as? Int,
                           let carbs = manualWrapper["carbs"] as? Int,
                           let fat = manualWrapper["fat"] as? Int {
                            
                            let dailyManual = DailyManual(id: id, calories: calories, protein: protein, carbs: carbs, fat: fat)
                            manuals.append(dailyManual)
                        }
                    }
                    
                    let dailyRecord = DailyRecord(id: id, userId: userId, date: date, calories: calories, protein: protein, carbs: carbs, fat: fat, manuals: manuals, foods: foods, drinks: drinks)
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



// Add Food to DailyRecord (USER)
func addFoodToDaily(name: String, servings: Float, weightValue: Int, weightUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "http://localhost:3000/dailyRecords/addFood") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
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


// Add Drink to DailyRecord (USER)
func addDrinkToDaily(_id: String, name: String, servings: Float, volumeValue: Int, volumeUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "http://localhost:3000/dailyRecords/addDrink") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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


// Add Manual to DailyRecord (USER)
func addManualToDaily(_id: String, calories: Int, protein: Int, carbs: Int, fat: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "http://localhost:3000/dailyRecords/addManual") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
        "_id": _id,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat
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


// Delete Food from Daily Record (USER)
func deleteFoodInput(_ food: DailyFood, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }

    var request = URLRequest(url: URL(string: "http://localhost:3000/dailyRecords/deleteFoodInput/\(food.id)")!)
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

// Delete Drink from Daily Record
func deleteDrinkInput(_ drink: DailyDrink, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/dailyRecords/deleteDrinkInput/\(drink.id)")!)
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

// Delete Manual from Daily Record (USER)
func deleteManualInput(_ manual: DailyManual, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/dailyRecords/deleteManualInput/\(manual.id)")!)
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


// Complete Day API Call
func completeDay(completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }

    guard let url = URL(string: "http://localhost:3000/dailyRecords/completeDay") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])))
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["message"] as? String, message == "Day completed and daily record archived successfully" {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from server"])))
            }
        } catch {
            print("Error decoding response: \(error)")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
        }
    }

    task.resume()
}


func deleteArchivedRecord(date: String, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }

    guard let url = URL(string: "http://localhost:3000/archivedRecords/deleteArchivedRecord") else {
        completion(false, "Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let body: [String: Any] = ["date": date]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(false, error?.localizedDescription)
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
               let message = json["message"] as? String {
                if message == "Archived record deleted successfully" {
                    completion(true, nil)
                } else {
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid response from server")
            }
        } catch {
            completion(false, error.localizedDescription)
        }
    }

    task.resume()
}

// Delete Food from ArchivedRecord
func deleteFoodFromArchived(recordId: String, foodInputId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }

    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/deleteFood/\(recordId)/\(foodInputId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"

    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to delete food entry"])))
            return
        }

        completion(.success(()))
    }

    task.resume()
}


func deleteDrinkFromArchived(recordId: String, drinkInputId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/deleteDrink/\(recordId)/\(drinkInputId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"
    
    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to delete food entry"])))
            return
        }

        completion(.success(()))
    }

    task.resume()
}


func deleteManualFromArchived(recordId: String, manualInputId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/deleteManual/\(recordId)/\(manualInputId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"
    
    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to delete food entry"])))
            return
        }

        completion(.success(()))
    }

    task.resume()
}

// Add Food to Archived Record
func addFoodToArchivedRecord(recordId: String, name: String, servings: Float, weightValue: Int, weightUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/addFood/\(recordId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let body: [String: Any] = [
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
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(false, "Invalid response")
            return
        }
        
        if httpResponse.statusCode == 200 {
            completion(true, nil)
        } else {
            completion(false, "Error: Received HTTP status code \(httpResponse.statusCode)")
        }
    }
    
    task.resume()
}


// Add Drink to Archived Record
func addDrinkToArchivedRecord(recordId: String, name: String, servings: Float, volumeValue: Int, volumeUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/addDrink/\(recordId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let body: [String: Any] = [
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
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(false, "Invalid response")
            return
        }
        
        if httpResponse.statusCode == 200 {
            completion(true, nil)
        } else {
            completion(false, "Error: Received HTTP status code \(httpResponse.statusCode)")
        }
    }
    
    task.resume()
}

// Add Manual Entry to Archived Record
func addManualToArchivedRecord(recordId: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/archivedRecords/addManual/\(recordId)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let body: [String: Any] = [
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fats
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(false, "Invalid response")
            return
        }
        
        if httpResponse.statusCode == 200 {
            completion(true, nil)
        } else {
            completion(false, "Error: Received HTTP status code \(httpResponse.statusCode)")
        }
    }
    
    task.resume()
}


// Get Specific Historical Record by ID
func fetchHistoricalRecord(id: String, completion: @escaping (Result<DailyRecord, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    let urlString = "http://localhost:3000/archivedRecords/\(id)"
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add authorization header
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed: \(error)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(.failure(NSError(domain: "No data", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            if let record = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Received JSON: \(record)") // Debug print
                
                if let id = record["_id"] as? String,
                   let userId = record["user"] as? String,
                   let date = record["date"] as? String,
                   let calories = record["calories"] as? Int,
                   let protein = record["protein"] as? Int,
                   let carbs = record["carbs"] as? Int,
                   let fat = record["fat"] as? Int,
                   let foodArray = record["foods"] as? [[String: Any]],
                   let drinkArray = record["drinks"] as? [[String: Any]],
                   let manualArray = record["manuals"] as? [[String: Any]],
                   let goalDict = record["goal"] as? [String: Any] {
                    
                    var foods: [DailyFood] = []
                    var drinks: [DailyDrink] = []
                    var manuals: [DailyManual] = []
                    
                    // Parse foods
                    for foodWrapper in foodArray {
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
                    
                    // Parse manuals
                    for manualWrapper in manualArray {
                        if let id = manualWrapper["_id"] as? String,
                           let calories = manualWrapper["calories"] as? Int,
                           let protein = manualWrapper["protein"] as? Int,
                           let carbs = manualWrapper["carbs"] as? Int,
                           let fat = manualWrapper["fat"] as? Int {
                            
                            let dailyManual = DailyManual(id: id, calories: calories, protein: protein, carbs: carbs, fat: fat)
                            manuals.append(dailyManual)
                        }
                    }
                    
                    // Parse goal
                    let goal = HistoricalGoal(
                        calorieGoal: goalDict["calorieGoal"] as? Int ?? 0,
                        proteinGoal: goalDict["proteinGoal"] as? Int ?? 0,
                        carbGoal: goalDict["carbGoal"] as? Int ?? 0,
                        fatGoal: goalDict["fatGoal"] as? Int ?? 0
                    )
                    
                    let dailyRecord = DailyRecord(id: id, userId: userId, date: date, calories: calories, protein: protein, carbs: carbs, fat: fat, manuals: manuals, foods: foods, drinks: drinks, goal: goal)
                    
                    completion(.success(dailyRecord))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                }
            } else {
                completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON"])))
            }
        } catch {
            print("Failed to parse JSON: \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}
