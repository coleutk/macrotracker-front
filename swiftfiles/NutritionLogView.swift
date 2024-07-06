import SwiftUI

struct NutritionLogView: View {
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var dailyRecord: DailyRecord?
    @State private var historicalRecords: [DailyRecord]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var needsRefresh = false
    
    init(historicalRecords: [DailyRecord] = []) {
        self._historicalRecords = State(initialValue: historicalRecords)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()
                
                VStack {
                    // Month and Year Picker
                    HStack {
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(DateFormatter().monthSymbols[month - 1])
                                    .tag(month)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .cornerRadius(10)
                        
                        Picker("Year", selection: $selectedYear) {
                            ForEach(2020...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .cornerRadius(10)
                    }
                    .padding()
                    // .onChange(of: selectedMonth) { _ in fetchDailyRecord() }
                    // .onChange(of: selectedYear) { _ in fetchDailyRecord() }
                    
                    // List of Entries
                    if isLoading {
                        ProgressView()
                            .foregroundColor(.white)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        List {
                            // Current Daily Record
                            if let dailyRecord = dailyRecord {
                                NavigationLink(destination: DayDetailView(dailyRecord: dailyRecord, needsRefresh: $needsRefresh, isHistorical: false)) {
                                    VStack(alignment: .leading) {
                                        let formattedDate = formattedDate(from: dailyRecord.date)
                                        Text("Today: \(formattedDate)")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.80))
                                    }
                                    .foregroundColor(Color.white.opacity(0.70))
                                    .padding(.vertical, 5)
                                }
                                .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                            }
                            
                            // Historical Records
                            ForEach(historicalRecords, id: \.id) { record in
                                NavigationLink(destination: DayDetailView(dailyRecord: record, needsRefresh: $needsRefresh, isHistorical: true)) {
                                    VStack(alignment: .leading) {
                                        let formattedDate = formattedDate(from: record.date)
                                        Text(formattedDate)
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.80))
                                    }
                                    .foregroundColor(Color.white.opacity(0.70))
                                    .padding(.vertical, 5)
                                }
                                .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .navigationTitle("Nutrition Log")
                        .foregroundColor(.white)
                    }
                }
                .foregroundColor(.white)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                fetchDailyRecord()
                fetchHistoricalRecords()
            }
        }
    }
    
    // Function to fetch current daily record
    func fetchDailyRecord() {
        isLoading = true
        errorMessage = nil
        
        getCurrentDaily { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let record):
                    self.dailyRecord = record
                case .failure(let error):
                    self.errorMessage = "Failed to fetch daily record: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Function to fetch historical records
    func fetchHistoricalRecords() {
        isLoading = true
        errorMessage = nil
        
        getAllHistoricalRecords { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let records):
                    self.historicalRecords = records
                case .failure(let error):
                    self.errorMessage = "Failed to fetch historical records: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Function to format date string
    func formattedDate(from dateString: String) -> String {
        let year = dateString.prefix(4)
        let month = dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)]
        let day = dateString[dateString.index(dateString.startIndex, offsetBy: 8)..<dateString.index(dateString.startIndex, offsetBy: 10)]
        
        let monthName = DateFormatter().monthSymbols[Int(month)! - 1]
        
        return "\(monthName) \(day), \(year)"
    }
}



struct DayDetailView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var selectedGoal: SelectedGoal? = nil
    @State var dailyRecord: DailyRecord
    @Binding var needsRefresh: Bool
    var isHistorical: Bool // New parameter
    
    @State private var foods: [DailyFood] = []
    @State private var drinks: [DailyDrink] = []
    @State private var manuals: [DailyManual] = []
    
    init(dailyRecord: DailyRecord, needsRefresh: Binding<Bool>, isHistorical: Bool) {
        self._dailyRecord = State(initialValue: dailyRecord)
        self._foods = State(initialValue: dailyRecord.foods)
        self._drinks = State(initialValue: dailyRecord.drinks)
        self._manuals = State(initialValue: dailyRecord.manuals)
        self._needsRefresh = needsRefresh
        self.isHistorical = isHistorical // Initialize new parameter
    }
    
