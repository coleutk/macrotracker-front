import SwiftUI

enum Item: String, CaseIterable, Identifiable {
    case Food, Drink
    var id: Self { self }
}

struct InventoryView: View {
    @State private var foods: [Food] = []
    
    //@State private var drinks: [Drink] = []
    
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    @State private var selectedItem: Item = .Food
    
    // For Food Add Sheet
    @State private var isAddFoodSheetPresented = false
    @State private var newFoodName = ""
    @State private var newFoodWeightValue = ""
    @State private var newFoodWeightUnit = ""
    @State private var newFoodCalories = ""
    @State private var newFoodProtein = ""
    @State private var newFoodCarbs = ""
    @State private var newFoodFats = ""
    
    // For Drink Add Sheet
    @State private var isAddDrinkSheetPresented = false
    @State private var newDrinkName = ""
    @State private var newDrinkVolumeValue = ""
    @State private var newDrinkVolumeUnit = ""
    @State private var newDrinkCalories = ""
    @State private var newDrinkProtein = ""
    @State private var newDrinkCarbs = ""
    @State private var newDrinkFats = ""
    
    // For Editing Food
    @State private var foodName = ""
    @State private var foodWeightValue = ""
    @State private var foodWeightUnit = ""
    @State private var foodCalories = ""
    @State private var foodProtein = ""
    @State private var foodCarbs = ""
    @State private var foodFats = ""
    
    // For Editing Drink
    @State private var drinkName = ""
    @State private var drinkVolumeValue = ""
    @State private var drinkVolumeUnit = ""
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
                            ForEach(foods, id: \.id) { food in
                                //let food = inventoryViewModel.foods[index]
                                NavigationLink(destination: EditFoodView(food: binding(for: food))) {
                                    Text(food.name)
                                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        } else {
//                            ForEach(inventoryViewModel.drinks.indices, id: \.self) { index in
//                                let drink = inventoryViewModel.drinks[index]
//                                NavigationLink(destination:
////                                                EditDrinkView(drinkName: $drinkName, drinkVolumeValue: $drinkVolumeValue,
////                                                              drinkVolumeUnit: $drinkVolumeUnit, drinkCalories: $drinkCalories, drinkProtein: $drinkProtein, drinkCarbs: $drinkCarbs, drinkFats: $drinkFats, drinks: $inventoryViewModel.drinks, drinkIndex: index)
//                                    .environmentObject(inventoryViewModel)
//                                    .onAppear {
//                                        drinkName = drink.name
//                                        drinkVolumeValue = String(drink.volume.value)
//                                        drinkVolumeUnit = drink.volume.unit.rawValue
//                                        drinkCalories = String(drink.calories)
//                                        drinkProtein = String(drink.protein)
//                                        drinkCarbs = String(drink.carbs)
//                                        drinkFats = String(drink.fats)
//                                    }
//                                ) {
//                                    Text(drink.name)
//                                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
//                                        .foregroundColor(.white.opacity(0.70))
//                                }
//                            }
//                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                    .foregroundColor(.white)
                    .onAppear {
                        loadFoods()
                    }
                    
                }
                .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                .navigationTitle("Inventory")
                
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
//                .sheet(isPresented: $isAddFoodSheetPresented) {
//                    AddFoodSheet(foodName: $newFoodName, foodWeightValue: $newFoodWeightValue, foodWeightUnit: $newFoodWeightUnit, foodCalories: $newFoodCalories, foodProtein: $newFoodProtein, foodCarbs: $newFoodCarbs, foodFats: $newFoodFats, isSheetPresented: $isAddFoodSheetPresented, foods: $inventoryViewModel.foods)
//                        .environmentObject(inventoryViewModel)
//                }
//                
//                .sheet(isPresented: $isAddDrinkSheetPresented) {
//                    AddDrinkSheet(drinkName: $newDrinkName, drinkVolumeValue: $newDrinkVolumeValue, drinkVolumeUnit: $newDrinkVolumeUnit, drinkCalories: $newDrinkCalories, drinkProtein: $newDrinkProtein, drinkCarbs: $newDrinkCarbs, drinkFats: $newDrinkFats, isSheetPresented: $isAddDrinkSheetPresented, drinks: $inventoryViewModel.drinks)
//                        .environmentObject(inventoryViewModel)
//                }
                
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
        newFoodWeightValue = ""
        newFoodWeightUnit = ""
        newFoodCalories = ""
        newFoodProtein = ""
        newFoodCarbs = ""
        newFoodFats = ""
    }
    
