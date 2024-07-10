//
//  apiInterface.swift
//  macrotracker
//
//  Created by Cole Price on 6/16/24.
//

import Foundation

struct Food: Identifiable, Codable {
    var id: String
    var name: String
    var weight: Weight
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct Weight: Codable {
    var value: Int
    var unit: WeightUnit
}

enum WeightUnit: String, Codable, CaseIterable {
    case g
    case kg
    case oz
    case mg
    case lb
}

// Get All Foods
func getAllFoods(_ completion: @escaping (Result<[Food], Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/foods/")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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


// Edit Food
func editFood(_ food: Food, completion: @escaping (Result<Food, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/foods/\(food.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "PATCH"
    
    // Create the array of objects as expected by the backend
    let updateOps: [[String: Any]] = [
        ["propName": "name", "value": food.name],
        ["propName": "weight", "value": ["value": food.weight.value, "unit": food.weight.unit.rawValue]],
        ["propName": "calories", "value": food.calories],
        ["propName": "protein", "value": food.protein],
        ["propName": "carbs", "value": food.carbs],
        ["propName": "fat", "value": food.fat]
    ]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: updateOps, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding food data: \(error)")
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            let error = NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
            print("No data received")
            completion(.failure(error))
            return
        }
        
        do {
            let updatedFood = try JSONDecoder().decode(Food.self, from: data)
            print("Data received and parsed: \(updatedFood)")
            completion(.success(updatedFood))
        } catch {
            print("Error decoding response data: \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}


// Delete Food
func deleteFood(_ food: Food, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/foods/\(food.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
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

// Add Food
func addFood(name: String, weightValue: Int, weightUnit: String, calories: Int, protein: Int, carbs: Int, fats: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "http://localhost:3000/foods") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
        "name": name,
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



