import SwiftUI

enum Item: String, CaseIterable, Identifiable {
    case Food, Drink
    var id: Self { self }
}

struct InventoryView: View {
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    @State private var selectedItem: Item = .Food
    
    // For Food Add Sheet
    @State private var isAddFoodSheetPresented = false
    @State private var newFoodName = ""
    @State private var newFoodWeight = ""
    @State private var newFoodCalories = ""
    @State private var newFoodProtein = ""
    @State private var newFoodCarbs = ""
    @State private var newFoodFats = ""
    
    // For Drink Add Sheet
    @State private var isAddDrinkSheetPresented = false
    @State private var newDrinkName = ""
    @State private var newDrinkVolume = ""
    @State private var newDrinkCalories = ""
    @State private var newDrinkProtein = ""
    @State private var newDrinkCarbs = ""
    @State private var newDrinkFats = ""
    
    // For Editing Food
    @State private var foodName = ""
    @State private var foodWeight = ""
    @State private var foodCalories = ""
    @State private var foodProtein = ""
    @State private var foodCarbs = ""
    @State private var foodFats = ""
    
    // For Editing Drink
    @State private var drinkName = ""
    @State private var drinkVolume = ""
    @State private var drinkCalories = ""
    @State private var drinkProtein = ""
    @State private var drinkCarbs = ""
    @State private var drinkFats = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 20/255, green: 20/255, blue: 30/255)
                    .ignoresSafeArea()
                
                VStack {
                    Picker("Item", selection: $selectedItem) {
                        Text("Food").tag(Item.Food)
                        Text("Drink").tag(Item.Drink)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                    .cornerRadius(10)
                    .padding()
                    
                    List {
                        if selectedItem == .Food {
                            ForEach(inventoryViewModel.foods.indices, id: \.self) { index in
                                let food = inventoryViewModel.foods[index]
                                NavigationLink(destination:
                                                EditFoodView(foodName: $foodName, foodWeight: $foodWeight, foodCalories: $foodCalories, foodProtein: $foodProtein, foodCarbs: $foodCarbs, foodFats: $foodFats, foods: $inventoryViewModel.foods, foodIndex: index)
                                    .environmentObject(inventoryViewModel)
                                    .onAppear {
                                        // Set the values of the selected food item
                                        foodName = food.name
                                        foodWeight = food.weight
                                        foodCalories = food.calories
                                        foodProtein = food.protein
                                        foodCarbs = food.carbs
                                        foodFats = food.fats
                                    }
                                ) {
                                    Text(food.name)
                                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        } else {
                            ForEach(inventoryViewModel.drinks.indices, id: \.self) { index in
                                let drink = inventoryViewModel.drinks[index]
                                NavigationLink(destination:
                                                EditDrinkView(drinkName: $drinkName, drinkVolume: $drinkVolume, drinkCalories: $drinkCalories, drinkProtein: $drinkProtein, drinkCarbs: $drinkCarbs, drinkFats: $drinkFats, drinks: $inventoryViewModel.drinks, drinkIndex: index)
                                    .environmentObject(inventoryViewModel)
                                    .onAppear {
                                        drinkName = drink.name
                                        drinkVolume = drink.volume
                                        drinkCalories = drink.calories
                                        drinkProtein = drink.protein
                                        drinkCarbs = drink.carbs
                                        drinkFats = drink.fats
                                    }
                                ) {
                                    Text(drink.name)
                                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                    .foregroundColor(.white)
                    
                }
                .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                .navigationTitle("Inventory")
                .onAppear {
                    inventoryViewModel.loadInventory()
                }
                
                VStack {
                    Spacer() // Pushes content to the top
                    
                    HStack {
                        if selectedItem == .Food {
                            Button(action: {
                                resetAddFoodFields()
                                isAddFoodSheetPresented.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10) // Rounded rectangle background
                                        .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255)) // Background color
                                        .frame(width: 100, height: 55)
                                    
                                    VStack {
                                        Image(systemName: "carrot")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                        Text("Add Food")
                                            .padding(.top, -5)
                                            .font(.system(size: 15))
                                            .bold()
                                    }
                                    .foregroundColor(.white.opacity(0.50))
                                }
                            }
                            .buttonStyle(MyButtonStyle())
                        }
                        
                        if selectedItem == .Drink {
                            Button(action: {
                                resetAddDrinkFields()
                                isAddDrinkSheetPresented.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10) // Rounded rectangle background
                                        .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255)) // Background color
                                        .frame(width: 100, height: 55)
                                    
                                    VStack {
                                        Image(systemName: "mug")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                        Text("Add Drink")
                                            .padding(.top, -5)
                                            .font(.system(size: 15))
                                            .bold()
                                    }
                                    .foregroundColor(.white.opacity(0.50))
                                }
                            }
                            .buttonStyle(MyButtonStyle())
                        }
                    }
                }
                .sheet(isPresented: $isAddFoodSheetPresented) {
                    AddFoodSheet(foodName: $newFoodName, foodWeight: $newFoodWeight, foodCalories: $newFoodCalories, foodProtein: $newFoodProtein, foodCarbs: $newFoodCarbs, foodFats: $newFoodFats, isSheetPresented: $isAddFoodSheetPresented, foods: $inventoryViewModel.foods)
                        .environmentObject(inventoryViewModel)
                }
                
                .sheet(isPresented: $isAddDrinkSheetPresented) {
                    AddDrinkSheet(drinkName: $newDrinkName, drinkVolume: $newDrinkVolume, drinkCalories: $newDrinkCalories, drinkProtein: $newDrinkProtein, drinkCarbs: $newDrinkCarbs, drinkFats: $newDrinkFats, isSheetPresented: $isAddDrinkSheetPresented, drinks: $inventoryViewModel.drinks)
                        .environmentObject(inventoryViewModel)
                }
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // For Button
    struct MyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(5)
                .foregroundColor(.white.opacity(0.70))
        }
    }
    
    // Reset add food fields
    private func resetAddFoodFields() {
        newFoodName = ""
        newFoodWeight = ""
        newFoodCalories = ""
        newFoodProtein = ""
        newFoodCarbs = ""
        newFoodFats = ""
    }
    
    // Reset add drink fields
    private func resetAddDrinkFields() {
        newDrinkName = ""
        newDrinkVolume = ""
        newDrinkCalories = ""
        newDrinkProtein = ""
        newDrinkCarbs = ""
        newDrinkFats = ""
    }
}




