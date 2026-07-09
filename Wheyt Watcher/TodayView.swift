import SwiftUI
import SwiftData

struct TodayView: View {
    let profile: UserProfile

    @Environment(\.modelContext) private var modelContext
    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var snapshots: [DailyTargetSnapshot]
    @Query private var weightLogs: [WeightLog]
    @Query private var dayStatuses: [DayStatus]

    @State private var showingAddFood = false
    @State private var showingAddTraining = false
    @State private var showingAddWeight = false
    @State private var selectedDate: Date = Date()
    @State private var showingCopyMeal = false
    @State private var showingFavorites = false
    @State private var showingMeals = false
    @State private var showingBarcodeScanner = false
    @State private var showingFoodSearch = false
    @State private var showingLogbook = false
    @State private var showingProfile = false
    @State private var showingQuickAddMenu = false
    @State private var showingGoalPeriodEndedSheet = false
    @State private var showingAdaptiveCheckInSheet = false
    @State private var adaptiveCheckInResult: AdaptiveCheckInResult?
    @State private var showingMissedDaysPrompt = false
    @State private var missedDaysRange: [Date] = []
    @State private var showingAddRestDay = false
    @AppStorage("wwLastMissedDaysPromptDate") private var lastMissedDaysPromptDateString: String = ""

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
            goalMode: profile.goalMode,
            goalPace: profile.goalPace,
            extraTrainingCalories: todaysTrainingCalories,
            manualCalorieAdjustment: profile.activeGoalPeriod?.calorieAdjustment ?? 0
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

    // MARK: - Tip van de dagdeel

    private enum CoachMessageType: Int, CaseIterable {
        case fiberClose, proteinClose, caloriesAlmostDone, caloriesPlenty, onTrack, generalTip
    }

    /// Per uur × dag-van-het-jaar, zodat de rotatie vaker wisselt (niet de hele ochtend hetzelfde
    /// bericht) en toch elke dag een ander patroon volgt.
    private var dagdeelRotationIndex: Int {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return (dayOfYear * 24 + hour) % CoachMessageType.allCases.count
    }

    private var coachMessage: String {
        let order = CoachMessageType.allCases
        for offset in 0..<order.count {
            let type = order[(dagdeelRotationIndex + offset) % order.count]
            if let message = coachMessage(for: type) {
                return message
            }
        }
        return "Je ligt goed op schema. Blijf zo doorgaan!"
    }

    private func coachMessage(for type: CoachMessageType) -> String? {
        switch type {

        case .fiberClose:
            guard fiberRemaining > 0, fiberRemaining <= 5 else { return nil }
            return "Nog \(fiberRemaining.roundedInt) g vezels te gaan. \(fiberEquivalent(fiberRemaining))"

        case .proteinClose:
            guard proteinRemaining > 0, proteinRemaining <= 30 else { return nil }
            return "Nog \(proteinRemaining.roundedInt) g eiwit te gaan. \(proteinEquivalent(proteinRemaining))"

        case .caloriesAlmostDone:
            guard caloriesRemaining <= 100 else { return nil }
            return "Je caloriedoel is bijna bereikt. Mooie dag!"

        case .caloriesPlenty:
            guard caloriesRemaining > 500 else { return nil }
            return "Je hebt nog \(caloriesRemaining.roundedInt) kcal over. Genoeg ruimte voor een volledige maaltijd."

        case .onTrack:
            return "Je ligt goed op schema. Blijf zo doorgaan!"

        case .generalTip:
            return NutritionTips.tip(for: Date())

        }
    }

    private func proteinEquivalent(_ grams: Double) -> String {
        let quarkGrams = (grams * 10).roundedInt
        return "Dat is ongeveer \(quarkGrams) g magere kwark, of een kipfiletje."
    }

