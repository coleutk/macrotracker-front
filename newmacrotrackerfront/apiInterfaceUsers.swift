import Foundation

struct User: Identifiable, Codable {
    var id: String // Conforming to Identifiable
    var selectedGoal: SelectedGoal?
}

struct SelectedGoal: Codable {
    var id: String // Use 'id' instead of '_id' to be consistent
    var name: String
    var calorieGoal: Int
    var proteinGoal: Int
    var carbGoal: Int
    var fatGoal: Int
}

func getUserSelectedGoal(_ completion: @escaping (Result<SelectedGoal, Error>) -> Void) {
    // Build request
    var request = URLRequest(url: URL(string: "http://localhost:3000/users/6653b47937963eb408615abc")!) // This is hardcoded to pull from ONLY this user, fix this later
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any],
           let user = json["user"] as? [String: Any],
           let selectedGoal = user["selectedGoal"] as? [String: Any] {
            
            print("Data received and parsed")
            
            // Try to parse out the selected goal
            if let id = selectedGoal["_id"] as? String,
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
            } else if let error {
                print("HTTP Request Failed \(error)")
                completion(.failure(error))
            }
        }
    }
    
    task.resume()
}

// Sign Up User
func userSignUp(username: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
    guard let url = URL(string: "http://localhost:3000/users/signup") else {
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
