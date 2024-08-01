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

    // For Locked Timer
    @State private var timeRemaining: Int = UserDefaults.standard.integer(forKey: "timeRemaining") // Retrieve from UserDefaults
    @State private var timer: Timer?

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
                                if dailyRecord.locked ?? false {
                                    VStack(alignment: .leading) {
                                        let formattedDate = formattedDate(from: dailyRecord.date)
                                        Text("\(formattedDate) (Tomorrow)")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.80))
                                            .padding(.bottom, -2)
                                        HStack {
                                            if timeRemaining > 0 {
                                                Text("Locked [\(formatTime(timeRemaining))]")
                                                    .font(.subheadline)
                                                    .foregroundColor(.red.opacity(0.80))
                                                    .padding(.trailing, -5)
                                                
                                                Image(systemName: "lock")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 13, height: 13)
                                                    .foregroundColor(.red.opacity(0.80))
                                            }
                                        }
                                        .padding(.bottom, -2)
                                    }
                                    .foregroundColor(Color.white.opacity(0.70))
                                    .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                } else {
                                    NavigationLink(destination: DayDetailView(
                                        dailyRecord: dailyRecord,
                                        needsRefresh: $needsRefresh,
                                        isHistorical: false,
                                        onRefreshHistoricalRecords: fetchHistoricalRecords,
                                        onDismiss: {
                                            self.fetchDailyRecord()
                                        },
                                        onCompleteDay: { timeUntilMidnight in
                                            print("Time until midnight received: \(timeUntilMidnight) seconds") // Debug print
                                            self.timeRemaining = timeUntilMidnight
                                            UserDefaults.standard.set(timeUntilMidnight, forKey: "timeRemaining") // Save to UserDefaults
                                            UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(timeUntilMidnight)), forKey: "endDate") // Save end date
                                            startTimer()
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
                checkAndInitializeRecords()
                calculateTimeRemaining()
                startTimer() // Start the timer on view appear
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

    // Function to check and initialize records
    func checkAndInitializeRecords() {
        isLoading = true
        errorMessage = nil

        initializeDailyRecordIfEmpty { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.message == "Records already exist" {
                        fetchDailyRecord()
                        fetchHistoricalRecords()
                    } else if let newRecord = response.newRecord {
                        self.dailyRecord = newRecord
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to initialize records: \(error.localizedDescription)"
                    fetchDailyRecord()
                    fetchHistoricalRecords()
                }
            }
        }
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

    // Timer functions
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                UserDefaults.standard.set(self.timeRemaining, forKey: "timeRemaining") // Save to UserDefaults
            } else {
                timer?.invalidate()
                unlockDailyRecord() // Call the function to unlock the daily record
                self.fetchDailyRecord()
            }
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func unlockDailyRecord() {
        // Call the API to unlock the daily record
        unlockCurrentDailyRecord { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Daily record unlocked: \(response)")
                    self.fetchDailyRecord() // Refresh the daily record
                case .failure(let error):
                    print("Failed to unlock daily record: \(error.localizedDescription)")
                }
            }
        }
    }

    func calculateTimeRemaining() {
        if let endDate = UserDefaults.standard.object(forKey: "endDate") as? Date {
            let remaining = Int(endDate.timeIntervalSinceNow)
            if remaining > 0 {
                timeRemaining = remaining
            } else {
                unlockDailyRecord()
            }
        }
    }
}



struct DayDetailView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var selectedGoal: SelectedGoal? = nil
    @State var dailyRecord: DailyRecord

    @Binding var needsRefresh: Bool
    @State private var resettingDaily: Bool = false
    var isHistorical: Bool
    var onRefreshHistoricalRecords: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onCompleteDay: ((Int) -> Void)?

    @State private var showDayConfirmationAlert = false
    @State private var currentAction: ActionType? = nil

    enum ActionType {
        case completeDay
        case deleteDay
    }

    @State private var foods: [DailyFood] = []
    @State private var drinks: [DailyDrink] = []
    @State private var manuals: [DailyManual] = []

    init(dailyRecord: DailyRecord, needsRefresh: Binding<Bool>, isHistorical: Bool, onRefreshHistoricalRecords: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onCompleteDay: ((Int) -> Void)? = nil) {
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
                            NavigationLink(destination: FoodDetailView(food: food, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
                                self.foods.removeAll { $0.id == food.id }
                                self.needsRefresh = true
                            }, isHistorical: isHistorical)) {
                                Text(food.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }

                        ForEach(drinks, id: \.id) { drink in
                            NavigationLink(destination: DrinkDetailView(drink: drink, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
                                self.drinks.removeAll { $0.id == drink.id }
                                self.needsRefresh = true
                            }, isHistorical: isHistorical)) {
                                Text(drink.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }

                        ForEach(manuals, id: \.id) { manual in
                            NavigationLink(destination: ManualDetailView(manual: manual, selectedGoal: selectedGoalForRecord(isHistorical: isHistorical), onDelete: {
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
                    VStack {
                        Spacer()

                        Button (action: {
                            currentAction = .deleteDay
                            showDayConfirmationAlert = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 61/255, green: 2/255, blue: 9/255))
                                    .frame(width: 162, height: 45)
                                    .opacity(0.70)

                                HStack {
                                    Text("Delete Day")
                                        .font(.system(size: 16))
                                        .bold()

                                    Image(systemName: "trash")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .foregroundColor(.white.opacity(0.50))
                            }
                        }
                    }
                }
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
                case .success(let timeUntilMidnight):
                    print("Time until midnight: \(timeUntilMidnight / 1000) seconds")
                    onCompleteDay?(timeUntilMidnight / 1000)
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
}




struct FoodDetailView: View {
    var food: DailyFood
    
    var selectedGoal: SelectedGoal?
    
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
    
    var selectedGoal: SelectedGoal?
    
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
    
    var selectedGoal: SelectedGoal?
    
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
