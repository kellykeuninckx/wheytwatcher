import SwiftUI
import SwiftData

struct TodayView: View {
    let profile: UserProfile

    @State private var selectedGoalMode: GoalMode
    @State private var selectedGoalPace: GoalPace

    init(profile: UserProfile) {
        self.profile = profile
        _selectedGoalMode = State(initialValue: profile.goalMode)
        _selectedGoalPace = State(initialValue: profile.goalPace)
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var snapshots: [DailyTargetSnapshot]

    @State private var showingAddFood = false
    @State private var showingAddTraining = false
    @State private var showingAddWeight = false
    @State private var selectedDate: Date = Date()
    @State private var showingCopyMeal = false
    @State private var showingFavorites = false
    @State private var showingMeals = false
    @State private var showingBarcodeScanner = false
    @State private var showingLogbook = false
    @State private var showingProfile = false

    @AppStorage("wwIsDarkTheme") private var isDarkTheme: Bool = true


    private var todaysFood: [FoodLogEntry] {
        foodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var todaysTrainings: [TrainingSession] {
        trainings.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var todaysTrainingCalories: Double {
        todaysTrainings.reduce(0) { $0 + $1.estimatedCaloriesBurned }
    }

    private var target: MacroTarget {
        MacroCalculator.calculate(
            for: profile,
            goalMode: selectedGoalMode,
            goalPace: selectedGoalPace,
            extraTrainingCalories: todaysTrainingCalories
        )
    }

    private var totals: MacroTotals {
        MacroTotals(entries: todaysFood)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var caloriesRemaining: Double {
        max(target.calories - totals.calories, 0)
    }
    private var proteinRemaining: Double {
        max(target.proteinGrams - totals.protein, 0)
    }

    private var fiberRemaining: Double {
        max(target.fiberGrams - totals.fiber, 0)
    }
    private var coachMessage: String {

        if fiberRemaining > 0 && fiberRemaining <= 5 {
            return "Nog \(fiberRemaining.roundedInt) g vezels te gaan. Eén volkoren boterham of een appel is waarschijnlijk al genoeg."
        }

        if proteinRemaining > 0 && proteinRemaining <= 30 {
            return "Nog \(proteinRemaining.roundedInt) g eiwit. Een portie magere kwark of kipfilet brengt je waarschijnlijk al op je doel."
        }

        if caloriesRemaining > 500 {
            return "Je hebt nog \(caloriesRemaining.roundedInt) kcal over. Genoeg ruimte voor een volledige maaltijd."
        }

        if caloriesRemaining <= 100 {
            return "Je caloriedoel is bijna bereikt. Mooie dag!"
        }

        return "Je ligt goed op schema. Blijf zo doorgaan!"
    }
    
    private var greeting: String {

        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Goedemorgen"
        case 12..<18:
            return "Goedemiddag"
        default:
            return "Goedenavond"
        }

    }
    var body: some View {
        NavigationStack {
            ZStack {
                DumbbellPatternBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        
                        dateNavigator
                        
                        coachCard
                        
                        caloriesCard
                        
                        macrosCard
                        
                        trainingCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddFood) {
                AddFoodView()
            }.sheet(isPresented: $showingCopyMeal) {
                CopyMealsView()
            }

            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }

            .sheet(isPresented: $showingMeals) {
                Text("MealsView")
            }

            .sheet(isPresented: $showingBarcodeScanner) {
                Text("BarcodeScannerView")
            }
            .sheet(isPresented: $showingLogbook) {
                LogbookView()
            }
            .sheet(isPresented: $showingAddTraining) {
                AddTrainingView(profile: profile)
            }
            .sheet(isPresented: $showingAddWeight) {
                AddWeightView(profile: profile)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(profile: profile)

            }
            .onAppear {
                if isToday {
                    ensureTodaySnapshotExists()
                }
            }
            .onChange(of: todaysTrainingCalories) {
                if isToday {
                    upsertTodaySnapshot()
                }
            }
        }
    }

    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Button {

                    showingProfile = true

                } label: {

                    HStack(spacing: 6) {

                        Text("\(greeting) \(profile.name) 👋")
                            .font(.title2.bold())
                            .foregroundStyle(Color.wwDarkAccent)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.wwSecondaryText)

                    }

                }
                .buttonStyle(.plain)
                
                Text("Track your macros. Guard your gains.")
                    .font(.subheadline)
                    .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                
                HStack(spacing: 8) {

                    Menu {

                        ForEach(GoalMode.allCases) { mode in
                            Button(mode.rawValue) {
                                selectedGoalMode = mode

                                if isToday {
                                    upsertTodaySnapshot()
                                }                            }
                        }

                    } label: {

                        Label(selectedGoalMode.rawValue, systemImage: "chevron.down")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.wwAqua.opacity(0.18))
                            .foregroundStyle(Color.wwTeal)
                            .clipShape(Capsule())

                    }

                    Menu {

                        ForEach(GoalPace.allCases) { pace in
                            Button(pace.rawValue) {
                                selectedGoalPace = pace

                                if isToday {
                                    upsertTodaySnapshot()
                                }
                            }
                        }

                    } label: {

                        Label(selectedGoalPace.rawValue, systemImage: "chevron.down")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())

                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                themeToggleButton

                Menu {
                    Button {
                        showingCopyMeal = true
                    } label: {
                        Label("Kopieer product", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        showingFavorites = true
                    } label: {
                        Label("Favorieten", systemImage: "star.fill")
                    }
                    
                    Button {
                        showingMeals = true
                    } label: {
                        Label("Maaltijden", systemImage: "fork.knife")
                    }
                    
                    Button {
                        showingBarcodeScanner = true
                    } label: {
                        Label("Scan barcode", systemImage: "barcode.viewfinder")
                    }
                    
                    Divider()
                    
                    Button {
                        showingAddFood = true
                    } label: {
                        Label("Voeg handmatig toe", systemImage: "square.and.pencil")
                    }

                    Button {
                        showingAddWeight = true
                    } label: {
                        Label("Gewicht invoeren", systemImage: "scalemass")
                    }
                    
                } label: {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.wwTeal)
                        .padding(10)
                        .background(Color.wwCardBackground)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
        }
    }

