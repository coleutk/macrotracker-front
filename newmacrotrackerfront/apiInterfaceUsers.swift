import Foundation

struct User: Identifiable, Codable {
    var id: String // Conforming to Identifiable
    var selectedGoal: SelectedGoal?
}

struct UserDetails: Codable {
    var username: String
    var email: String
}

struct SelectedGoal: Identifiable, Codable {
    var id: String // Use 'id' instead of '_id' to be consistent
    var name: String
    var calorieGoal: Int
    var proteinGoal: Int
    var carbGoal: Int
    var fatGoal: Int
}

let baseURL = "https://macrotracker-back-860a4fde2f08.herokuapp.com"

// Grab Selected Goal from User Details (USER)
func getUserSelectedGoal(_ completion: @escaping (Result<SelectedGoal?, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    guard let url = URL(string: "\(baseURL)/users/me") else {
        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(error ?? NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Network error"])))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
               let user = json["user"] as? [String: Any] {
                
                if let selectedGoal = user["selectedGoal"] as? [String: Any],
                   let id = selectedGoal["_id"] as? String,
                   let name = selectedGoal["name"] as? String,
                   let calorieGoal = selectedGoal["calorieGoal"] as? Int,
                   let proteinGoal = selectedGoal["proteinGoal"] as? Int,
                   let carbGoal = selectedGoal["carbGoal"] as? Int,
                   let fatGoal = selectedGoal["fatGoal"] as? Int {
                    
                    let goal = SelectedGoal(
                        id: id,
                        name: name,
                        calorieGoal: calorieGoal,
                        proteinGoal: proteinGoal,
                        carbGoal: carbGoal,
                        fatGoal: fatGoal
                    )
                    
                    print("Selected Goal parsed: \(goal)")
                    completion(.success(goal))
                } else if user["selectedGoal"] is NSNull {
                    completion(.success(nil))
                } else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}


// Sign Up User
func userSignUp(username: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
    guard let url = URL(string: "\(baseURL)/users/signup") else {
        completion(false, "Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: Any] = [
        "username": username,
        "email": email,
        "password": password
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(false, "Network error")
            return
        }
        
        do {
            // Parse JSON response
            if let responseDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                
                // Check for "message" key in the response
                if let message = responseDict["message"] as? String {
                    // Handle specific messages
                    if message == "User created" {
                        completion(true, message)
                    } else {
                        completion(false, message) // Display backend message on error
                    }
                } else if let errors = responseDict["errors"] as? [[String: Any]] {
                    // Handle validation errors (if any)
                    let errorMessage = errors.compactMap { $0["msg"] as? String }.joined(separator: "\n")
                    completion(false, errorMessage)
                } else {
                    completion(false, "Unknown error")
                }
            } else {
                completion(false, "Invalid response from server")
            }
        } catch {
            completion(false, "Failed to parse response")
        }
    }
    
    task.resume()
}



// Log in User
func userLogin(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
    guard let url = URL(string: "\(baseURL)/users/login") else {
        completion(false, "Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: Any] = [
        "email": email,
        "password": password
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            completion(false, "Network error")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                if let message = json["message"] as? String, message == "Auth successful",
                   let token = json["token"] as? String {
                    UserDefaults.standard.set(token, forKey: "token")
                    completion(true, nil)
                } else if let message = json["message"] as? String {
                    completion(false, message)
                } else {
                    completion(false, "Unknown error")
                }
            } else {
                completion(false, "Invalid response from server")
            }
        } catch {
            completion(false, "Failed to parse response")
        }
    }
    
    task.resume()
}


// Pull Username/E-Mail (USER)
func getUserDetails(_ completion: @escaping (Result<UserDetails, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    guard let url = URL(string: "\(baseURL)/users/me") else {
        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(error ?? NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Network error"])))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
               let user = json["user"] as? [String: Any],
               let username = user["username"] as? String,
               let email = user["email"] as? String{
                
                let userDetails = UserDetails(
                    username: username,
                    email: email
                )
                
                //print("Selected Goal parsed: \(userDetails)")
                completion(.success(userDetails))
            } else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}


// Update Username/E-Mail (USER)
func updateUserDetails (username: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/users/updateUser")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the token
    request.httpMethod = "PATCH"
    
    let body: [String: Any] = [
        "username": username,
        "email": email
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let data = data, let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }
            return
        }
        
        if httpResponse.statusCode == 200 {
            DispatchQueue.main.async {
                completion(.success(()))
            }
        } else {
            let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: responseString])))
            }
        }
    }
    
    task.resume()
}


// Update Password in Edit Profile (USER)
func updateUserPassword(currentPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/users/updatePassword")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "PATCH"
    
    let body: [String: Any] = [
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let data = data, let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }
            return
        }
        
        if httpResponse.statusCode == 200 {
            DispatchQueue.main.async {
                completion(.success(()))
            }
        } else {
            let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: responseString])))
            }
        }
    }
    
    task.resume()
}

// Function to delete a user by ID
func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "token") else {
        completion(false, "User not authenticated")
        return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/users/deleteUser")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, error.localizedDescription)
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            completion(true, "User deleted successfully")
        } else {
            completion(false, "Failed to delete user")
        }
    }
    
    task.resume()
}


