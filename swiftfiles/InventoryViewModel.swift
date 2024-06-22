import SwiftUI
import Combine

class InventoryViewModel: ObservableObject {
//    @Published var foods: [Food] = [] {
//        didSet {
//            saveInventory()
//        }
//    }
//    @Published var drinks: [Drink] = [] {
//        didSet {
//            saveInventory()
//        }
//    }
//
//    init() {
//        loadInventory()
//    }

//    func saveInventory() {
//        let defaults = UserDefaults.standard
//        do {
//            let encodedFoods = try JSONEncoder().encode(foods)
//            defaults.set(encodedFoods, forKey: "foods")
//            print("Saved Foods: \(foods)")
//        } catch {
//            print("Error saving foods: \(error)")
//        }
//        
//        do {
//            let encodedDrinks = try JSONEncoder().encode(drinks)
//            defaults.set(encodedDrinks, forKey: "drinks")
//            print("Saved Drinks: \(drinks)")
//        } catch {
//            print("Error saving drinks: \(error)")
//        }
//    }
//
//    func loadInventory() {
//        let defaults = UserDefaults.standard
//        if let foodsData = defaults.data(forKey: "foods") {
//            do {
//                foods = try JSONDecoder().decode([Food].self, from: foodsData)
//                print("Loaded Foods: \(foods)")
//            } catch {
//                print("Error loading foods: \(error)")
//            }
//        }
//        if let drinksData = defaults.data(forKey: "drinks") {
//            do {
//                drinks = try JSONDecoder().decode([Drink].self, from: drinksData)
//                print("Loaded Drinks: \(drinks)")
//            } catch {
//                print("Error loading drinks: \(error)")
//            }
//        }
//    }
}


//// Food Info
//struct Food: Identifiable, Codable {
//    var id: UUID
//    var name: String
//    var weight: Weight
//    var calories: Int
//    var protein: Double
//    var carbs: Int
//    var fats: Double
//}
//
//struct Weight: Codable {
//    var value: Int
//    var unit: Unit
//}
//
//// Drink Info
//struct Drink: Identifiable, Codable {
//    var id: UUID
//    var name: String
//    var volume: Volume
//    var calories: Int
//    var protein: Double
//    var carbs: Int
//    var fats: Double
//}
//
//struct Volume: Codable {
//    var value: Int
//    var unit: Unit
//}
//
//enum Unit: String, Codable {
//    case g = "g"
//    case kg = "kg"
//    case mg = "mg"
//    case oz = "oz"
//    case floz = "fl oz"
//    case lb = "lb"
//    case mL = "mL"  // Assuming this was missing for Volume units
//    case L = "L"    // Adding other possible units for volume
//    case c = "c"
//}