//    let goalCalories: Int = 2300
//    let goalProtein: Int = 160
//    let goalCarbs: Int = 250
//    let goalFats: Int = 70
    
    var body: some View {
        let formattedDate = formattedDate(from: dailyRecord.date)
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()
                
                VStack {
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                        GridRow {
                            if let goal = selectedGoal {
                                NutrientView(nutrient: "Calories", curValue: Int(dailyRecord.calories), goalValue: goal.calorieGoal, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                                NutrientView(nutrient: "Protein", curValue: Int(dailyRecord.protein), goalValue: goal.proteinGoal, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                            }
                        }
                        GridRow {
                            if let goal = selectedGoal {
                                NutrientView(nutrient: "Carbs", curValue: Int(dailyRecord.carbs), goalValue: goal.carbGoal, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                                NutrientView(nutrient: "Fat", curValue: Int(dailyRecord.fat), goalValue: goal.fatGoal, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    List {
                        ForEach(foods, id: \.id) { food in
                            NavigationLink(destination: FoodDetailView(food: food, onDelete: {
                                self.foods.removeAll { $0.id == food.id }
                                self.needsRefresh = true
                            }, isHistorical: isHistorical)) {
                                Text(food.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                        
                        ForEach(drinks, id: \.id) { drink in
                            NavigationLink(destination: DrinkDetailView(drink: drink, onDelete: {
                                self.drinks.removeAll { $0.id == drink.id }
                                self.needsRefresh = true
                            }, isHistorical: isHistorical)) {
                                Text(drink.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                        
                        ForEach(manuals, id: \.id) { manual in
                            NavigationLink(destination: ManualDetailView(manual: manual, onDelete: {
                                self.manuals.removeAll { $0.id == manual.id }
                                self.needsRefresh = true
                            }, isHistorical: isHistorical)) {
                                Text("Manual Entry")
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                }
                .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                .foregroundColor(.white)
            }
            .navigationTitle("\(formattedDate)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchUserSelectedGoal()
                
                if needsRefresh {
                    fetchDailyRecord()
                    needsRefresh = false
                }
            }
        }
    }
    
    func formattedDate(from dateString: String) -> String {
        let year = dateString.prefix(4)
        let month = dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)]
        let day = dateString[dateString.index(dateString.startIndex, offsetBy: 8)..<dateString.index(dateString.startIndex, offsetBy: 10)]
        
        let monthName = DateFormatter().monthSymbols[Int(month)! - 1]
        
        return "\(monthName) \(day), \(year)"
    }
    
    func fetchDailyRecord() {
        isLoading = true
        errorMessage = nil
        
        getCurrentDaily { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let record):
                    self.dailyRecord = record
                    self.foods = record.foods
                    self.drinks = record.drinks
                    self.manuals = record.manuals
                case .failure(let error):
                    self.errorMessage = "Failed to fetch daily record: \(error.localizedDescription)"
                }
            }
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
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}



struct FoodDetailView: View {
    var food: DailyFood
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter


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
                    
                    Text("\(food.name)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Serving", color: Color(.white))
                    
                    Text("\(food.servings, specifier: "%.2f")")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Weight", color: Color(.white))
                    
                    Text("\(food.weight.value)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("\(food.weight.unit)")
                        .padding(8)
                        .frame(width: 80, height: 60)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    Text("\(food.calories)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    Text("\(food.protein)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                    
                    Text("\(food.carbs)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                    
                    Text("\(food.fat)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                
                if !isHistorical {
                    // Delete Item Button
                    Button(action: {
                        deleteFoodInput(food) { result in
                            switch result {
                            case .success:
                                print("Food item deleted!")
                                // Set alert message
                                alertMessage = "Deleted \(food.name)"
                                // Show the alert
                                showAlert = true
                            case .failure(let error):
                                print("Failed to delete food item: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete food item"
                                // Show the alert
                                showAlert = true
                            }
                        }
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
            }
            .foregroundColor(.white.opacity(0.70))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Notify the parent view of the deletion
                        onDelete()
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}


struct DrinkDetailView: View {
    var drink: DailyDrink
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack{
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    Text("\(drink.name)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Serving", color: Color(.white))
                    
                    Text("\(drink.servings, specifier: "%.2f")")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Volume", color: Color(.white))
                    
                    Text("\(drink.volume.value)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("\(drink.volume.unit)")
                        .padding(8)
                        .frame(width: 80, height: 60)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    Text("\(drink.calories)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    Text("\(drink.protein)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                    
                    Text("\(drink.carbs)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                    
                    Text("\(drink.fat)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
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
                
                // Delete Item Button
                if !isHistorical {
                    Button(action: {
                        deleteDrinkInput(drink) { result in
                            switch result {
                            case .success:
                                print("Drink item deleted!")
                                // Set alert message
                                alertMessage = "Deleted \(drink.name)"
                                // Show the alert
                                showAlert = true
                            case .failure(let error):
                                print("Failed to delete drink item: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete drink item"
                                // Show the alert
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Delete \(drink.name)")
                            .foregroundColor(.white.opacity(0.70))
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.50))
                            .cornerRadius(15)
                            .padding(.horizontal, 22)
                            .padding(.top, 20)
                    }
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Notify the parent view of the deletion
                        onDelete()
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}



struct ManualDetailView: View {
    var manual: DailyManual
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack{
                Text("Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Calories", color: Color(.white))
                    
                    Text("\(manual.calories)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(.white))
                    
                    Text("\(manual.protein)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(.white))
                    
                    Text("\(manual.carbs)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fats", color: Color(.white))
                    
                    Text("\(manual.fat)")
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.70)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                if !isHistorical {
                    // Delete Item Button
                    Button(action: {
                        deleteManualInput(manual) { result in
                            switch result {
                            case .success:
                                print("Manual entry deleted!")
                                // Set alert message
                                alertMessage = "Deleted manual entry"
                                // Show the alert
                                showAlert = true
                            case .failure(let error):
                                print("Failed to delete manual entry: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete manual entry"
                                // Show the alert
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Delete Manual Entry")
                            .foregroundColor(.white.opacity(0.70))
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.50))
                            .cornerRadius(15)
                            .padding(.horizontal, 22)
                            .padding(.top, 20)
                    }
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Notify the parent view of the deletion
                        onDelete()
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}


struct NutritionLogView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionLogView()
    }
}
