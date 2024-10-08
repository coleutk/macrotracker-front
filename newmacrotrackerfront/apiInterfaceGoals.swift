//
//  apiInterfaceGoals.swift
//  newmacrotrackerfront
//
//  Created by Cole Price on 6/27/24.
//

import Foundation

struct Goal: Identifiable, Codable {
    var id: String
    var name: String
    var calorieGoal: Int
    var proteinGoal: Int
    var carbGoal: Int
    var fatGoal: Int
}

// Get All Goals (USER)
func getAllGoals(_ completion: @escaping (Result<[Goal], Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "\(baseURL)/goals/")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "GET"
    
    // Container for fetched foods
    var goals: [Goal] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any],
           let goalArray = json["goals"] as? [Any] {
            
            print("Data received and parsed")
            
            // Try to parse out the food items
            for object in goalArray {
                if let currGoal = object as? [AnyHashable: Any] {
                    if let id = currGoal["_id"] as? String,
                       let name = currGoal["name"] as? String,
                       let calorieGoal = currGoal["calorieGoal"] as? Int,
                       let proteinGoal = currGoal["proteinGoal"] as? Int,
                       let carbGoal = currGoal["carbGoal"] as? Int,
                       let fatGoal = currGoal["fatGoal"] as? Int
                    {
                    
                        goals.append(Goal(
                            id: id,
                            name: name,
                            calorieGoal: calorieGoal,
                            proteinGoal: proteinGoal,
                            carbGoal: carbGoal,
                            fatGoal: fatGoal
                            
                        ))
                        
                    } else {
                        print("Failed to parse food item: \(currGoal)")
                    }
                }
            }
            print("Foods parsed: \(goals)")
            completion(.success(goals))
        } else if let error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

// Edit Goal (USER)
func editGoal(_ goal: Goal, completion: @escaping (Result<Goal, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    // Build request
    var request = URLRequest(url: URL(string: "\(baseURL)/goals/\(goal.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "PATCH"
    
    // Create the array of objects as expected by the backend
    let updateOps: [[String: Any]] = [
        ["propName": "name", "value": goal.name],
        ["propName": "calorieGoal", "value": goal.calorieGoal],
        ["propName": "proteinGoal", "value": goal.proteinGoal],
        ["propName": "carbGoal", "value": goal.carbGoal],
        ["propName": "fatGoal", "value": goal.fatGoal]
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
            let updatedGoal = try JSONDecoder().decode(Goal.self, from: data)
            print("Data received and parsed: \(updatedGoal)")
            completion(.success(updatedGoal))
        } catch {
            print("Error decoding response data: \(error)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

// Delete Goal (USER)
func deleteGoal(_ goal: Goal, selectedGoalId: String?, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/goals/\(goal.id)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "DELETE"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("HTTP Request Failed \(error)")
            completion(.failure(error))
            return
        }
        
        if goal.id == selectedGoalId {
            // Clear the selected goal if the deleted goal is the selected one
            clearSelectedGoal { success, message in
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to clear selected goal"])))
                }
            }
        } else {
            completion(.success(()))
        }
    }
    
    task.resume()
}

// Add Goal (USER)
func addGoal(name: String, calorieGoal: Int, proteinGoal: Int, carbGoal: Int, fatGoal: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "\(baseURL)/goals") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
        "name": name,
        "calorieGoal": calorieGoal,
        "proteinGoal": proteinGoal,
        "carbGoal": carbGoal,
        "fatGoal": fatGoal
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

// Make Different Goal = Selected Goal (USER)
func makeNewSelectedGoal(goalId: String, name: String, calorieGoal: Int, proteinGoal: Int, carbGoal: Int, fatGoal: Int, completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "\(baseURL)/goal/makeSelectedGoal") else { // Hardcoded to update it for the specific user, fix this to do it for the user that is logged in (stored in backend under userId = )
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
        "goalId": goalId,
        "name": name,
        "calorieGoal": calorieGoal,
        "proteinGoal": proteinGoal,
        "carbGoal": carbGoal,
        "fatGoal": fatGoal
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

// Function to clear the selected goal for the user
func clearSelectedGoal(completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    guard let url = URL(string: "\(baseURL)/goals/clearSelectedGoal") else {
        completion(false, "Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            completion(false, error?.localizedDescription)
            return
        }
        
        do {
            if let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
               let success = response["success"] as? Bool {
                completion(success, nil)
            } else {
                completion(false, "Unexpected response from server")
            }
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    task.resume()
}


