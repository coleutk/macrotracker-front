import SwiftUI

struct HomeView: View {
    var username: String
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

    @State private var totalCalories: Float = 0.0
    @State private var totalProtein: Float = 0.0
    @State private var totalCarbs: Float = 0.0
    @State private var totalFats: Float = 0.0

    let goalCalories: Float = 2300.0
    let goalProtein: Float = 160.0
    let goalCarbs: Float = 250.0
    let goalFats: Float = 70.0

    func updateProgress() {
        calorieProgress = totalCalories / goalCalories
        proteinProgress = totalProtein / goalProtein
        carbProgress = totalCarbs / goalCarbs
        fatProgress = totalFats / goalFats
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
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                                    .frame(width: 300, height: 50)
                                
                                VStack {
                                    Text("\(username)'s GOAL 1")
                                        .aspectRatio(contentMode: .fit)
                                        .font(.largeTitle)
                                        .bold()
                                }
                                .foregroundColor(.white.opacity(0.70))
                            }
                        }
                        .buttonStyle(MyButtonStyle())
                        .padding(.horizontal, 10)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                            GridRow {
                                NutrientView(nutrient: "Calories", curValue: totalCalories, goalValue: goalCalories, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                                NutrientView(nutrient: "Protein", curValue: totalProtein, goalValue: goalProtein, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                            }
                            GridRow {
                                NutrientView(nutrient: "Carbs", curValue: totalCarbs, goalValue: goalCarbs, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                                NutrientView(nutrient: "Fat", curValue: totalFats, goalValue: goalFats, color: Color(red: 171/255, green: 169/255, blue: 195/255))
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
                            .sheet(isPresented: $isManualWriteSheetPresented) {
                                ManualWriteSheet(manualCalories: $manualCalories, manualProtein: $manualProtein, manualCarbs: $manualCarbs, manualFats: $manualFats, isSheetPresented: $isManualWriteSheetPresented, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFats: $totalFats, updateProgress: updateProgress)
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
                            .sheet(isPresented: $isInventorySelectionSheetPresented) {
                                InventorySelectionSheet()
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
}


struct NutrientView: View {
    var nutrient: String
    var curValue: Float
    var goalValue: Float
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

            Text("\(String(format: "%.0f", curValue))\(nutrient == "Calories" ? "" : "g") / \(String(format: "%.0f", floor(goalValue)))\(nutrient == "Calories" ? "" : "g")")
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
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
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

    @Binding var totalCalories: Float
    @Binding var totalProtein: Float
    @Binding var totalCarbs: Float
    @Binding var totalFats: Float

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

                TextField("Calories", text: $manualCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)

                HStack {
                    TextField("Protein", text: $manualProtein)
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
                    TextField("Carbs", text: $manualCarbs)
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
                    TextField("Fats", text: $manualFats)
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
                    // Add manually entered values to total values
                    totalCalories += Float(manualCalories) ?? 0.0
                    totalProtein += Float(manualProtein) ?? 0.0
                    totalCarbs += Float(manualCarbs) ?? 0.0
                    totalFats += Float(manualFats) ?? 0.0

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
                                    FoodInputSheet(food: bindingFood(for: selectedFood))
                                }
                            case .Drink:
                                if let selectedDrink = selectedDrink {
                                    // BlueSheetView(drink: bindingDrink(for: selectedDrink))
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


struct FoodInputSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var food: Food
    
    @State private var selectedUnit: String
    @State private var servingSize: String
    
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
        _servingSize = State(initialValue: "1")
        
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
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Servings Size", text: $servingSize)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                HStack {
                    TextField("Weight Value", text: $foodWeightValue)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("g").tag("g")
                        Text("kg").tag("kg")
                        Text("mg").tag("mg")
                        Text("oz").tag("oz")
                        Text("lb").tag("lb")
                    }
                    .padding(8)
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 90)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.leading, -20)
                    .padding(.trailing, 22)
                }
                
                TextField("Calories", text: $foodCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                HStack {
                    TextField("Protein", text: $foodProtein)
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
                    // Add your logic to save the food item
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
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