    private func fiberEquivalent(_ grams: Double) -> String {
        let apples = max(Int((grams / 4).rounded()), 1)
        return "Dat is ongeveer \(apples) \(apples == 1 ? "appel" : "appels")."
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

                if showingQuickAddMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showingQuickAddMenu = false
                            }
                        }

                    VStack {
                        HStack {
                            Spacer()
                            quickAddDropdown
                                .padding(.trailing, 18)
                        }
                        // Let op: deze top-padding is een schatting (nav bar + header-hoogte).
                        // Even visueel checken in Xcode en desgewenst bijstellen.
                        .padding(.top, 85)

                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                MealsView()
            }

            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView()
            }
            .sheet(isPresented: $showingFoodSearch) {
                FoodSearchView()
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
            .sheet(isPresented: $showingGoalPeriodEndedSheet) {
                EditGoalSheet(
                    profile: profile,
                    completionMessage: goalCompletionMessage
                )
            }
            .sheet(isPresented: $showingAdaptiveCheckInSheet) {
                if let period = profile.activeGoalPeriod, let result = adaptiveCheckInResult {
                    AdaptiveCheckInSheet(
                        result: result,
                        onApply: { kcal in
                            period.calorieAdjustment += kcal
                            period.lastCheckInDate = Date()
                            try? modelContext.save()
                        },
                        onDismiss: {
                            period.lastCheckInDate = Date()
                            try? modelContext.save()
                        }
                    )
                }
            }
            .sheet(isPresented: $showingMissedDaysPrompt) {
                MissedDaysPromptSheet(
                    days: missedDaysRange,
                    onSelect: { type in
                        for day in missedDaysRange {
                            let status = DayStatus(date: day, type: type)
                            modelContext.insert(status)
                        }
                        try? modelContext.save()
                        recordMissedDaysPromptShownToday()
                        showingMissedDaysPrompt = false
                    },
                    onDismiss: {
                        recordMissedDaysPromptShownToday()
                        showingMissedDaysPrompt = false
                    }
                )
            }
            .sheet(isPresented: $showingAddRestDay) {
                AddRestDaySheet()
            }
            .onAppear {
                if isToday {
                    ensureTodaySnapshotExists()
                }
                checkGoalPeriodEnded()
                if !showingGoalPeriodEndedSheet {
                    checkAdaptiveCheckIn()
                }
                if !showingGoalPeriodEndedSheet && !showingAdaptiveCheckInSheet {
                    checkMissedDaysPrompt()
                }
            }
            .onChange(of: todaysTrainingCalories) {
                if isToday {
                    upsertTodaySnapshot()
                }
            }
            .onChange(of: profile.goalMode) {
                if isToday {
                    upsertTodaySnapshot()
                }
            }
            .onChange(of: profile.goalPace) {
                if isToday {
                    upsertTodaySnapshot()
                }
            }
        }
    }

    // MARK: - Doelperiode afgerond

    private func checkGoalPeriodEnded() {
        if let period = profile.activeGoalPeriod, period.hasEnded {
            showingGoalPeriodEndedSheet = true
        }
    }

    private var goalCompletionMessage: String {
        let weeks = profile.activeGoalPeriod?.durationWeeks ?? 0
        return "🎉 Goed bezig! Je hebt je \(profile.goalMode.rawValue.lowercased()) van \(weeks) weken volgehouden. Kies hieronder hoe je verder wil — nog een periode in hetzelfde doel, of iets nieuws."
    }

    // MARK: - Slimme 2-wekelijkse check-in

    private func checkAdaptiveCheckIn() {
        guard let period = profile.activeGoalPeriod,
              !period.hasEnded,
              period.goalMode != .maintenance else { return }

        let referenceDate = period.lastCheckInDate ?? period.startDate
        let daysSinceCheckIn = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: referenceDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0

        guard daysSinceCheckIn >= 14 else { return }

        adaptiveCheckInResult = AdaptiveCheckInEvaluator.evaluate(
            period: period,
            foodEntries: foodEntries,
            weightLogs: weightLogs,
            trainings: trainings,
            dayStatuses: dayStatuses
        )
        showingAdaptiveCheckInSheet = true
    }

    // MARK: - Gemiste dagen (reactieve check)

    private var missedDaysDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private func alreadyPromptedForMissedDaysToday() -> Bool {
        guard !lastMissedDaysPromptDateString.isEmpty else { return false }
        return lastMissedDaysPromptDateString == missedDaysDayFormatter.string(from: Date())
    }

    private func recordMissedDaysPromptShownToday() {
        lastMissedDaysPromptDateString = missedDaysDayFormatter.string(from: Date())
    }

    /// Kijkt of er, vlak vóór vandaag, een aaneengesloten reeks dagen is zonder voedingslog én
    /// zonder handmatige dagstatus. Zo ja: vraagt de gebruiker of dat ziek/vakantie/rustdag was.
    /// Vraagt maximaal 1x per dag (anders zou dit elke keer dat de app opent terugkomen).
    private func checkMissedDaysPrompt() {
        guard !alreadyPromptedForMissedDaysToday() else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var missingDays: [Date] = []
        var offset = 1

        while missingDays.count < 14 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { break }

            let hasFoodEntry = foodEntries.contains { calendar.isDate($0.date, inSameDayAs: day) }
            let isMarked = dayStatuses.contains { calendar.isDate($0.date, inSameDayAs: day) }

            if hasFoodEntry || isMarked {
                break
            }

            missingDays.append(day)
            offset += 1
        }

        guard missingDays.count >= 3 else { return }

        missedDaysRange = missingDays.sorted()
        showingMissedDaysPrompt = true
    }

    // MARK: - Doel-voortgang (read-only, wisselen doe je via Profiel)

    private var goalProgressLabel: some View {
        Group {
            if let period = profile.activeGoalPeriod {
                Text("\(profile.goalMode.rawValue) — week \(period.currentWeekNumber) van \(period.durationWeeks), nog \(period.weeksRemaining) \(period.weeksRemaining == 1 ? "week" : "weken") te gaan")
            } else {
                Text(profile.goalMode.rawValue)
            }
        }
        .font(.caption.bold())
        .foregroundStyle(Color.wwOrange)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
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

                Spacer()

                HStack(spacing: 10) {
                    themeToggleButton

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showingQuickAddMenu.toggle()
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

            Text("TRACK YOUR MACROS · GUARD YOUR GAINS")
                .font(.caption2.weight(.medium))
                .kerning(1.5)
                .foregroundStyle(Color.wwTeal)

            goalProgressLabel

        }
    }

    // MARK: - Quick-add dropdown

    private struct QuickAddOption: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let action: () -> Void
    }

    private var quickAddOptions: [QuickAddOption] {
        [
            QuickAddOption(icon: "doc.on.doc", title: "Kopieer product") {
                showingCopyMeal = true
            },
            QuickAddOption(icon: "star.fill", title: "Voeg favoriet toe") {
                showingFavorites = true
            },
            QuickAddOption(icon: "fork.knife", title: "Voeg maaltijd toe") {
                showingMeals = true
            },
            QuickAddOption(icon: "barcode.viewfinder", title: "Scan barcode") {
                showingBarcodeScanner = true
            },
            QuickAddOption(icon: "magnifyingglass", title: "Zoek product") {
                showingFoodSearch = true
            },
            QuickAddOption(icon: "square.and.pencil", title: "Voeg handmatig toe") {
                showingAddFood = true
            },
            QuickAddOption(icon: "scalemass", title: "Voeg weegmoment toe") {
                showingAddWeight = true
            }
        ]
    }

    private var quickAddDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(quickAddOptions.enumerated()), id: \.element.id) { index, option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showingQuickAddMenu = false
                    }
                    option.action()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: option.icon)
                            .font(.subheadline)
                            .foregroundStyle(Color.wwTeal)
                            .frame(width: 20)

                        Text(option.title)
                            .font(.subheadline)
                            .foregroundStyle(Color.wwDarkAccent)

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < quickAddOptions.count - 1 {
                    Divider()
                        .padding(.leading, 46)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(width: 220)
        .background(Color.wwCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Calorieën")
                    .font(.headline)
                    .foregroundStyle(Color.wwDarkAccent)

                Spacer()

                Button {
                    showingAddRestDay = true
                } label: {
                    Image(systemName: "bed.double.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.wwSecondaryText)
                }
            }
            
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
            existing.goalMode = profile.goalMode
            existing.goalPace = profile.goalPace
            existing.calories = target.calories
            existing.proteinGrams = target.proteinGrams
            existing.carbsGrams = target.carbsGrams
            existing.fatGrams = target.fatGrams
            existing.fiberGrams = target.fiberGrams
            existing.trainingCalories = target.trainingCalories
        } else {
            let snapshot = DailyTargetSnapshot(
                date: Date(),
                goalMode: profile.goalMode,
                goalPace: profile.goalPace,
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

// MARK: - Slimme check-in sheet

struct AdaptiveCheckInSheet: View {

    let result: AdaptiveCheckInResult
    let onApply: (Double) -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text(icon)
                .font(.system(size: 44))

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.wwDarkAccent)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.wwSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Spacer()

            if case .suggestAdjustment(let kcal, _) = result {

                Button {
                    onApply(kcal)
                    dismiss()
                } label: {
                    Text("Pas toe (\(kcal > 0 ? "+" : "")\(Int(kcal)) kcal per dag)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.wwTeal)

                Button("Niet nu") {
                    onDismiss()
                    dismiss()
                }
                .foregroundStyle(Color.wwSecondaryText)

            } else {

                Button {
                    onDismiss()
                    dismiss()
                } label: {
                    Text("Begrepen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.wwTeal)

            }

        }
        .padding(30)
        .presentationDetents([.medium])
    }

    private var icon: String {
        switch result {
        case .insufficientData: return "🧐"
        case .onTrack: return "✅"
        case .suggestAdjustment: return "💡"
        }
    }

    private var title: String {
        switch result {
        case .insufficientData: return "Nog even geduld"
        case .onTrack: return "Je zit goed op schema!"
        case .suggestAdjustment: return "Kleine bijstelling?"
        }
    }

    private var message: String {
        switch result {
        case .insufficientData(let reason): return reason
        case .onTrack(let message): return message
        case .suggestAdjustment(_, let reasoning): return reasoning
        }
    }

}

// MARK: - Algemene voedingstips (database voor de "tip van de dagdeel")

enum NutritionTips {

    static let all: [String] = [
        "Wist je dat 1 appel ongeveer 4 g vezels bevat?",
        "Wist je dat 100 g kipfilet ongeveer 31 g eiwit bevat?",
        "Wist je dat volkoren brood meer vezels bevat dan wit brood?",
        "Wist je dat 1 ei ongeveer 6 g eiwit bevat?",
        "Wist je dat peulvruchten zoals linzen rijk zijn aan zowel eiwit als vezels?",
        "Wist je dat magere kwark een van de goedkoopste eiwitbronnen is?",
        "Wist je dat een banaan ongeveer 3 g vezels bevat?",
        "Wist je dat voldoende vezels je langer een verzadigd gevoel geven?",
        "Wist je dat noten een goede bron van gezonde, onverzadigde vetten zijn?",
        "Wist je dat 100 g Griekse yoghurt ongeveer 10 g eiwit bevat?",
        "Wist je dat groenten met veel water, zoals komkommer, weinig calorieën kosten maar wel vullen?",
        "Wist je dat havermout een goede combinatie van vezels én langzame koolhydraten is?",
        "Wist je dat spieren tijdens rust groeien, niet tijdens de training zelf?",
        "Wist je dat een dieetpauze na een lange cut je metabolisme kan helpen herstellen?",
        "Wist je dat je gewicht van dag tot dag kan schommelen door water — de wekelijkse trend zegt veel meer dan één meting?",
        "Wist je dat progressive overload (geleidelijk zwaarder trainen) de sleutel is tot spiergroei?",
        "Wist je dat voldoende slaap net zo belangrijk is voor herstel als je voeding?",
        "Wist je dat consistentie over weken en maanden belangrijker is dan perfectie op één dag?",
        "Wist je dat krachttraining tijdens een cut helpt om je spiermassa te behouden?",
        "Wist je dat een te agressief tekort vaker leidt tot terugval dan een gematigd tekort?"
    ]

    /// Kiest een tip op basis van uur + dag, zodat 'm ook binnen één dag al verschuift i.p.v. steeds
    /// dezelfde tekst te tonen totdat de datum omslaat.
    static func tip(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return all[(dayOfYear * 24 + hour) % all.count]
    }

}

// MARK: - Gemiste-dagen check-in

struct MissedDaysPromptSheet: View {

    let days: [Date]
    let onSelect: (DayStatusType) -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("🕊️")
                .font(.system(size: 44))

            Text("We zien dat je \(days.count) dagen niet hebt gelogd")
                .font(.title3.bold())
                .foregroundStyle(Color.wwDarkAccent)
                .multilineTextAlignment(.center)

            Text("Was je ziek, met vakantie, of gewoon druk? Dan tellen die dagen niet mee als gemist.")
                .font(.subheadline)
                .foregroundStyle(Color.wwSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Spacer()

            VStack(spacing: 10) {

                ForEach(DayStatusType.allCases) { type in
                    Button {
                        onSelect(type)
                        dismiss()
                    } label: {
                        Label(type.rawValue, systemImage: type.icon)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.wwTeal)
                }

                Button("Nee, gewoon niet gelogd") {
                    onDismiss()
                    dismiss()
                }
                .foregroundStyle(Color.wwSecondaryText)

            }

        }
        .padding(30)
        .presentationDetents([.medium])
    }

}