struct EditFoodView: View {
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert = false
    
    @Binding var foodName: String
    @Binding var foodWeight: String
    @Binding var foodCalories: String
    @Binding var foodProtein: String
    @Binding var foodCarbs: String
    @Binding var foodFats: String
    @Binding var foods: [Food] // Add this line
    let foodIndex: Int // Add this line
    
    // Initialize the text fields with default values
    init(foodName: Binding<String>, foodWeight: Binding<String>, foodCalories: Binding<String>, foodProtein: Binding<String>, foodCarbs: Binding<String>, foodFats: Binding<String>, foods: Binding<[Food]>, foodIndex: Int) {
        _foodName = foodName
        _foodWeight = foodWeight
        _foodCalories = foodCalories
        _foodProtein = foodProtein
        _foodCarbs = foodCarbs
        _foodFats = foodFats
        _foods = foods
        self.foodIndex = foodIndex
    }
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            VStack {
                Text("Edit Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Food Name", text: $foodName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Weight", text: $foodWeight)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $foodCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Protein", text: $foodProtein)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Carbs", text: $foodCarbs)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Fats", text: $foodFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                // Save Changes Button
                Button(action: {
                    // Save changes
                    // For example:
                    saveChanges()
                    
                    // Dismiss the view and go back to inventory
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                
                // Delete Item Button
                Button(action: {
                    // Save changes
                    // For example:
                    deleteItem()
                    
                    // Dismiss the view and go back to inventory
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete \(foodName)")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.bottom, 50)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Changes Saved"), message: Text("Your changes have been saved."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveChanges() {
        // Update the food item in the foods array with the edited values
        let editedFood = Food(name: foodName, weight: foodWeight, calories: foodCalories, protein: foodProtein, carbs: foodCarbs, fats: foodFats)
        inventoryViewModel.foods[foodIndex] = editedFood
        
        inventoryViewModel.saveInventory()
        
        // Print a message to indicate that changes are saved
        print("Changes saved!")
        
        // Display an alert
        showAlert = true
    }
    
    func deleteItem() {
        // Remove the current food item from the list using the index
        inventoryViewModel.foods.remove(at: foodIndex)
        
        inventoryViewModel.saveInventory()
        
        // Implement logic to delete the item
        // For example:
        print("Food item deleted!") // for Xcode console
        
        // Display an alert or perform any other actions as needed
        showAlert = true
    }
}


struct EditDrinkView: View {
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert = false
    
    @Binding var drinkName: String
    @Binding var drinkVolume: String
    @Binding var drinkCalories: String
    @Binding var drinkProtein: String
    @Binding var drinkCarbs: String
    @Binding var drinkFats: String
    @Binding var drinks: [Drink]
    let drinkIndex: Int
    
    // Initialize the text fields with default values
    init(drinkName: Binding<String>, drinkVolume: Binding<String>, drinkCalories: Binding<String>, drinkProtein: Binding<String>, drinkCarbs: Binding<String>, drinkFats: Binding<String>, drinks: Binding<[Drink]>, drinkIndex: Int) {
        _drinkName = drinkName
        _drinkVolume = drinkVolume
        _drinkCalories = drinkCalories
        _drinkProtein = drinkProtein
        _drinkCarbs = drinkCarbs
        _drinkFats = drinkFats
        _drinks = drinks
        self.drinkIndex = drinkIndex
    }
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            VStack {
                Text("Edit Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Drink Name", text: $drinkName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Volume", text: $drinkVolume)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $drinkCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Protein", text: $drinkProtein)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Carbs", text: $drinkCarbs)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Fats", text: $drinkFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                Button(action: {
                    // Save changes
                    // For example:
                    saveChanges()
                    
                    // Dismiss the view and go back to inventory
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                
                // Delete Item Button
                Button(action: {
                    // Save changes
                    // For example:
                    deleteItem()
                    
                    // Dismiss the view and go back to inventory
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete \(drinkName)")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.bottom, 50)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Changes Saved"), message: Text("Your changes have been saved."), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveChanges() {
        // Update the food item in the foods array with the edited values
        let editedDrink = Drink(name: drinkName, volume: drinkVolume, calories: drinkCalories, protein: drinkProtein, carbs: drinkCarbs, fats: drinkFats)
        inventoryViewModel.drinks[drinkIndex] = editedDrink
        
        inventoryViewModel.saveInventory()
        // Print a message to indicate that changes are saved
        print("Changes saved!")
        
        // Display an alert
        showAlert = true
    }
    
    
    func deleteItem() {
        // Remove the current food item from the list using the index
        inventoryViewModel.drinks.remove(at: drinkIndex)
        
        inventoryViewModel.saveInventory()
        // Implement logic to delete the item
        // For example:
        print("Food item deleted!") // for Xcode console
        
        // Display an alert or perform any other actions as needed
        showAlert = true
    }
}



struct AddFoodSheet: View {
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    
    @Binding var foodName: String
    @Binding var foodWeight: String
    @Binding var foodCalories: String
    @Binding var foodProtein: String
    @Binding var foodCarbs: String
    @Binding var foodFats: String
    @Binding var isSheetPresented: Bool
    @Binding var foods: [Food]
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Food Name", text: $foodName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Weight", text: $foodWeight)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $foodCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Protein", text: $foodProtein)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Carbs", text: $foodCarbs)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Fats", text: $foodFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                Button(action: {
                    let newFood = Food(name: foodName, weight: foodWeight, calories: foodCalories, protein: foodProtein, carbs: foodCarbs, fats: foodFats)
                    inventoryViewModel.foods.append(newFood)
                    inventoryViewModel.saveInventory()
                    isSheetPresented = false
                }) {
                    Text("Add Food")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}

struct AddDrinkSheet: View {
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    
    @Binding var drinkName: String
    @Binding var drinkVolume: String
    @Binding var drinkCalories: String
    @Binding var drinkProtein: String
    @Binding var drinkCarbs: String
    @Binding var drinkFats: String
    @Binding var isSheetPresented: Bool
    @Binding var drinks: [Drink]
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Drink Name", text: $drinkName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Volume", text: $drinkVolume)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $drinkCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Protein", text: $drinkProtein)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Carbs", text: $drinkCarbs)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Fats", text: $drinkFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                Button(action: {
                    let newDrink = Drink(name: drinkName, volume: drinkVolume, calories: drinkCalories, protein: drinkProtein, carbs: drinkCarbs, fats: drinkFats)
                    inventoryViewModel.drinks.append(newDrink)
                    inventoryViewModel.saveInventory()
                    isSheetPresented = false
                }) {
                    Text("Add Drink")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}


struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
            .environmentObject(InventoryViewModel())
    }
}
