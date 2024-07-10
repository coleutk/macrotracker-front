import SwiftUI

enum Item: String, CaseIterable, Identifiable {
    case Food, Drink
    var id: Self { self }
}

struct InventoryView: View {
    @State private var foods: [Food] = []    
    @State private var drinks: [Drink] = []
    
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
                                NavigationLink(destination: EditFoodView(
                                    food: bindingFood(for: food),
                                    onSave: {
                                        loadFoods()
                                    },
                                    onDelete: {
                                        loadFoods()
                                    }
                                )) {
                                    Text(food.name)
                                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        } else {
                            ForEach(drinks, id: \.id) { drink in
                                NavigationLink(destination: EditDrinkView(
                                    drink: bindingDrink(for: drink),
                                    onSave: {
                                        loadDrinks()
                                    },
                                    onDelete: {
                                        loadDrinks()
                                    }
                                )) {
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
                    .onAppear {
                        loadFoods()
                        loadDrinks()
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
                .sheet(isPresented: $isAddFoodSheetPresented) {
                    AddFoodSheet(foodName: $newFoodName, foodWeightValue: $newFoodWeightValue, foodWeightUnit: $newFoodWeightUnit, foodCalories: $newFoodCalories, foodProtein: $newFoodProtein, foodCarbs: $newFoodCarbs, foodFats: $newFoodFats, isSheetPresented: $isAddFoodSheetPresented, foods: $foods)
                        .onDisappear {
                            loadFoods()
                        }
                }

                .sheet(isPresented: $isAddDrinkSheetPresented) {
                    AddDrinkSheet(drinkName: $newDrinkName, drinkVolumeValue: $newDrinkVolumeValue, drinkVolumeUnit: $newDrinkVolumeUnit, drinkCalories: $newDrinkCalories, drinkProtein: $newDrinkProtein, drinkCarbs: $newDrinkCarbs, drinkFats: $newDrinkFats, isSheetPresented: $isAddDrinkSheetPresented, drinks: $drinks)
                        .onDisappear {
                            loadDrinks()
                        }
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
    
    private func loadDrinks() {
        print("loadDrinks called")
        getAllDrinks { result in
            switch result {
            case .success(let drinks):
                print("Drinks loaded: \(drinks)") // Debug print
                self.drinks = drinks
            case .failure(let error):
                print("Failed to load drinks: \(error.localizedDescription)")
            }
        }
    }
    
    private func bindingFood(for food: Food) -> Binding<Food> {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else {
            fatalError("Food not found")
        }
        return $foods[index]
    }
    
    private func bindingDrink(for drink: Drink) -> Binding<Drink> {
        guard let index = drinks.firstIndex(where: { $0.id == drink.id }) else {
            fatalError("Drink not found")
        }
        return $drinks[index]
    }
}

struct MacroDisplayVertical: View {
    var nutrient: String
    var color: Color

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(color.opacity(0.30))
                    .frame(width: 55, height: 28) // Outer colored rounded rectangle

                HStack {
                    Text("\(nutrient)")
                        .foregroundColor(.white.opacity(0.50))
                        .bold()
                        .font(.system(size: 11)) // Adjusted font size
                }
            }
        }
        .rotationEffect(.degrees(-90))
        .padding(.leading, 5)
    }
}

struct EditFoodView: View {
    @Environment(\.presentationMode) var presentationMode

    // Saving Food Details
    @State private var showAlert = false
    @State private var alertMessage = "Changes saved!"
    
    @Binding var food: Food
    var onSave: (() -> Void)?
    var onDelete: (() -> Void)? // Callback for deletion
    
    @State private var selectedUnit: String
    
    // Intermediate variables for TextField binding
    @State private var foodName: String
    @State private var foodWeightValue: String
    @State private var foodCalories: String
    @State private var foodProtein: String
    @State private var foodCarbs: String
    @State private var foodFat: String

    init(food: Binding<Food>, onSave: (() -> Void)?, onDelete: (() -> Void)?) {
        _food = food
        _selectedUnit = State(initialValue: food.wrappedValue.weight.unit.rawValue)
        self.onDelete = onDelete
        
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
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $foodName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Weight", color: Color(.white))
                    
                    TextField("Enter Amount...", text: $foodWeightValue)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit.rawValue)
                        }
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80, height: 60)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                    .onChange(of: selectedUnit) { oldValue, newValue in
                        food.weight.unit = WeightUnit(rawValue: newValue) ?? .g
                    }
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $foodCalories)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $foodProtein)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    
                    TextField("Enter Amount...", text: $foodCarbs)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fats", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    TextField("Enter Amount...", text: $foodFat)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                Button(action: {
                    // Save changes here
                    food.name = foodName
                    food.weight.value = Int(foodWeightValue) ?? food.weight.value
                    food.calories = Int(foodCalories) ?? food.calories
                    food.protein = Int(foodProtein) ?? food.protein
                    food.carbs = Int(foodCarbs) ?? food.carbs
                    food.fat = Int(foodFat) ?? food.fat
                    
                    // Call the editFood function
                    editFood(food) { result in
                        switch result {
                        case .success(let updatedFood):
                            onSave?()
                            print("Changes saved: \(updatedFood)")
                            alertMessage = "Changes saved!"
                            showAlert = true
                            food = updatedFood // Update the food with the returned updatedFood
                        case .failure(let error):
                            print("Failed to save changes: \(error)")
                            alertMessage = "Failed to save changes: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
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
                    deleteFood(food) { result in
                        switch result {
                        case .success:
                            onDelete?() // Call the onDelete callback
                            print("Food item deleted!")
                            alertMessage = "Food item deleted!"
                            showAlert = true
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print("Failed to delete food item: \(error)")
                            alertMessage = "Failed to delete food item: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
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


struct EditDrinkView: View {
    @Environment(\.presentationMode) var presentationMode

    // Saving Drink Details
    @State private var showAlert = false
    @State private var alertMessage = "Changes saved!"
    
    @Binding var drink: Drink
    var onSave: (() -> Void)?
    var onDelete: (() -> Void)? // Callback for deletion
    
    @State private var selectedUnit: String
    
    // Intermediate variables for TextField binding
    @State private var drinkName: String
    @State private var drinkVolumeValue: String
    @State private var drinkCalories: String
    @State private var drinkProtein: String
    @State private var drinkCarbs: String
    @State private var drinkFat: String

    init(drink: Binding<Drink>, onSave: (() -> Void)?, onDelete: (() -> Void)?) {
        _drink = drink
        _selectedUnit = State(initialValue: drink.wrappedValue.volume.unit.rawValue)
        self.onDelete = onDelete

        
        // Initialize intermediate variables
        _drinkName = State(initialValue: drink.wrappedValue.name)
        _drinkVolumeValue = State(initialValue: String(drink.wrappedValue.volume.value))
        _drinkCalories = State(initialValue: String(drink.wrappedValue.calories))
        _drinkProtein = State(initialValue: String(drink.wrappedValue.protein))
        _drinkCarbs = State(initialValue: String(drink.wrappedValue.carbs))
        _drinkFat = State(initialValue: String(drink.wrappedValue.fat))
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
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $drinkName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Volume", color: Color(.white))
                    
                    TextField("Enter Amount...", text: $drinkVolumeValue)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(VolumeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit.rawValue)
                        }
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80, height: 60)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                    .onChange(of: selectedUnit) { oldValue, newValue in
                        drink.volume.unit = VolumeUnit(rawValue: newValue) ?? .mL
                    }
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $drinkCalories)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $drinkProtein)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    
                    TextField("Enter Amount...", text: $drinkCarbs)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fats", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    TextField("Enter Amount...", text: $drinkFat)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                Button(action: {
                    // Save changes here
                    drink.name = drinkName
                    drink.volume.value = Int(drinkVolumeValue) ?? drink.volume.value
                    drink.calories = Int(drinkCalories) ?? drink.calories
                    drink.protein = Int(drinkProtein) ?? drink.protein
                    drink.carbs = Int(drinkCarbs) ?? drink.carbs
                    drink.fat = Int(drinkFat) ?? drink.fat
                    
                    // Call the editDrink function
                    editDrink(drink) { result in
                        switch result {
                        case .success(let updatedDrink):
                            onSave?()
                            print("Changes saved: \(updatedDrink)")
                            alertMessage = "Changes saved!"
                            showAlert = true
                            drink = updatedDrink // Update the drink with the returned updatedDrink
                        case .failure(let error):
                            print("Failed to save changes: \(error)")
                            alertMessage = "Failed to save changes: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
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
                    deleteDrink(drink) { result in
                        switch result {
                        case .success:
                            onDelete?() // Call the onDelete callback
                            print("Drink item deleted!")
                            alertMessage = "Drink item deleted!"
                            showAlert = true
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print("Failed to delete drink item: \(error)")
                            alertMessage = "Failed to delete drink item: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
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
}


struct AddFoodSheet: View {
    @Binding var foodName: String
    @Binding var foodWeightValue: String
    @Binding var foodWeightUnit: String
    @Binding var foodCalories: String
    @Binding var foodProtein: String
    @Binding var foodCarbs: String
    @Binding var foodFats: String
    @Binding var isSheetPresented: Bool
    @Binding var foods: [Food]
    
    @State private var selectedUnit: String = "g"
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $foodName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Weight", color: Color(.white))
                    
                    TextField("Enter Amount...", text: $foodWeightValue)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("g").tag("g")
                        Text("kg").tag("kg")
                        Text("mg").tag("mg")
                        Text("oz").tag("oz")
                        Text("lb").tag("lb")
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80, height: 60)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $foodCalories)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $foodProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    
                    TextField("Enter Amount...", text: $foodCarbs)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fats", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    TextField("Enter Amount...", text: $foodFats)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                Button(action: {
                    guard let foodWeightValue = Int(foodWeightValue),
                          let foodCalories = Int(foodCalories),
                          let foodProtein = Int(foodProtein),
                          let foodCarbs = Int(foodCarbs),
                          let foodFats = Int(foodFats) else {
                        print("Invalid input")
                        return
                    }
                    
                    addFood(name: foodName, weightValue: foodWeightValue, weightUnit: selectedUnit, calories: foodCalories, protein: foodProtein, carbs: foodCarbs, fats: foodFats) { success, message in
                        if success {
                            print("Food created successfully")
                        } else {
                            print("Failed to create goal: \(message ?? "Unknown error")")
                        }
                    }
                    
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
    @Binding var drinkName: String
    @Binding var drinkVolumeValue: String
    @Binding var drinkVolumeUnit: String
    @Binding var drinkCalories: String
    @Binding var drinkProtein: String
    @Binding var drinkCarbs: String
    @Binding var drinkFats: String
    @Binding var isSheetPresented: Bool
    @Binding var drinks: [Drink]
    
    @State private var selectedUnit: String = "mL"
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $drinkName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Volume", color: Color(.white))
                    
                    TextField("Enter Amount...", text: $drinkVolumeValue)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("mL").tag("mL")
                        Text("L").tag("L")
                        Text("oz").tag("oz")
                        Text("c").tag("c")
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80, height: 60)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $drinkCalories)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $drinkProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    
                    TextField("Enter Amount...", text: $drinkCarbs)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fats", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    TextField("Enter Amount...", text: $drinkFats)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                Button(action: {
                    guard let drinkVolumeValue = Int(drinkVolumeValue),
                          let drinkCalories = Int(drinkCalories),
                          let drinkProtein = Int(drinkProtein),
                          let drinkCarbs = Int(drinkCarbs),
                          let drinkFats = Int(drinkFats) else {
                        print("Invalid input")
                        return
                    }
                    
                    addDrink(name: drinkName, volumeValue: drinkVolumeValue, volumeUnit: selectedUnit, calories: drinkCalories, protein: drinkProtein, carbs: drinkCarbs, fats: drinkFats) { success, message in
                        if success {
                            print("Drink created successfully")
                        } else {
                            print("Failed to create goal: \(message ?? "Unknown error")")
                        }
                    }
                    
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
    }
}
