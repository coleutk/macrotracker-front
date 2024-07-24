import SwiftUI

struct HomeView: View {
    var username: String
    @State private var selectedGoal: SelectedGoal? = nil
    @State private var dailyRecord: DailyRecord? = nil
    @State private var foods: [Food] = []
    @State private var drinks: [Drink] = []

    @State var calorieProgress: Float = 0.0
    @State var proteinProgress: Float = 0.0
    @State var carbProgress: Float = 0.0
    @State var fatProgress: Float = 0.0

    @State private var isInventorySelectionSheetPresented = false

    @State private var isManualWriteSheetPresented = false
    @State private var manualCalories = ""
    @State private var manualProtein = ""
    @State private var manualCarbs = ""
    @State private var manualFats = ""

    @State private var totalCalories: Int = 0
    @State private var totalProtein: Int = 0
    @State private var totalCarbs: Int = 0
    @State private var totalFats: Int = 0
    
    @State private var errorMessage: String? = nil


    func updateProgress() {
        if let goal = selectedGoal, let record = dailyRecord {
            totalCalories = record.calories
            totalProtein = record.protein
            totalCarbs = record.carbs
            totalFats = record.fat

            calorieProgress = min(Float(totalCalories) / Float(goal.calorieGoal), 1.0)
            proteinProgress = min(Float(totalProtein) / Float(goal.proteinGoal), 1.0)
            carbProgress = min(Float(totalCarbs) / Float(goal.carbGoal), 1.0)
            fatProgress = min(Float(totalFats) / Float(goal.fatGoal), 1.0)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 20/255, green: 20/255, blue: 30/255)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button(action: {
                            //isAddFoodSheetPresented.toggle()
                        }) {
                            ZStack {
                                 if let goal = selectedGoal {
                                     Text("\(goal.name)")
                                         .font(.title)
                                         .bold()
                                         .padding(10)
                                         .background(
                                             RoundedRectangle(cornerRadius: 10)
                                                 .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                                         )
                                 } else if selectedGoal == nil{
                                     ZStack {
                                         RoundedRectangle(cornerRadius: 10)
                                             .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                                             .frame(width: 300)
                                             .frame(height: 100)
                                         VStack {
                                             Text("[No goal selected]")
                                                 .font(.title)
                                                 .bold()
                                                 .padding(10)
                                                 .padding(.bottom, -20)
                                             Text("Create your goal in Profile!")
                                                 .font(.title3)
                                                 .padding(10)
                                         }
                                     }
                                 }
                             }
                         }
                         .buttonStyle(MyButtonStyle())
                         .padding(.horizontal, 10)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                            GridRow {
                                if let goal = selectedGoal {
                                    NutrientView(nutrient: "Calories", curValue: Int(totalCalories), goalValue: goal.calorieGoal, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                                    NutrientView(nutrient: "Protein", curValue: Int(totalProtein), goalValue: goal.proteinGoal, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                                }
                            }
                            GridRow {
                                if let goal = selectedGoal {
                                    NutrientView(nutrient: "Carbs", curValue: Int(totalCarbs), goalValue: goal.carbGoal, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                                    NutrientView(nutrient: "Fat", curValue: Int(totalFats), goalValue: goal.fatGoal, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    ZStack {
                        ProgressBar(progress: self.$calorieProgress, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                            .frame(width: 325.0, height: 325.0)
                            .padding(15.0)
                            .animation(.easeInOut(duration: 2.0), value: calorieProgress)
                        
                        ProgressBar(progress: self.$proteinProgress, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                            .frame(width: 239.0, height: 239.0)
                            .padding(15.0)
                            .animation(.easeInOut(duration: 2.0), value: proteinProgress)
                        
                        ProgressBar(progress: self.$carbProgress, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                            .frame(width: 153.0, height: 153.0)
                            .padding(15.0)
                            .animation(.easeInOut(duration: 2.0), value: carbProgress)
                        
                        ProgressBar(progress: self.$fatProgress, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                            .frame(width: 67.0, height: 67.0)
                            .padding(15.0)
                            .animation(.easeInOut(duration: 2.0), value: fatProgress)
                    }
                    .padding(.bottom, 20)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                isManualWriteSheetPresented.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                                        .frame(width: 50, height: 50)
                                    
                                    VStack {
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                    }
                                    .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .buttonStyle(MyButtonStyle())
                            .padding(.horizontal, 10)
                            .sheet(isPresented: $isManualWriteSheetPresented, onDismiss: {
                                fetchCurrentDailyRecord()
                            }) {
                                ManualWriteSheet(
                                    manualCalories: $manualCalories,
                                    manualProtein: $manualProtein,
                                    manualCarbs: $manualCarbs,
                                    manualFats: $manualFats,
                                    isSheetPresented: $isManualWriteSheetPresented,
                                    totalCalories: $totalCalories,
                                    totalProtein: $totalProtein,
                                    totalCarbs: $totalCarbs,
                                    totalFats: $totalFats,
                                    updateProgress: updateProgress
                                )
                            }
                            
                            Button(action: {
                                isInventorySelectionSheetPresented.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                                        .frame(width: 50, height: 50)
                                    
                                    VStack {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                    }
                                    .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .buttonStyle(MyButtonStyle())
                            .padding(.horizontal, 10)
                            .sheet(isPresented: $isInventorySelectionSheetPresented, onDismiss: {
                                fetchCurrentDailyRecord()
                            }) {
                                InventorySelectionSheet(
                                    totalCalories: $totalCalories,
                                    totalProtein: $totalProtein,
                                    totalCarbs: $totalCarbs,
                                    totalFats: $totalFats,
                                    updateProgress: updateProgress
                                )
                            }
                        }
                    }
                    .padding(.bottom, 60)
                    
                    HStack {
                        NavigationLink(destination: NutritionLogView()) {
                            VStack {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                Text("Nutrition Log")
                                    .font(.system(size: 15))
                            }
                        }
                        .buttonStyle(MyButtonStyle())
                        .offset(x: 35)
                        .padding(.top, 5)
                        
                        Spacer()
                        
                        NavigationLink(destination: InventoryView()) {
                            VStack {
                                Image(systemName: "fork.knife")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                Text("Inventory")
                                    .font(.system(size: 15))
                            }
                        }
                        .buttonStyle(MyButtonStyle())
                        .offset(x: -16)
                        .padding(.top, 5)
                        
                        Spacer()
                        
                        NavigationLink(destination: ProfileView(username: "cratik")) {
                            VStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                Text("Profile")
                                    .font(.system(size: 15))
                            }
                        }
                        .buttonStyle(MyButtonStyle())
                        .offset(x: -52)
                        .padding(.top, 5)
                    }
                    .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .frame(height: 5)
                }
            }
            .onAppear {
                fetchUserSelectedGoal()
                fetchCurrentDailyRecord()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    struct MyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(5)
                .foregroundColor(.white.opacity(0.70))
        }
    }
    
    private func fetchUserSelectedGoal() {
        getUserSelectedGoal { result in
            switch result {
            case .success(let goal):
                DispatchQueue.main.async {
                    self.selectedGoal = goal
                }
            case .failure(let error):
                if (error as NSError).code == 404 { // Assuming 404 is the error code for no goal found
                    DispatchQueue.main.async {
                        self.selectedGoal = nil // No goal found
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func fetchCurrentDailyRecord() {
        getCurrentDaily { result in
            switch result {
            case .success(let record):
                DispatchQueue.main.async {
                    self.dailyRecord = record
                    self.updateProgress()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    // If no record exists, initialize values to zero
                    self.dailyRecord = DailyRecord(id: "", userId: "", date: "", calories: 0, protein: 0, carbs: 0, fat: 0, manuals: [], foods: [], drinks: [])
                    self.updateProgress()
                }
            }
        }
    }
}


struct NutrientView: View {
    var nutrient: String
    var curValue: Int
    var goalValue: Int
    var color: Color

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .frame(width: 100, height: 25) // Outer colored rounded rectangle

                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color.opacity(0.70), lineWidth: 2) // Hollow inner rounded rectangle
                    .frame(width: 98, height: 23) // Adjusted size to fit inside the outer rectangle


                HStack {
                    Text("\(nutrient)")
                        .foregroundColor(.white.opacity(0.70))
                        .bold()
                        .font(.system(size: 14)) // Adjusted font size
                }
            }

            Text("\(String(curValue))\(nutrient == "Calories" ? "" : "g") / \(String((goalValue)))\(nutrient == "Calories" ? "" : "g")")
                .foregroundColor(.white.opacity(0.70))
                .bold()
                .font(.system(size: 14)) // Adjusted font size
        }
        .padding(5) // Adjusted padding
    }
}


struct ProgressBar : View {
    @Binding var progress: Float
    var color: Color = Color.green
    var outlineWidth: Double = 30.0
    var fillerWidth: Double = 20.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: outlineWidth)
                .opacity(0.20)
                .foregroundColor(.white.opacity(0.70))

            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1)))
                .stroke(style: StrokeStyle(lineWidth: fillerWidth, lineCap:
                        .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270))

        }
    }
}

// ManualWriteSheet when click PENCIL ICON
struct ManualWriteSheet: View {
    @Binding var manualCalories: String
    @Binding var manualProtein: String
    @Binding var manualCarbs: String
    @Binding var manualFats: String
    @Binding var isSheetPresented: Bool

    @Binding var totalCalories: Int
    @Binding var totalProtein: Int
    @Binding var totalCarbs: Int
    @Binding var totalFats: Int
    
    @State private var message = ""
    @State private var showAlert = false

    var updateProgress: () -> Void

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
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $manualCalories)
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
                    
                    TextField("Enter Amount...", text: $manualProtein)
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
                    
                    TextField("Enter Amount...", text: $manualCarbs)
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
                    
                    TextField("Enter Amount...", text: $manualFats)
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
                    // Generate a unique ID
                    let id = UUID().uuidString
                    // Convert input values from String to Int
                    let calories = Int(manualCalories) ?? 0
                    let protein = Int(manualProtein) ?? 0
                    let carbs = Int(manualCarbs) ?? 0
                    let fats = Int(manualFats) ?? 0

                    // Call the addManualToDaily function
                    addManualToDaily(
                        _id: id,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fats
                    )  { success, error in
                        DispatchQueue.main.async {
                            if success {
                                message = "Manual added to daily successfully!"
                            } else {
                                message = error ?? "Failed to add manual to daily."
                            }
                            showAlert = true
                        }
                    }
                    
                    // Add manually entered values to total values
                    totalCalories += Int(manualCalories) ?? 0
                    totalProtein += Int(manualProtein) ?? 0
                    totalCarbs += Int(manualCarbs) ?? 0
                    totalFats += Int(manualFats) ?? 0

                    // Clear the text fields
                    manualCalories = ""
                    manualProtein = ""
                    manualCarbs = ""
                    manualFats = ""

                    // Update the progress bars
                    updateProgress()

                    // Close the sheet
                    isSheetPresented = false
                }) {
                    Text("Add Manually")
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


struct InventorySelectionSheet: View {
    @State private var selectedItem: Item = .Food
    @State private var foods: [Food] = []
    @State private var drinks: [Drink] = []
    
    @State private var isFoodInputSheetPresented = false
    @State private var isDrinkInputSheetPresented = false
    @State private var selectedFood: Food? = nil
    @State private var selectedDrink: Drink? = nil
    
    @Binding var totalCalories: Int
    @Binding var totalProtein: Int
    @Binding var totalCarbs: Int
    @Binding var totalFats: Int

    var updateProgress: () -> Void
    
    
    class SheetMananger: ObservableObject{
        enum Sheet{
            case Food
            case Drink
        }
        
        @Published var showSheet = false
        @Published var whichSheet: Sheet? = nil
    }
    
    @StateObject var sheetManager = SheetMananger()

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
                                Button(action: {
                                    selectedFood = food
                                    sheetManager.whichSheet = .Food
                                    sheetManager.showSheet.toggle()
                                }) {
                                    Text(food.name)
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        } else {
                            ForEach(drinks, id: \.id) { drink in
                                Button(action: {
                                    selectedDrink = drink
                                    sheetManager.whichSheet = .Drink
                                    sheetManager.showSheet.toggle()
                                }) {
                                    Text(drink.name)
                                        .foregroundColor(.white.opacity(0.70))
                                }
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .foregroundColor(.white)
                    .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                    .onAppear {
                        loadFoods()
                        loadDrinks()
                    }
                    .sheet(isPresented: $sheetManager.showSheet, content: {
                        if let whichSheet = sheetManager.whichSheet {
                            switch whichSheet {
                            case .Food:
                                if let selectedFood = selectedFood {
                                    FoodInputSheet(
                                        food: bindingFood(for: selectedFood),
                                        totalCalories: $totalCalories,
                                        totalProtein: $totalProtein,
                                        totalCarbs: $totalCarbs,
                                        totalFats: $totalFats,
                                        updateProgress: updateProgress
                                    )
                                }
                            case .Drink:
                                if let selectedDrink = selectedDrink {
                                    DrinkInputSheet(
                                        drink: bindingDrink(for: selectedDrink),
                                        totalCalories: $totalCalories,
                                        totalProtein: $totalProtein,
                                        totalCarbs: $totalCarbs,
                                        totalFats: $totalFats,
                                        updateProgress: updateProgress
                                    )
                                }
                            }
                        }
                    })
                }
                .background(Color(red: 20/255, green: 20/255, blue: 30/255))
            }
        }
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

// For User to input Food Item Consumption
struct FoodInputSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var food: Food
    
    // For Adding Input to totals
    @Binding var totalCalories: Int
    @Binding var totalProtein: Int
    @Binding var totalCarbs: Int
    @Binding var totalFats: Int

    var updateProgress: () -> Void
    
    @State private var selectedUnit: String
    @State private var servingSize: String
    // Intermediate variables for TextField binding
    @State private var foodName: String
    @State private var foodWeightValue: String
    @State private var foodCalories: String
    @State private var foodProtein: String
    @State private var foodCarbs: String
    @State private var foodFat: String

    @FocusState private var isServingSizeFocused: Bool
    @FocusState private var isWeightValueFocused: Bool
    
    @State private var message = ""
    @State private var showAlert = false

    init(food: Binding<Food>, totalCalories: Binding<Int>, totalProtein: Binding<Int>, totalCarbs: Binding<Int>, totalFats: Binding<Int>, updateProgress: @escaping () -> Void) {
        _food = food
        _totalCalories = totalCalories
        _totalProtein = totalProtein
        _totalCarbs = totalCarbs
        _totalFats = totalFats
        self.updateProgress = updateProgress
        
        _selectedUnit = State(initialValue: food.wrappedValue.weight.unit.rawValue)
        _servingSize = State(initialValue: String(format: "%.2f", 1.0))
        // Initialize intermediate variables
        _foodName = State(initialValue: food.wrappedValue.name)
        _foodWeightValue = State(initialValue: String(food.wrappedValue.weight.value))
        _foodCalories = State(initialValue: String(food.wrappedValue.calories))
        _foodProtein = State(initialValue: String(food.wrappedValue.protein))
        _foodCarbs = State(initialValue: String(food.wrappedValue.carbs))
        _foodFat = State(initialValue: String(food.wrappedValue.fat))
    }
    
    func recalculateMacronutrients() {
        guard let foodWeightValue = Float(foodWeightValue) else { return }
        
        let weightFactor = foodWeightValue / Float(food.weight.value)
        foodCalories = String(Int(Float(food.calories) * weightFactor))
        foodProtein = String(Int(Float(food.protein) * weightFactor))
        foodCarbs = String(Int(Float(food.carbs) * weightFactor))
        foodFat = String(Int(Float(food.fat) * weightFactor))
    }
    
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Serving", color: Color(.white))
                    
                    TextField("Serving Size", text: $servingSize)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .focused($isServingSizeFocused)
                        .onSubmit {
                            let newServingSize = Float(servingSize) ?? 1.0
                            foodWeightValue = String(Float(food.weight.value) * newServingSize)
                            recalculateMacronutrients()
                        }
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
                        .focused($isWeightValueFocused)
                        .onSubmit {
                            guard let weightValue = Float(foodWeightValue), weightValue != 0 else { return }
                            servingSize = String(format: "%.2f", weightValue / Float(food.weight.value))
                            recalculateMacronutrients()
                        }
                    
                    Text(selectedUnit)
                        .padding(8)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .opacity(0.70)
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $foodProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                    guard let flooredWeightValue = Float(foodWeightValue) else { return }
                    addFoodToDaily(
                        name: food.name,
                        servings: Float(servingSize) ?? 0,
                        weightValue: Int(floor(flooredWeightValue)),
                        weightUnit: selectedUnit,
                        calories: Int(foodCalories) ?? 0,
                        protein: Int(foodProtein) ?? 0,
                        carbs: Int(foodCarbs) ?? 0,
                        fats: Int(foodFat) ?? 0
                    ) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                message = "Food added to daily successfully!"
                            } else {
                                message = error ?? "Failed to add food to daily."
                            }
                            showAlert = true
                        }
                    }

                    
                    // Update total values
                    totalCalories += Int(foodCalories) ?? 0
                    totalProtein += Int(foodProtein) ?? 0
                    totalCarbs += Int(foodCarbs) ?? 0
                    totalFats += Int(foodFat) ?? 0

                    // Update progress bars
                    updateProgress()

                    // Close the sheet
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add to user's goal")
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



