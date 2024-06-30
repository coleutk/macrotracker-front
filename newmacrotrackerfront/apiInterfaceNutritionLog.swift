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
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var foods: [Food]
    var drinks: [Drink]
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