    // MARK: - Thema-toggle

    private var themeToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isDarkTheme.toggle()
            }
        } label: {
            Image(systemName: isDarkTheme ? "moon.fill" : "sun.max.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.wwTeal)
                .padding(10)
                .background(Color.wwCardBackground)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel(isDarkTheme ? "Schakel naar licht thema" : "Schakel naar donker thema")
    }
    
    // MARK: - Date Navigator
    
    private var dateNavigator: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.wwTeal)
                    .padding(4)
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                if isToday {
                    Text("Vandaag")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.wwDarkAccent)
                } else {
                    Text(selectedDate, format: .dateTime.weekday(.wide))
                        .font(.headline)
                        .foregroundStyle(Color.wwDarkAccent)
                }
                
                Text(selectedDate, format: .dateTime.day().month(.wide))
                    .font(.caption)
                    .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundStyle(isToday ? Color.wwDarkAccent.opacity(0.2) : Color.wwTeal)
                    .padding(4)
            }
            .disabled(isToday)
        }
        .wwCard()
    }

    // MARK: - Calories Card
    
    private var caloriesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calorieën")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)
            
            HStack(spacing: 14) {
                RingProgressView(
                    title: "",
                    current: totals.calories,
                    target: target.calories,
                    unit: "kcal",
                    gradient: .wwMain,
                    lineWidth: 16,
                    titleFont: .caption,
                    valueFont: .title2.bold(),
                    showLabels: true
                )
                .frame(width: 118, height: 118)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    CalorieInfoRow(
                        icon: "flame.fill",
                        label: "Verbrand",
                        value: "\(todaysTrainingCalories.roundedInt)",
                        color: .orange
                    )
                    
                    CalorieInfoRow(
                        icon: "fork.knife",
                        label: "Gegeten",
                        value: "\(totals.calories.roundedInt)",
                        color: .wwTeal
                    )
                    
                    CalorieInfoRow(
                        icon: "target",
                        label: "Resterend",
                        value: "\(caloriesRemaining.roundedInt)",
                        color: .wwBlue
                    )
                }
            }
        }
        .wwCard()
        .onTapGesture {
            showingLogbook = true
        }
    }
    
    // MARK: - Macros Card
    
    private var macrosCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Macro's")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)
            
            HStack(spacing: 0) {
                Spacer()
                
                CompactRingView(
                    title: "Eiwit",
                    current: totals.protein,
                    target: target.proteinGrams,
                    unit: "g",
                    gradient: .wwProtein,
                    lineWidth: 7
                )
                
                Spacer()
                
                CompactRingView(
                    title: "Carbs",
                    current: totals.carbs,
                    target: target.carbsGrams,
                    unit: "g",
                    gradient: .wwCarbs,
                    lineWidth: 7
                )
                
                Spacer()
                
                CompactRingView(
                    title: "Vet",
                    current: totals.fat,
                    target: target.fatGrams,
                    unit: "g",
                    gradient: .wwFat,
                    lineWidth: 7
                )
                
                Spacer()
                
                CompactRingView(
                    title: "Vezels",
                    current: totals.fiber,
                    target: target.fiberGrams,
                    unit: "g",
                    gradient: .wwFiber,
                    lineWidth: 7
                )
                
                Spacer()
            }
        }
        .wwCard()
    }
    
    // MARK: - Training Card
    
    private var trainingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)
            
            if todaysTrainings.isEmpty {
                if isToday {
                    Button {
                        showingAddTraining = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.wwTeal)
                            
                            Text("Training toevoegen")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.wwTeal)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.3))
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    HStack {
                        Image(systemName: "figure.stand")
                            .font(.title2)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.3))
                        
                        Text("Geen training gelogd")
                            .font(.subheadline)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            } else {
                List {
                    ForEach(todaysTrainings) { training in
                        HStack(spacing: 14) {
                            Image(systemName: trainingIcon(for: training.type))
                                .font(.title2)
                                .foregroundStyle(Color.wwTeal)
                                .frame(width: 36)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(training.type.rawValue)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.wwDarkAccent)
                                
                                Text("\(training.durationMinutes) min • RPE \(training.rpe)")
                                    .font(.caption)
                                    .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(training.estimatedCaloriesBurned.roundedInt)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.wwDarkAccent)
                                
                                Text("kcal")
                                    .font(.caption)
                                    .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(todaysTrainings[index])
                        }
                        try? modelContext.save()
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .frame(height: CGFloat(todaysTrainings.count) * 60)
                
                if isToday {
                    Divider()
                    
                    Button {
                        showingAddTraining = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.caption.bold())
                            
                            Text("Nog een training")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.wwTeal)
                    }
                }
            }
        }
        .wwCard()
    }
    
    // MARK: - Today's Log Card
    
    
    private var coachCard: some View {

        HStack(alignment: .top, spacing: 10) {

            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .padding(.top, 2)

            Text(coachMessage)
                .font(.footnote)
                .foregroundStyle(Color.wwDarkAccent)

        }
        .wwCard()

    }
    
    // MARK: - Helper Functions
    
    private func trainingIcon(for type: TrainingType) -> String {
        switch type {
        case .heavyStrength, .hypertrophy:
            return "dumbbell.fill"
        case .hyrox:
            return "figure.cross.training"
        case .gymnastics:
            return "figure.gymnastics"
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .boxing:
            return "figure.boxing"
        case .other:
            return "figure.mixed.cardio"
        }
    }

    private func ensureTodaySnapshotExists() {
        let exists = snapshots.contains { Calendar.current.isDateInToday($0.date) }
        if !exists {
            upsertTodaySnapshot()
        }
    }

    private func upsertTodaySnapshot() {
        if let existing = snapshots.first(where: { Calendar.current.isDateInToday($0.date) }) {
            existing.goalMode = selectedGoalMode
            existing.goalPace = selectedGoalPace
            existing.calories = target.calories
            existing.proteinGrams = target.proteinGrams
            existing.carbsGrams = target.carbsGrams
            existing.fatGrams = target.fatGrams
            existing.fiberGrams = target.fiberGrams
            existing.trainingCalories = target.trainingCalories
        } else {
            let snapshot = DailyTargetSnapshot(
                date: Date(),
                goalMode: selectedGoalMode,
                goalPace: selectedGoalPace,
                calories: target.calories,
                proteinGrams: target.proteinGrams,
                carbsGrams: target.carbsGrams,
                fatGrams: target.fatGrams,
                fiberGrams: target.fiberGrams,
                trainingCalories: target.trainingCalories
            )
            modelContext.insert(snapshot)
        }
    }
}

// MARK: - Supporting Views

struct CalorieInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 22)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.wwDarkAccent)
            }
        }
    }
}

struct MacroTotals {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double

    init(entries: [FoodLogEntry]) {
        calories = entries.reduce(0) { $0 + $1.calories }
        protein = entries.reduce(0) { $0 + $1.proteinGrams }
        carbs = entries.reduce(0) { $0 + $1.carbsGrams }
        fat = entries.reduce(0) { $0 + $1.fatGrams }
        fiber = entries.reduce(0) { $0 + $1.fiberGrams }
    }
}