// For User to input Drink Item Consumption
struct DrinkInputSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var drink: Drink
    
    // For Adding Input to totals
    @Binding var totalCalories: Int
    @Binding var totalProtein: Int
    @Binding var totalCarbs: Int
    @Binding var totalFats: Int

    var updateProgress: () -> Void
    
    @State private var selectedUnit: String
    @State private var servingSize: String
    
    // Intermediate variables for TextField binding
    @State private var drinkName: String
    @State private var drinkVolumeValue: String
    @State private var drinkCalories: String
    @State private var drinkProtein: String
    @State private var drinkCarbs: String
    @State private var drinkFat: String
    
    @FocusState private var isServingSizeFocused: Bool
    @FocusState private var isVolumeValueFocused: Bool
    
    @State private var message = ""
    @State private var showAlert = false

    init(drink: Binding<Drink>, totalCalories: Binding<Int>, totalProtein: Binding<Int>, totalCarbs: Binding<Int>, totalFats: Binding<Int>, updateProgress: @escaping () -> Void) {
        _drink = drink
        _totalCalories = totalCalories
        _totalProtein = totalProtein
        _totalCarbs = totalCarbs
        _totalFats = totalFats
        self.updateProgress = updateProgress
        
        _selectedUnit = State(initialValue: drink.wrappedValue.volume.unit.rawValue)
        _servingSize = State(initialValue: String(format: "%.2f", 1.0))
        
        // Initialize intermediate variables
        _drinkName = State(initialValue: drink.wrappedValue.name)
        _drinkVolumeValue = State(initialValue: String(drink.wrappedValue.volume.value))
        _drinkCalories = State(initialValue: String(drink.wrappedValue.calories))
        _drinkProtein = State(initialValue: String(drink.wrappedValue.protein))
        _drinkCarbs = State(initialValue: String(drink.wrappedValue.carbs))
        _drinkFat = State(initialValue: String(drink.wrappedValue.fat))
    }
    
    func recalculateMacronutrients() {
        guard let drinkVolumeValue = Float(drinkVolumeValue) else { return }
        
        let volumeFactor = drinkVolumeValue / Float(drink.volume.value)
        drinkCalories = String(Int(Float(drink.calories) * volumeFactor))
        drinkProtein = String(Int(Float(drink.protein) * volumeFactor))
        drinkCarbs = String(Int(Float(drink.carbs) * volumeFactor))
        drinkFat = String(Int(Float(drink.fat) * volumeFactor))
    }
    
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Serving", color: Color(.white))
                    
                    TextField("Serving Size", text: $servingSize)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .focused($isServingSizeFocused)
                        .onSubmit {
                            let newServingSize = Float(servingSize) ?? 1.0
                            drinkVolumeValue = String(Float(drink.volume.value) * newServingSize)
                            recalculateMacronutrients()
                        }
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
                        .focused($isVolumeValueFocused)
                        .onSubmit {
                            guard let volumeValue = Float(drinkVolumeValue), volumeValue != 0 else { return }
                            servingSize = String(format: "%.2f", volumeValue / Float(drink.volume.value))
                            recalculateMacronutrients()
                        }
                    
                    Text(selectedUnit)
                        .padding(8)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .opacity(0.70)
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $drinkProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                        .disabled(true)
                    
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
                    guard let flooredVolumeValue = Float(drinkVolumeValue) else { return }
                    addDrinkToDaily(
                        _id: drink.id,
                        name: drink.name,
                        servings: Float(servingSize) ?? 0,
                        volumeValue: Int(floor(flooredVolumeValue)),
                        volumeUnit: selectedUnit,
                        calories: Int(drinkCalories) ?? 0,
                        protein: Int(drinkProtein) ?? 0,
                        carbs: Int(drinkCarbs) ?? 0,
                        fats: Int(drinkFat) ?? 0
                    ) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                message = "Drink added to daily successfully!"
                            } else {
                                message = error ?? "Failed to add drink to daily."
                            }
                            showAlert = true
                        }
                    }
                    
                    // Update total values
                    totalCalories += Int(drinkCalories) ?? 0
                    totalProtein += Int(drinkProtein) ?? 0
                    totalCarbs += Int(drinkCarbs) ?? 0
                    totalFats += Int(drinkFat) ?? 0

                    // Update progress bars
                    updateProgress()

                    // Close the sheet
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add to user's goal")
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



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(username: "cratik")
    }
}
