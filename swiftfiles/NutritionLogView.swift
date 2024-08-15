import SwiftUI
import UserNotifications

struct NutritionLogView: View {
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var dailyRecord: DailyRecord?
    @State private var historicalRecords: [DailyRecord]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var needsRefresh = false
    @State private var searchText: String = "" // State to track the search query

    init(historicalRecords: [DailyRecord] = []) {
        self._historicalRecords = State(initialValue: historicalRecords)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()

                VStack {
                    // Search Bar
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(10)
                            .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Month and Year Picker
                    HStack {
                        // Your month and year picker code here
                    }
                    .padding(.bottom, 5)

                    // List of Entries
                    if isLoading {
                        ProgressView()
                            .foregroundColor(.white)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        List {
                            // Filtered current daily record
                            if let dailyRecord = dailyRecord, dailyRecordMatchesSearch(dailyRecord) {
                                NavigationLink(destination: DayDetailView(
                                    dailyRecord: dailyRecord,
                                    needsRefresh: $needsRefresh,
                                    isHistorical: false,
                                    onRefreshHistoricalRecords: fetchHistoricalRecords,
                                    onDismiss: {
                                        self.fetchDailyRecord()
                                    },
                                    onCompleteDay: { 
                                        self.fetchHistoricalRecords()
                                        self.fetchDailyRecord() // Reload the current record to reflect new state
                                    })) {
                                        VStack(alignment: .leading) {
                                            let formattedDate = formattedDate(from: dailyRecord.date)
                                            
                                            Text("\(formattedDate) (Today)")
                                                .font(.headline)
                                                .foregroundColor(.white.opacity(0.80))
                                        }
                                        .foregroundColor(Color.white.opacity(0.70))
                                        .padding(.vertical, 5)
                                    }
                                    .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                            }

                            // Filtered historical records
                            ForEach(filteredHistoricalRecords(), id: \.id) { record in
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
                
                if needsRefresh {
                    fetchHistoricalRecords()
                    fetchDailyRecord()
                    needsRefresh = false
                }
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
                    // Sort the records by date in descending order
                    self.historicalRecords = records.sorted(by: { $0.date > $1.date })
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

    // Function to filter historical records based on the search query
    func filteredHistoricalRecords() -> [DailyRecord] {
        if searchText.isEmpty {
            return historicalRecords
        } else {
            return historicalRecords.filter { record in
                formattedDate(from: record.date).lowercased().contains(searchText.lowercased())
            }
        }
    }

    // Function to check if daily record matches search query
    func dailyRecordMatchesSearch(_ record: DailyRecord) -> Bool {
        if searchText.isEmpty {
            return true
        } else {
            return formattedDate(from: record.date).lowercased().contains(searchText.lowercased())
        }
    }
}



struct DayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isInventorySelectionSheetPresented = false
    @State private var isManualWriteSheetPresented = false
    @State private var manualCalories = ""
    @State private var manualProtein = ""
    @State private var manualCarbs = ""
    @State private var manualFats = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var selectedGoal: SelectedGoal? = nil
    @State var dailyRecord: DailyRecord

    @Binding var needsRefresh: Bool
    @State private var resettingDaily: Bool = false
    var isHistorical: Bool
    var onRefreshHistoricalRecords: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onCompleteDay: (() -> Void)?

    @State private var showDayConfirmationAlert = false
    @State private var currentAction: ActionType? = nil

    enum ActionType {
        case completeDay
        case deleteDay
    }

    @State private var foods: [DailyFood] = []
    @State private var drinks: [DailyDrink] = []
    @State private var manuals: [DailyManual] = []
    
    @State private var totalCalories: Int = 0
    @State private var totalProtein: Int = 0
    @State private var totalCarbs: Int = 0
    @State private var totalFats: Int = 0

    init(dailyRecord: DailyRecord, needsRefresh: Binding<Bool>, isHistorical: Bool, onRefreshHistoricalRecords: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onCompleteDay: (() -> Void)? = nil) {
        self._dailyRecord = State(initialValue: dailyRecord)
        self._foods = State(initialValue: dailyRecord.foods)
        self._drinks = State(initialValue: dailyRecord.drinks)
        self._manuals = State(initialValue: dailyRecord.manuals)
        self._needsRefresh = needsRefresh
        self.isHistorical = isHistorical
        self.onRefreshHistoricalRecords = onRefreshHistoricalRecords
        self.onDismiss = onDismiss
        self.onCompleteDay = onCompleteDay
    }

    var body: some View {
        let formattedDate = formattedDate(from: dailyRecord.date)
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()

                VStack {
                    if !isHistorical {
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                            GridRow {
                                if let goal = selectedGoal {
                                    NutrientView(nutrient: "Calories", curValue: Int(dailyRecord.calories), goalValue: goal.calorieGoal, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                                    NutrientView(nutrient: "Protein", curValue: Int(dailyRecord.protein), goalValue: goal.proteinGoal, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                                }
                            }
                            if let goal = selectedGoal {
                                if goal.carbGoal != 0 || goal.fatGoal != 0 {
                                    GridRow {
                                        if goal.carbGoal != 0 {
                                            NutrientView(nutrient: "Carbs", curValue: Int(dailyRecord.carbs), goalValue: goal.carbGoal, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                                        }
                                        if goal.fatGoal != 0 {
                                            NutrientView(nutrient: "Fat", curValue: Int(dailyRecord.fat), goalValue: goal.fatGoal, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        if selectedGoal == nil {
                            Text("[No goal selected]")
                                .foregroundColor(.red)
                        }

                    } else {
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                            GridRow {
                                if let goal = dailyRecord.goal {
                                    NutrientView(nutrient: "Calories", curValue: Int(dailyRecord.calories), goalValue: goal.calorieGoal, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                                    NutrientView(nutrient: "Protein", curValue: Int(dailyRecord.protein), goalValue: goal.proteinGoal, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                                }
                            }
                            if let goal = dailyRecord.goal {
                                if goal.carbGoal != 0 || goal.fatGoal != 0 {
                                    GridRow {
                                        if goal.carbGoal != 0 {
                                            NutrientView(nutrient: "Carbs", curValue: Int(dailyRecord.carbs), goalValue: goal.carbGoal, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                                        }
                                        if goal.fatGoal != 0 {
                                            NutrientView(nutrient: "Fat", curValue: Int(dailyRecord.fat), goalValue: goal.fatGoal, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        if dailyRecord.goal == nil {
                            Text("[No goal selected]")
                                .foregroundColor(.red)
                        }
                    }

                    List {
                        ForEach(foods, id: \.id) { food in
                            NavigationLink(destination: FoodDetailView(food: food, recordId: dailyRecord.id, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
                                self.needsRefresh = true
                                self.fetchUpdatedRecord() // Immediately refresh after deletion
                            }, isHistorical: isHistorical)) {
                                Text(food.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }

                        ForEach(drinks, id: \.id) { drink in
                            NavigationLink(destination: DrinkDetailView(drink: drink, recordId: dailyRecord.id, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
                                self.needsRefresh = true
                                self.fetchUpdatedRecord()
                            }, isHistorical: isHistorical)) {
                                Text(drink.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }

                        ForEach(manuals, id: \.id) { manual in
                            NavigationLink(destination: ManualDetailView(manual: manual, recordId: dailyRecord.id, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
                                self.needsRefresh = true
                                self.fetchUpdatedRecord()
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

                if !isHistorical {
                    VStack {
                        Spacer()

                        Button (action: {
                            currentAction = .completeDay
                            showDayConfirmationAlert = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 20/255, green: 20/255, blue: 30/255))
                                    .frame(width: 162, height: 45)

                                HStack {
                                    Text("Complete Day")
                                        .font(.system(size: 16))
                                        .bold()

                                    Image(systemName: "checkmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .foregroundColor(.white.opacity(0.50))
                            }
                        }
                    }
                } else {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    currentAction = .deleteDay
                                    showDayConfirmationAlert = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color(red: 61/255, green: 2/255, blue: 9/255))
                                            .frame(width: 50, height: 50) // Size of the circle
                                            .opacity(0.70)
                                        
                                        Image(systemName: "trash")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25) // Size of the icon
                                            .foregroundColor(.white.opacity(0.50))
                                    }
                                    .shadow(radius: 5) // Add some shadow for better visibility
                                }
                                .padding(.leading, 20) // Add padding to position it away from the edges
                                .padding(.bottom, -12)
                                
                                Spacer()
                                
                                Button(action: {
                                    isManualWriteSheetPresented.toggle()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color(red: 20/255, green: 20/255, blue: 30/255))
                                            .frame(width: 46, height: 46)
                                        
                                        VStack {
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 23, height: 23)
                                        }
                                        .foregroundColor(.white.opacity(0.70))
                                    }
                                    .shadow(radius: 5) // Add some shadow for better visibility
                                    .padding(.leading, 20) // Add padding to position it away from the edges
                                    .padding(.trailing, 10)
                                    .padding(.bottom, -12)
                                }
                                .sheet(isPresented: $isManualWriteSheetPresented, onDismiss: {
                                    fetchUpdatedRecord()
                                }) {
                                    if let historicalGoal = dailyRecord.goal {
                                        let convertedGoal = historicalGoal.toSelectedGoal(
                                            withId: dailyRecord.id,
                                            name: "Historical Goal"
                                        )
                                        ManualWriteSheetArchived(
                                            manualCalories: $manualCalories,
                                            manualProtein: $manualProtein,
                                            manualCarbs: $manualCarbs,
                                            manualFats: $manualFats,
                                            selectedGoal: convertedGoal,
                                            recordId: dailyRecord.id
                                        )
                                    }
                                }
                                
                                Button(action: {
                                    isInventorySelectionSheetPresented.toggle()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color(red: 20/255, green: 20/255, blue: 30/255))
                                            .frame(width: 46, height: 46)
                                        
                                        VStack {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 23, height: 23)
                                        }
                                        .foregroundColor(.white.opacity(0.70))
                                    }
                                    .shadow(radius: 5) // Add some shadow for better visibility
                                    .padding(.trailing, 20) // Add padding to position it away from the edges
                                    .padding(.bottom, -12)
                                }
                                .sheet(isPresented: $isInventorySelectionSheetPresented, onDismiss: {
                                    fetchUpdatedRecord()
                                }) {
                                    if let historicalGoal = dailyRecord.goal {
                                        let convertedGoal = historicalGoal.toSelectedGoal(
                                            withId: dailyRecord.id,
                                            name: "Historical Goal"
                                        )
                                        InventorySelectionSheetArchived(
                                            selectedGoal: convertedGoal,
                                            recordId: dailyRecord.id
                                        )
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .navigationTitle("\(formattedDate)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchUserSelectedGoal()
                
                if needsRefresh {
                    fetchUpdatedRecord() // Ensure this is called to refresh the record data
                    if !isHistorical {
                        fetchDailyRecord()
                    }
                    needsRefresh = false
                }
            }
            .onDisappear {
                if !isHistorical && resettingDaily {
                    onRefreshHistoricalRecords?()
                    onDismiss?()
                }
            }
            .alert(isPresented: $showDayConfirmationAlert) {
                switch currentAction {
                case .completeDay:
                    return Alert(
                        title: Text("Complete Day"),
                        message: Text("Are you sure you want to complete \(formattedDate)?"),
                        primaryButton: .destructive(Text("Yes")) {
                            resettingDaily = true
                            completeDailyRecord()
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                case .deleteDay:
                    return Alert(
                        title: Text("Delete Day"),
                        message: Text("Are you sure you want to delete \(formattedDate)?"),
                        primaryButton: .destructive(Text("Yes")) {
                            deleteArchived()
                        },
                        secondaryButton: .cancel()
                    )
                case .none:
                    return Alert(title: Text("Error"), message: Text("Unknown action"))
                }
            }
        }
    }

    func selectedGoalForRecord(isHistorical: Bool) -> SelectedGoal? {
        if isHistorical {
            if let goal = dailyRecord.goal {
                return SelectedGoal(
                    id: dailyRecord.id,
                    name: "Historical Goal",
                    calorieGoal: goal.calorieGoal,
                    proteinGoal: goal.proteinGoal,
                    carbGoal: goal.carbGoal,
                    fatGoal: goal.fatGoal
                )
            } else {
                return nil
            }
        } else {
            return selectedGoal
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
                    if let record = record {
                        self.dailyRecord = record
                        self.foods = record.foods
                        self.drinks = record.drinks
                        self.manuals = record.manuals
                    } else {
                        self.foods = []
                        self.drinks = []
                        self.manuals = []
                    }
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
                if (error as NSError).code == 404 {
                    DispatchQueue.main.async {
                        self.selectedGoal = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func completeDailyRecord() {
        completeDay { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Refresh both daily and historical records after completing the day
                    onCompleteDay?()
                    onRefreshHistoricalRecords?()
                    onDismiss?()
                case .failure(let error):
                    print("Failed to complete day: \(error.localizedDescription)")
                }
            }
        }
    }


    func deleteArchived() {
        deleteArchivedRecord(date: dailyRecord.date) { success, message in
            DispatchQueue.main.async {
                if success {
                    print("Archived record deleted successfully")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Failed to delete archived record: \(message ?? "Unknown error")")
                }
            }
        }
    }
    
    // New function to fetch the updated record
    private func fetchUpdatedRecord() {
        fetchHistoricalRecord(id: dailyRecord.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedRecord):
                    self.dailyRecord = updatedRecord
                    self.foods = updatedRecord.foods
                    self.drinks = updatedRecord.drinks
                    self.manuals = updatedRecord.manuals
                case .failure(let error):
                    self.errorMessage = "Failed to refresh record: \(error.localizedDescription)"
                }
            }
        }
    }
}


struct InventorySelectionSheetArchived: View {
    @State private var selectedItem: Item = .Food
    @State private var foods: [Food] = []
    @State private var drinks: [Drink] = []
    
    // Search Bar State
    @State private var searchText: String = ""
    
    @State private var isFoodInputSheetPresented = false
    @State private var isDrinkInputSheetPresented = false
    @State private var selectedFood: Food? = nil
    @State private var selectedDrink: Drink? = nil
    
    var selectedGoal: SelectedGoal? // Add this line
    
    @State private var dailyRecord: DailyRecord? // Add state to hold the updated record
    var recordId: String // Accept record ID
    
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
                    .padding(.bottom, -10)
                    
                    // Search Bar
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(10)
                            .background(Color(red: 20/255, green: 20/255, blue: 30/255))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 44/255, green: 44/255, blue: 53/255), lineWidth: 2) // Set the border color and width
                                    .padding(.horizontal)
                            )
                    }
                    .padding(.bottom, 5)
                    
                    List {
                        if selectedItem == .Food {
                            ForEach(filteredFoods(), id: \.id) { food in
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
                            ForEach(filteredDrinks(), id: \.id) { drink in
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
                                    FoodInputSheetArchived(
                                        food: bindingFood(for: selectedFood),
                                        selectedGoal: selectedGoal,
                                        recordId: recordId
                                    )
                                }
                            case .Drink:
                                if let selectedDrink = selectedDrink {
                                    DrinkInputSheetArchived(
                                        drink: bindingDrink(for: selectedDrink),
                                        selectedGoal: selectedGoal,
                                        recordId: recordId
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
                self.foods = foods.sorted(by: { $0.id > $1.id })
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
                self.drinks = drinks.sorted(by: { $0.id > $1.id })
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
    
    // Filtering functions
    private func filteredFoods() -> [Food] {
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func filteredDrinks() -> [Drink] {
        if searchText.isEmpty {
            return drinks
        } else {
            return drinks.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}



// For User to input Food Item Consumption in Archived Records
struct FoodInputSheetArchived: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var food: Food

    var selectedGoal: SelectedGoal?
    var recordId: String // Identify the archived record
    
    @State private var selectedUnit: String
    @State private var servingSize: String
    @State private var foodName: String
    @State private var foodWeightValue: String
    @State private var foodCalories: String
    @State private var foodProtein: String
    @State private var foodCarbs: String
    @State private var foodFat: String

    @FocusState private var isServingSizeFocused: Bool
    @FocusState private var isWeightValueFocused: Bool
    
    @State private var eitherAlert = false
    
    @State private var message = ""
    @State private var showAlert = false
    
    @State private var errorMessage = ""
    @State private var showErrorAlert = false

    init(food: Binding<Food>, selectedGoal: SelectedGoal?, recordId: String) {
        _food = food
        self.selectedGoal = selectedGoal
        self.recordId = recordId
        
        _selectedUnit = State(initialValue: food.wrappedValue.weight.unit.rawValue)
        _servingSize = State(initialValue: String(format: "%.2f", 1.0))
        _foodName = State(initialValue: food.wrappedValue.name)
        _foodWeightValue = State(initialValue: String(food.wrappedValue.weight.value))
        _foodCalories = State(initialValue: String(food.wrappedValue.calories))
        _foodProtein = State(initialValue: String(food.wrappedValue.protein))
        _foodCarbs = State(initialValue: food.wrappedValue.carbs != nil ? String(food.wrappedValue.carbs!) : "")
        _foodFat = State(initialValue: food.wrappedValue.fat != nil ? String(food.wrappedValue.fat!) : "")
    }
    
    func recalculateMacronutrients() {
        guard let foodWeightValue = Float(foodWeightValue) else { return }
        
        let weightFactor = foodWeightValue / Float(food.weight.value)
        foodCalories = String(Int(Float(food.calories) * weightFactor))
        foodProtein = String(Int(Float(food.protein) * weightFactor))
        foodCarbs = String(Int(Float(food.carbs ?? 0) * weightFactor))
        foodFat = String(Int(Float(food.fat ?? 0) * weightFactor))
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
                
                if selectedGoal?.carbGoal != 0 {
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        
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
                }
                
                Button(action: {
                    if (selectedGoal?.carbGoal != 0 && foodCarbs.isEmpty) || selectedGoal?.fatGoal != 0 && foodFat.isEmpty {
                        var missingMacros: [String] = []
                        if selectedGoal?.carbGoal != 0 && foodCarbs.isEmpty {
                            missingMacros.append("carbs")
                        }
                        
                        if selectedGoal?.fatGoal != 0 && foodFat.isEmpty {
                            missingMacros.append("fat")
                        }
                        
                        message = "The current food is missing: \(missingMacros.joined(separator: ", ")). Please update these values in your inventory before adding."
                        eitherAlert = true
                        showErrorAlert = true
                    } else {
                        guard let flooredWeightValue = Float(foodWeightValue) else { return }
                        addFoodToArchivedRecord(
                            recordId: recordId,
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
                                    message = ""
                                } else {
                                    message = error ?? "Failed to add food to archived."
                                }
                                eitherAlert = true
                                showAlert = true
                            }
                        }
                    }
                }) {
                    Text("Add to Archived Record")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                .alert(isPresented: $eitherAlert) {
                    Alert(
                        title: Text(showErrorAlert ? "Missing Values" : "Food Added Successfully!"),
                        message: Text(message),
                        dismissButton: .default(Text("OK")) {
                            if !showErrorAlert {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}



struct DrinkInputSheetArchived: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var drink: Drink

    var selectedGoal: SelectedGoal?
    var recordId: String // Identify Archived Record
    
    @State private var selectedUnit: String
    @State private var servingSize: String
    @State private var drinkName: String
    @State private var drinkVolumeValue: String
    @State private var drinkCalories: String
    @State private var drinkProtein: String
    @State private var drinkCarbs: String
    @State private var drinkFat: String
    
    @FocusState private var isServingSizeFocused: Bool
    @FocusState private var isVolumeValueFocused: Bool
    
    @State private var eitherAlert = false
    
    @State private var message = ""
    @State private var showAlert = false

    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    init(drink: Binding<Drink>, selectedGoal: SelectedGoal?, recordId: String) {
        _drink = drink
        self.selectedGoal = selectedGoal
        self.recordId = recordId
        
        _selectedUnit = State(initialValue: drink.wrappedValue.volume.unit.rawValue)
        _servingSize = State(initialValue: String(format: "%.2f", 1.0))
        _drinkName = State(initialValue: drink.wrappedValue.name)
        _drinkVolumeValue = State(initialValue: String(drink.wrappedValue.volume.value))
        _drinkCalories = State(initialValue: String(drink.wrappedValue.calories))
        _drinkProtein = State(initialValue: String(drink.wrappedValue.protein))
        _drinkCarbs = State(initialValue: drink.wrappedValue.carbs != nil ? String(drink.wrappedValue.carbs!) : "")
        _drinkFat = State(initialValue: drink.wrappedValue.fat != nil ? String(drink.wrappedValue.fat!) : "")
    }
    
    func recalculateMacronutrients() {
        guard let drinkVolumeValue = Float(drinkVolumeValue) else { return }
        
        let volumeFactor = drinkVolumeValue / Float(drink.volume.value)
        drinkCalories = String(Int(Float(drink.calories) * volumeFactor))
        drinkProtein = String(Int(Float(drink.protein) * volumeFactor))
        drinkCarbs = String(Int(Float(drink.carbs ?? 0) * volumeFactor))
        drinkFat = String(Int(Float(drink.fat ?? 0) * volumeFactor))
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
                
                if selectedGoal?.carbGoal != 0 {
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        
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
                }
                
                Button(action: {
                    if (selectedGoal?.carbGoal != 0 && drinkCarbs.isEmpty) || (selectedGoal?.fatGoal != 0 && drinkFat.isEmpty) {
                        var missingMacros: [String] = []
                        if selectedGoal?.carbGoal != 0 && drinkCarbs.isEmpty {
                            missingMacros.append("carbs")
                        }
                        if selectedGoal?.fatGoal != 0 && drinkFat.isEmpty {
                            missingMacros.append("fats")
                        }
                        message = "The current drink is missing: \(missingMacros.joined(separator: ", ")). Please update these values in your inventory before adding."
                        eitherAlert = true
                        showErrorAlert = true
                    } else {
                        guard let flooredVolumeValue = Float(drinkVolumeValue) else { return }
                        addDrinkToArchivedRecord(
                            recordId: recordId,
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
                                    message = ""
                                } else {
                                    message = error ?? "Failed to add drink to archived record."
                                }
                                eitherAlert = true
                                showAlert = true
                            }
                        }
                    }
                }) {
                    Text("Add to Archived Record")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                .alert(isPresented: $eitherAlert) {
                    Alert(
                        title: Text(showErrorAlert ? "Missing Values" : "Drink Added Successfully!"),
                        message: Text(message),
                        dismissButton: .default(Text("OK")) {
                            if !showErrorAlert {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}


// ManualWriteSheet when click PENCIL ICON
struct ManualWriteSheetArchived: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var manualCalories: String
    @Binding var manualProtein: String
    @Binding var manualCarbs: String
    @Binding var manualFats: String

    @State private var message = ""
    @State private var showAlert = false

    var selectedGoal: SelectedGoal?
    var recordId: String // Identify Archived Record

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

                if selectedGoal?.carbGoal != 0 {
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        
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
                }

                Button(action: {
                    // Convert input values from String to Int
                    let calories = Int(manualCalories) ?? 0
                    let protein = Int(manualProtein) ?? 0
                    let carbs = Int(manualCarbs) ?? 0
                    let fats = Int(manualFats) ?? 0

                    // Call the addManualToDaily function
                    addManualToArchivedRecord(
                        recordId: recordId,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fats: fats
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

                    // Clear the text fields
                    manualCalories = ""
                    manualProtein = ""
                    manualCarbs = ""
                    manualFats = ""
                }) {
                    Text("Add to ArchivedRecord")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("ManualEntry Added Successfully!"),
                        dismissButton: .default(Text("OK")) {
                            // Dismiss the view only if it's a success alert
                            presentationMode.wrappedValue.dismiss()
                            
                        }
                    )
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}


struct FoodDetailView: View {
    var food: DailyFood
    var recordId: String // Accept record ID
    
    var selectedGoal: SelectedGoal?
    
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter

    @State private var dailyRecord: DailyRecord? // Add state to hold the updated record

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
                
                if selectedGoal?.carbGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                        
                        Text("\(food.carbs ?? 0)")
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        
                        Text("\(food.fat ?? 0)")
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
                }
                
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
                                // Call the onDelete closure
                                onDelete()
                            case .failure(let error):
                                print("Failed to delete food item: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete food item: \(error.localizedDescription)"
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
                } else {
                    Button(action: {
                        deleteFoodFromArchived(recordId: recordId, foodInputId: food.id) { result in
                            switch result {
                            case .success:
                                print("Food item deleted from archived!")
                                
                                // Set alert message
                                alertMessage = "Deleted \(food.name)"
                                // Show the alert
                                showAlert = true
                                
                                // Notify the parent view to refresh
                                onDelete()
                                
                            case .failure(let error):
                                print("Failed to delete food item: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete food item: \(error.localizedDescription)"
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
                        if !isHistorical {
                            onDelete()
                        }
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
    var recordId: String // Accept record ID
    
    var selectedGoal: SelectedGoal?
    
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter
    
    @State private var dailyRecord: DailyRecord? // Add state to hold the updated record
    
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
                
                if selectedGoal?.carbGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                        
                        Text("\(drink.carbs ?? 0)")
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        
                        Text("\(drink.fat ?? 0)")
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
                }
                
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
                                
                                onDelete()
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
                } else {
                    Button(action: {
                        deleteDrinkFromArchived(recordId: recordId, drinkInputId: drink.id) { result in
                            switch result {
                            case .success:
                                print("Drink item deleted from archived!")
                                
                                // Set alert message
                                alertMessage = "Deleted \(drink.name)"
                                // Show the alert
                                showAlert = true
                                
                                // Notify the parent view to refresh
                                onDelete()
                                
                            case .failure(let error):
                                print("Failed to delete food item: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete drink item: \(error.localizedDescription)"
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
    var recordId: String // Accept record ID
    
    var selectedGoal: SelectedGoal?
    
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    var isHistorical: Bool // New parameter
    
    @State private var dailyRecord: DailyRecord? // Add state to hold the updated record
    
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
                
                if selectedGoal?.carbGoal != 0 {
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
                }
                
                if selectedGoal?.fatGoal != 0 {
                    HStack {
                        MacroDisplayVertical(nutrient: "Fat", color: Color(.white))
                        
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
                }
                
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
                } else {
                    // Delete Item Button
                    Button(action: {
                        deleteManualFromArchived(recordId: recordId, manualInputId: manual.id) { result in
                            switch result {
                            case .success:
                                print("Drink item deleted from archived!")
                                
                                // Set alert message
                                alertMessage = "Deleted Manual Entry"
                                // Show the alert
                                showAlert = true
                                
                                // Notify the parent view to refresh
                                onDelete()
                                
                            case .failure(let error):
                                print("Failed to delete manual entry: \(error)")
                                // Set alert message
                                alertMessage = "Failed to delete manual entry: \(error.localizedDescription)"
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