    // Reset add drink fields
    private func resetAddDrinkFields() {
        newDrinkName = ""
        newDrinkVolumeValue = ""
        newDrinkVolumeUnit = ""
        newDrinkCalories = ""
        newDrinkProtein = ""
        newDrinkCarbs = ""
        newDrinkFats = ""
    }
    
    private func loadFoods() {
        print("loadFoods called")
        getAllFoods { result in
            switch result {
            case .success(let foods):
                print("Foods loaded: \(foods)") // Debug print
                self.foods = foods
            case .failure(let error):
                print("Failed to load foods: \(error.localizedDescription)")
            }
        }
    }
    
    private func binding(for food: Food) -> Binding<Food> {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else {
            fatalError("Food not found")
        }
        return $foods[index]
    }
}




import SwiftUI

struct EditFoodView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert = false
    
    @Binding var food: Food
    
    @State private var selectedUnit: String
    
    // Intermediate variables for TextField binding
    @State private var foodName: String
    @State private var foodWeightValue: String
    @State private var foodCalories: String
    @State private var foodProtein: String
    @State private var foodCarbs: String
    @State private var foodFat: String

    init(food: Binding<Food>) {
        _food = food
        _selectedUnit = State(initialValue: food.wrappedValue.weight.unit.rawValue)
        
        // Initialize intermediate variables
        _foodName = State(initialValue: food.wrappedValue.name)
        _foodWeightValue = State(initialValue: String(food.wrappedValue.weight.value))
        _foodCalories = State(initialValue: String(food.wrappedValue.calories))
        _foodProtein = State(initialValue: String(food.wrappedValue.protein))
        _foodCarbs = State(initialValue: String(food.wrappedValue.carbs))
        _foodFat = State(initialValue: String(food.wrappedValue.fat))
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
                
                HStack {
                    TextField("Weight Value", text: $foodWeightValue)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit.rawValue)
                        }
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 90)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                    .onChange(of: selectedUnit) { oldValue, newValue in
                        food.weight.unit = WeightUnit(rawValue: newValue) ?? .g
                    }
                }
                
                TextField("Calories", text: $foodCalories)
                    .keyboardType(.numberPad)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                HStack {
                    TextField("Protein", text: $foodProtein)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                HStack {
                    TextField("Carbs", text: $foodCarbs)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                HStack {
                    TextField("Fat", text: $foodFat)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                Button(action: {
                    // Save changes here
                    food.name = foodName
                    food.weight.value = Int(foodWeightValue) ?? food.weight.value
                    food.calories = Int(foodCalories) ?? food.calories
                    food.protein = Int(foodProtein) ?? food.protein
                    food.carbs = Int(foodCarbs) ?? food.carbs
                    food.fat = Int(foodFat) ?? food.fat
                    
                    print("Changes saved!")
                    showAlert = true
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
                    // Handle deletion here
                    print("Food item deleted!")
                    showAlert = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete \(food.name)")
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
}


//struct EditDrinkView: View {
//    @EnvironmentObject var inventoryViewModel: InventoryViewModel
//    @Environment(\.presentationMode) var presentationMode
//
//    @State private var showAlert = false
//    
//    @Binding var drinkName: String
//    @Binding var drinkVolumeValue: String
//    @Binding var drinkVolumeUnit: String
//    @Binding var drinkCalories: String
//    @Binding var drinkProtein: String
//    @Binding var drinkCarbs: String
//    @Binding var drinkFats: String
//    @Binding var drinks: [Drink]
//    let drinkIndex: Int
//    
//    @State private var selectedUnit: String = "mL"
//
//    init(drinkName: Binding<String>, drinkVolumeValue: Binding<String>, drinkVolumeUnit: Binding<String>, drinkCalories: Binding<String>, drinkProtein: Binding<String>, drinkCarbs: Binding<String>, drinkFats: Binding<String>, drinks: Binding<[Drink]>, drinkIndex: Int) {
//        _drinkName = drinkName
//        _drinkVolumeValue = drinkVolumeValue
//        _drinkVolumeUnit = drinkVolumeUnit
//        _drinkCalories = drinkCalories
//        _drinkProtein = drinkProtein
//        _drinkCarbs = drinkCarbs
//        _drinkFats = drinkFats
//        _drinks = drinks
//        self.drinkIndex = drinkIndex
//        _selectedUnit = State(initialValue: drinkVolumeUnit.wrappedValue)
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(red: 20/255, green: 20/255, blue: 30/255)
//                .ignoresSafeArea()
//            
//            VStack {
//                Text("Edit Details:")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white.opacity(0.70))
//                
//                TextField("Drink Name", text: $drinkName)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Volume Value", text: $drinkVolumeValue)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Picker("Unit", selection: $selectedUnit) {
//                        Text("mL").tag("mL")
//                        Text("L").tag("L")
//                        Text("floz").tag("floz")
//                        Text("c").tag("c")
//                    }
//                    .padding(8)
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(width: 90)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.leading, -20)
//                    .padding(.trailing, 22)
//                }
//                
//                TextField("Calories", text: $drinkCalories)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Protein", text: $drinkProtein)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Carbs", text: $drinkCarbs)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Fat", text: $drinkFats)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                Button(action: {
//                    guard let volumeValue = Int(drinkVolumeValue),
//                          let calories = Int(drinkCalories),
//                          let protein = Double(drinkProtein),
//                          let carbs = Int(drinkCarbs),
//                          let fats = Double(drinkFats) else {
//                        print("Invalid input")
//                        return
//                    }
//                    
//                    let editedDrink = Drink(id: UUID(), name: drinkName, volume: Volume(value: volumeValue, unit: Unit(rawValue: selectedUnit)!), calories: calories, protein: protein, carbs: carbs, fats: fats)
//                    inventoryViewModel.drinks[drinkIndex] = editedDrink
//                    
//                    inventoryViewModel.saveInventory()
//                    
//                    // Print a message to indicate that changes are saved
//                    print("Changes saved!")
//                    
//                    // Display an alert
//                    showAlert = true
//                    
//                    // Dismiss the view and go back to inventory
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Confirm Changes")
//                        .foregroundColor(.white.opacity(0.70))
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue.opacity(0.50))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                        .padding(.top, 20)
//                }
//                
//                // Delete Item Button
//                Button(action: {
//                    // Remove the current drink item from the list using the index
//                    inventoryViewModel.drinks.remove(at: drinkIndex)
//                    
//                    inventoryViewModel.saveInventory()
//                    
//                    // Print a message to indicate that the item is deleted
//                    print("Drink item deleted!")
//                    
//                    // Display an alert or perform any other actions as needed
//                    showAlert = true
//                    
//                    // Dismiss the view and go back to inventory
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Delete \(drinkName)")
//                        .foregroundColor(.white.opacity(0.70))
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red.opacity(0.50))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                        .padding(.top, 20)
//                }
//            }
//            .foregroundColor(.white.opacity(0.70))
//            .padding(.bottom, 50)
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Changes Saved"), message: Text("Your changes have been saved."), dismissButton: .default(Text("OK")))
//        }
//    }
//}
//
//
//
//struct AddFoodSheet: View {
//    @EnvironmentObject var inventoryViewModel: InventoryViewModel
//    
//    @Binding var foodName: String
//    @Binding var foodWeightValue: String
//    @Binding var foodWeightUnit: String
//    @Binding var foodCalories: String
//    @Binding var foodProtein: String
//    @Binding var foodCarbs: String
//    @Binding var foodFats: String
//    @Binding var isSheetPresented: Bool
//    @Binding var foods: [Food]
//    
//    @State private var selectedUnit: String = "g"
//    
//    var body: some View {
//        ZStack {
//            Color(red: 20/255, green: 20/255, blue: 30/255)
//                .ignoresSafeArea()
//            VStack {
//                Text("Details:")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white.opacity(0.70))
//                
//                TextField("Food Name", text: $foodName)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Weight Value", text: $foodWeightValue)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Picker("Unit", selection: $selectedUnit) {
//                        Text("g").tag("g")
//                        Text("kg").tag("kg")
//                        Text("mg").tag("mg")
//                        Text("oz").tag("oz")
//                        Text("lb").tag("lb")
//                    }
//                    .padding(8)
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(width: 90)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.leading, -20)
//                    .padding(.trailing, 22)
//                }
//                
//                TextField("Calories", text: $foodCalories)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Protein", text: $foodProtein)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Carbs", text: $foodCarbs)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Fat", text: $foodFats)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                Button(action: {
//                    guard let weightValue = Int(foodWeightValue),
//                          let calories = Int(foodCalories),
//                          let protein = Double(foodProtein),
//                          let carbs = Int(foodCarbs),
//                          let fats = Double(foodFats) else {
//                        print("Invalid input")
//                        return
//                    }
//                    
//                    let newFood = Food(id: UUID(), name: foodName, weight: Weight(value: weightValue, unit: Unit(rawValue: selectedUnit)!), calories: calories, protein: protein, carbs: carbs, fats: fats)
//                    inventoryViewModel.foods.append(newFood)
//                    inventoryViewModel.saveInventory()
//                    isSheetPresented = false
//                }) {
//                    Text("Add Food")
//                        .foregroundColor(.white.opacity(0.70))
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue.opacity(0.50))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                        .padding(.top, 20)
//                }
//            }
//            .foregroundColor(.white.opacity(0.70))
//        }
//    }
//}
//
//struct AddDrinkSheet: View {
//    @EnvironmentObject var inventoryViewModel: InventoryViewModel
//    
//    @Binding var drinkName: String
//    @Binding var drinkVolumeValue: String
//    @Binding var drinkVolumeUnit: String
//    @Binding var drinkCalories: String
//    @Binding var drinkProtein: String
//    @Binding var drinkCarbs: String
//    @Binding var drinkFats: String
//    @Binding var isSheetPresented: Bool
//    @Binding var drinks: [Drink]
//    
//    @State private var selectedUnit: String = "mL"
//    
//    var body: some View {
//        ZStack {
//            Color(red: 20/255, green: 20/255, blue: 30/255)
//                .ignoresSafeArea()
//            VStack {
//                Text("Details:")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white.opacity(0.70))
//                
//                TextField("Drink Name", text: $drinkName)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Volume Value", text: $drinkVolumeValue)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Picker("Unit", selection: $selectedUnit) {
//                        Text("mL").tag("mL")
//                        Text("L").tag("L")
//                        Text("floz").tag("floz")
//                        Text("c").tag("c")
//                    }
//                    .padding(8)
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(width: 90)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.leading, -20)
//                    .padding(.trailing, 22)
//                }
//                
//                TextField("Calories", text: $drinkCalories)
//                    .padding(14)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black.opacity(0.20))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 22)
//                
//                HStack {
//                    TextField("Protein", text: $drinkProtein)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Carbs", text: $drinkCarbs)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                HStack {
//                    TextField("Fat", text: $drinkFats)
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                    
//                    Text("g")
//                        .padding(14)
//                        .frame(width: 90)
//                        .background(Color.black.opacity(0.20))
//                        .cornerRadius(15)
//                        .padding(.leading, -20)
//                        .padding(.trailing, 22)
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                
//                Button(action: {
//                    guard let volumeValue = Int(drinkVolumeValue),
//                          let calories = Int(drinkCalories),
//                          let protein = Double(drinkProtein),
//                          let carbs = Int(drinkCarbs),
//                          let fats = Double(drinkFats) else {
//                        print("Invalid input")
//                        return
//                    }
//                    
//                    let newDrink = Drink(id: UUID(), name: drinkName, volume: Volume(value: volumeValue, unit: Unit(rawValue: selectedUnit)!), calories: calories, protein: protein, carbs: carbs, fats: fats)
//                    inventoryViewModel.drinks.append(newDrink)
//                    inventoryViewModel.saveInventory()
//                    isSheetPresented = false
//                }) {
//                    Text("Add Drink")
//                        .foregroundColor(.white.opacity(0.70))
//                        .padding(14)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue.opacity(0.50))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 22)
//                        .padding(.top, 20)
//                }
//            }
//            .foregroundColor(.white.opacity(0.70))
//        }
//    }
//}


struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
