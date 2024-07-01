import SwiftUI

struct NutritionLogView: View {
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var dailyRecord: DailyRecord?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                    //                    .onChange(of: selectedMonth) { _ in fetchDailyRecord() }
                    //                    .onChange(of: selectedYear) { _ in fetchDailyRecord() }
                    
                    // List of Entries
                    if isLoading {
                        ProgressView()
                            .foregroundColor(.white)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if let dailyRecord = dailyRecord {
                        List {
                            NavigationLink(destination: DayDetailView(dailyRecord: dailyRecord)) {
                                VStack(alignment: .leading) {
                                    let formattedDate = formattedDate(from: dailyRecord.date)
                                    Text(formattedDate)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.80))
                                    // Summary of the day's nutrition info
                                    //                                    HStack {
                                    //                                        Text("Calories: \(dailyRecord.calories)")
                                    //                                            .font(.subheadline)
                                    //                                        Spacer()
                                    //                                        Text("Protein: \(dailyRecord.protein)g")
                                    //                                            .font(.subheadline)
                                    //                                        Spacer()
                                    //                                        Text("Fats: \(dailyRecord.fat)g")
                                    //                                            .font(.subheadline)
                                    //                                        Spacer()
                                    //                                        Text("Carbs: \(dailyRecord.carbs)g")
                                    //                                            .font(.subheadline)
                                    //                                    }
                                }
                                .foregroundColor(Color.white.opacity(0.70))
                                .padding(.vertical, 5)
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                        .listStyle(PlainListStyle())
                        .background(Color(red: 56/255, green: 56/255, blue: 56/255))
                        .navigationTitle("Nutrition Log")
                        .foregroundColor(.white)
                    }
                }
                .foregroundColor(.white)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                fetchDailyRecord()
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
    var dailyRecord: DailyRecord
    
    let goalCalories: Int = 2300
    let goalProtein: Int = 160
    let goalCarbs: Int = 250
    let goalFats: Int = 70
    
    var body: some View {
        let formattedDate = formattedDate(from: dailyRecord.date)
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()
                
                VStack {
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                        GridRow {
                            NutrientView(nutrient: "Calories", curValue: Int(dailyRecord.calories), goalValue: goalCalories, color: Color(red: 10/255, green: 211/255, blue: 255/255))
                            NutrientView(nutrient: "Protein", curValue: Int(dailyRecord.protein), goalValue: goalProtein, color: Color(red: 46/255, green: 94/255, blue: 170/255))
                        }
                        GridRow {
                            NutrientView(nutrient: "Carbs", curValue: Int(dailyRecord.carbs), goalValue: goalCarbs, color: Color(red: 120/255, green: 255/255, blue: 214/255))
                            NutrientView(nutrient: "Fat", curValue: Int(dailyRecord.fat), goalValue: goalFats, color: Color(red: 171/255, green: 169/255, blue: 195/255))
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    
                    List {
                        ForEach(dailyRecord.foods, id: \.id) { food in
                            NavigationLink(destination: FoodDetailView(food: food)) {
                                Text(food.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                        
                        ForEach(dailyRecord.drinks, id: \.id) { drink in
                            NavigationLink(destination: DrinkDetailView(drink: drink)) {
                                Text(drink.name)
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
        }
    }
    
    func formattedDate(from dateString: String) -> String {
        let year = dateString.prefix(4)
        let month = dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)]
        let day = dateString[dateString.index(dateString.startIndex, offsetBy: 8)..<dateString.index(dateString.startIndex, offsetBy: 10)]
        
        let monthName = DateFormatter().monthSymbols[Int(month)! - 1]
        
        return "\(monthName) \(day), \(year)"
    }
}

struct FoodDetailView: View {
    var food: DailyFood
    
    var body: some View {
        VStack {
            Text(food.name)
            // Add more detailed views here
        }
    }
}

struct DrinkDetailView: View {
    var drink: DailyDrink
    
    var body: some View {
        VStack {
            Text(drink.name)
            // Add more detailed views here
        }
    }
}

struct NutritionLogView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionLogView()
    }
}
