import SwiftUI

struct NutritionLogView: View {
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
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
                    
                    // List of Entries
                    List {
                        ForEach(daysInMonth(month: selectedMonth, year: selectedYear), id: \.self) { day in
                            NavigationLink(destination: DayDetailView(day: day, month: selectedMonth, year: selectedYear)) {
                                VStack(alignment: .leading) {
                                    Text("Day \(day)")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.80))
                                    // Summary of the day's nutrition info
                                    HStack {
                                        Text("Calories: 2000")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("Protein: 150g")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("Fats: 70g")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("Carbs: 250g")
                                            .font(.subheadline)
                                    }
                                }
                                .foregroundColor(Color.white.opacity(0.70))
                                .padding(.vertical, 5)
                            }
                            .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 56/255, green: 56/255, blue: 56/255))
                    .navigationTitle("Nutrition Log")
                    .foregroundColor(.white)
                }
                .foregroundColor(.white)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func daysInMonth(month: Int, year: Int) -> [Int] {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return Array(range)
    }
}

struct DayDetailView: View {
    var day: Int
    var month: Int
    var year: Int
    
    var body: some View {
        ZStack {
            Color(red: 56/255, green: 56/255, blue: 56/255)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Details for \(day)/\(month)/\(year)")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                
                // Detailed nutrition information
                Text("Calories: 2000").foregroundColor(.white)
                Text("Protein: 150g").foregroundColor(.white)
                Text("Fats: 70g").foregroundColor(.white)
                Text("Carbs: 250g").foregroundColor(.white)
            }
            .navigationTitle("Day \(day) Details")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

struct NutritionLogView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionLogView()
    }
}
