import SwiftUI
import Combine

class InventoryViewModel: ObservableObject {
    @Published var foods: [Food] = [] {
        didSet {
            saveInventory()
        }
    }
    @Published var drinks: [Drink] = [] {
        didSet {
            saveInventory()
        }
    }

    init() {
//        UserDefaults.standard.removeObject(forKey: "foods")
//        UserDefaults.standard.removeObject(forKey: "drinks")
        
        loadInventory()
    }

    func saveInventory() {
        let defaults = UserDefaults.standard
        do {
            let encodedFoods = try JSONEncoder().encode(foods)
            defaults.set(encodedFoods, forKey: "foods")
            print("Saved Foods: \(foods)")
        } catch {
            print("Error saving foods: \(error)")
        }
        
        do {
            let encodedDrinks = try JSONEncoder().encode(drinks)
            defaults.set(encodedDrinks, forKey: "drinks")
            print("Saved Drinks: \(drinks)")
        } catch {
            print("Error saving drinks: \(error)")
        }
    }

    func loadInventory() {
        let defaults = UserDefaults.standard
        if let foodsData = defaults.data(forKey: "foods") {
            do {
                foods = try JSONDecoder().decode([Food].self, from: foodsData)
                print("Loaded Foods: \(foods)")
            } catch {
                print("Error loading foods: \(error)")
            }
        }
        if let drinksData = defaults.data(forKey: "drinks") {
            do {
                drinks = try JSONDecoder().decode([Drink].self, from: drinksData)
                print("Loaded Drinks: \(drinks)")
            } catch {
                print("Error loading drinks: \(error)")
            }
        }
    }
}



struct Food: Identifiable, Codable {
    var id = UUID()
    var name: String
    var weight: String
    var calories: String
    var protein: String
    var carbs: String
    var fats: String
}

struct Drink: Identifiable, Codable {
    var id = UUID()
    var name: String
    var volume: String
    var calories: String
    var protein: String
    var carbs: String
    var fats: String
}
