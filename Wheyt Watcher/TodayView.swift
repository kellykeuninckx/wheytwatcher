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
    @State private var macroBreakdownSelection: MacroBreakdownType?
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
    @State private var newBadgeBatch: BadgeUnlockBatch?

    @AppStorage("wwLastAcknowledgedKwarkTier") private var lastAcknowledgedKwarkTier = ""
    @AppStorage("wwLastAcknowledgedStreakTier") private var lastAcknowledgedStreakTier = ""
    @AppStorage("wwLastAcknowledgedWalkingTier") private var lastAcknowledgedWalkingTier = ""
    @State private var missedDaysRange: [Date] = []
    @State private var showingAddRestDay = false
    @AppStorage("wwLastMissedDaysPromptDate") private var lastMissedDaysPromptDateString: String = ""

    @AppStorage("wwIsDarkTheme") private var isDarkTheme: Bool = true
    @AppStorage("wwBluntCoachMode") private var bluntCoachMode = false
    @AppStorage("wwReminderEveningLog") private var reminderEveningLog = true
    @AppStorage("wwReminderGoalEnding") private var reminderGoalEnding = true
    @AppStorage("wwReminderWeeklyWeighIn") private var reminderWeeklyWeighIn = true
    @AppStorage("wwWeighInWeekday") private var weighInWeekday = 2


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
            if bluntCoachMode {
                return "Nog \(fiberRemaining.roundedInt)g vezels te gaan. Werk dat fruit naar binnen, joh."
            }
            return "Nog \(fiberRemaining.roundedInt) g vezels te gaan. \(fiberEquivalent(fiberRemaining))"

        case .proteinClose:
            guard proteinRemaining > 0, proteinRemaining <= 30 else { return nil }
            if bluntCoachMode {
                return "Nog \(proteinRemaining.roundedInt)g eiwit te gaan. Pak die kwark er nou maar bij."
            }
            return "Nog \(proteinRemaining.roundedInt) g eiwit te gaan. \(proteinEquivalent(proteinRemaining))"

        case .caloriesAlmostDone:
            guard caloriesRemaining > 0, caloriesRemaining <= 100 else { return nil }
            return bluntCoachMode
                ? "Bijna je caloriedoel behaald. Laat die koekjes maar liggen."
                : "Je caloriedoel is bijna bereikt. Mooie dag!"

        case .caloriesPlenty:
            guard caloriesRemaining > 500 else { return nil }
            if bluntCoachMode {
                return "Nog \(caloriesRemaining.roundedInt) kcal over. Wil je nou gains of niet? Eten met die hap."
            }
            return "Je hebt nog \(caloriesRemaining.roundedInt) kcal over. Genoeg ruimte voor een volledige maaltijd."

        case .onTrack:
            return bluntCoachMode
                ? "Je ligt op schema. Hèhè, zal eens tijd worden."
                : "Je ligt goed op schema. Blijf zo doorgaan!"

        case .generalTip:
            return bluntCoachMode
                ? BluntCoachMessages.message(for: Date(), hasLoggedToday: !todaysFood.isEmpty)
                : NutritionTips.tip(for: Date())

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
            .tint(Color.wwTeal)
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
            .sheet(item: $newBadgeBatch) { batch in
                NewBadgeSheet(badges: batch.badges)
            }
            .sheet(item: $macroBreakdownSelection) { macro in
                MacroBreakdownView(initialMacro: macro, date: selectedDate, entries: todaysFood)
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
                if !showingGoalPeriodEndedSheet && !showingAdaptiveCheckInSheet && !showingMissedDaysPrompt {
                    checkNewBadge()
                }
                refreshReminders()
            }
            .onChange(of: todaysFood.count) {
                refreshReminders()
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

    // MARK: - Nieuwe badge (kwark / streak / wandelen)

    private func checkNewBadge() {
        let kwarkGrams = BadgeMetrics.totalKwarkGrams(foodEntries: foodEntries)
        let streak = Double(BadgeMetrics.longestLoggingStreak(foodEntries: foodEntries, dayStatuses: dayStatuses))
        let walkingHours = BadgeMetrics.totalWalkingHours(trainings: trainings)

        var newlyUnlocked: [BadgeTier] = []

        if let tier = BadgeTiers.current(value: kwarkGrams, tiers: BadgeTiers.kwark),
           tier.name != lastAcknowledgedKwarkTier {
            lastAcknowledgedKwarkTier = tier.name
            newlyUnlocked.append(tier)
        }

        if let tier = BadgeTiers.current(value: streak, tiers: BadgeTiers.streak),
           tier.name != lastAcknowledgedStreakTier {
            lastAcknowledgedStreakTier = tier.name
            newlyUnlocked.append(tier)
        }

        if let tier = BadgeTiers.current(value: walkingHours, tiers: BadgeTiers.walking),
           tier.name != lastAcknowledgedWalkingTier {
            lastAcknowledgedWalkingTier = tier.name
            newlyUnlocked.append(tier)
        }

        guard !newlyUnlocked.isEmpty else { return }
        newBadgeBatch = BadgeUnlockBatch(badges: newlyUnlocked)
    }

    // MARK: - Reminders

    private func refreshReminders() {
        let today = Calendar.current.startOfDay(for: Date())
        let hasLoggedToday = foodEntries.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }

        ReminderManager.refreshEveningLogReminder(
            enabled: reminderEveningLog,
            hasLoggedToday: hasLoggedToday
        )

        ReminderManager.setGoalEndingReminderEnabled(
            reminderGoalEnding,
            period: profile.activeGoalPeriod
        )

        ReminderManager.refreshWeeklyWeighInReminderIfNeeded(
            enabled: reminderWeeklyWeighIn,
            weekday: weighInWeekday
        )
    }

    // MARK: - Doel-voortgang (read-only, wisselen doe je via Profiel)

    private var goalProgressLabel: some View {
        HStack(spacing: 8) {

            Text(goalProgressText)
                .font(.caption2.weight(.medium))
                .kerning(1)
                .foregroundStyle(Color.wwOrange)
                .fixedSize(horizontal: false, vertical: true)

            if let period = profile.activeGoalPeriod {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.wwOrange.opacity(0.2))

                        Capsule()
                            .fill(Color.wwOrange)
                            .frame(width: geo.size.width * progressFraction(for: period))
                    }
                }
                .frame(height: 3)
                .frame(maxWidth: 60)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var goalProgressText: String {
        guard let period = profile.activeGoalPeriod else {
            return profile.goalMode.rawValue.uppercased()
        }
        let weeksWord = period.weeksRemaining == 1 ? "WEEK" : "WEKEN"
        return "\(profile.goalMode.rawValue.uppercased()) · NOG \(period.weeksRemaining) \(weeksWord)"
    }

    private func progressFraction(for period: GoalPeriod) -> Double {
        guard period.durationWeeks > 0 else { return 0 }
        return min(max(Double(period.currentWeekNumber) / Double(period.durationWeeks), 0), 1)
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
                        color: .wwAqua
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
                .contentShape(Rectangle())
                .onTapGesture { macroBreakdownSelection = .eiwit }
                
                Spacer()
                
                CompactRingView(
                    title: "Carbs",
                    current: totals.carbs,
                    target: target.carbsGrams,
                    unit: "g",
                    gradient: .wwCarbs,
                    lineWidth: 7
                )
                .contentShape(Rectangle())
                .onTapGesture { macroBreakdownSelection = .koolhydraten }
                
                Spacer()
                
                CompactRingView(
                    title: "Vet",
                    current: totals.fat,
                    target: target.fatGrams,
                    unit: "g",
                    gradient: .wwFat,
                    lineWidth: 7
                )
                .contentShape(Rectangle())
                .onTapGesture { macroBreakdownSelection = .vet }
                
                Spacer()
                
                CompactRingView(
                    title: "Vezels",
                    current: totals.fiber,
                    target: target.fiberGrams,
                    unit: "g",
                    gradient: .wwFiber,
                    lineWidth: 7
                )
                .contentShape(Rectangle())
                .onTapGesture { macroBreakdownSelection = .vezels }
                
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

            Spacer(minLength: 0)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        case .swimming:
            return "figure.pool.swim"
        case .crossfit:
            return "figure.cross.training"
        case .cycling:
            return "figure.outdoor.cycle"
        case .yoga:
            return "figure.yoga"
        case .racketSports:
            return "figure.tennis"
        case .rowing:
            return "figure.rower"
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
        "Wist je dat 1 appel ongeveer 4 g vezels bevat? Een makkelijke manier om dichter bij je dagdoel te komen.",
        "Wist je dat 100 g kipfilet ongeveer 31 g eiwit bevat? Ideaal voor spierherstel na het trainen.",
        "Volkoren brood bevat meer vezels dan wit brood. Dat houdt je langer verzadigd.",
        "Wist je dat 1 ei ongeveer 6 g eiwit bevat? Een goedkope eiwitbron bij elke maaltijd.",
        "Peulvruchten zoals linzen zijn rijk aan zowel eiwit als vezels. Een slimme, plantaardige eiwitbron.",
        "Magere kwark is een van de goedkoopste eiwitbronnen die er zijn.",
        "Wist je dat een banaan ongeveer 3 g vezels bevat? Handig vlak vóór of na het sporten.",
        "Voldoende vezels geven je langer een verzadigd gevoel.",
        "Noten zijn een goede bron van gezonde, onverzadigde vetten.",
        "Wist je dat 100 g Griekse yoghurt ongeveer 10 g eiwit bevat? Een prima eiwitrijk tussendoortje.",
        "Groenten met veel water, zoals komkommer, bevatten weinig calorieën maar geven wel een verzadigd gevoel.",
        "Havermout bevat een combinatie van vezels en langzame koolhydraten. Dat geeft je langdurig energie — ideaal voor duursporters.",
        "Spieren groeien tijdens rust, niet tijdens de training zelf.",
        "Een dieetpauze na een lange cut kan je metabolisme helpen herstellen.",
        "Je gewicht kan van dag tot dag schommelen doordat je vocht vasthoudt.",
        "Progressive overload — geleidelijk zwaarder trainen — is de sleutel tot spiergroei.",
        "Slaap is net zo belangrijk voor een goed herstel als je voeding.",
        "Consistentie gedurende weken of maanden is belangrijker dan die ene perfecte dag of week.",
        "Krachttraining tijdens een cut helpt om je spiermassa te behouden. Goed om te weten.",
        "Een te agressief tekort leidt vaker tot terugval dan een gematigd tekort.",
        "Wist je dat de tomaat botanisch gezien een fruit is, maar in de keuken als groente wordt behandeld?",
        "Wist je dat honing praktisch niet kan bederven — archeologen vonden ooit potten honing van duizenden jaren oud die nog eetbaar waren?",
        "Wist je dat pinda's eigenlijk peulvruchten zijn, geen noten?",
        "Wist je dat wortels van oorsprong paars waren, niet oranje?",
        "Wist je dat je smaakpapillen zich ongeveer elke twee weken vernieuwen?",
        "Wist je dat chocolademelk in de 17e eeuw oorspronkelijk als medicijn werd verkocht?"
    ]

    /// Kiest een tip op basis van uur + dag, zodat 'm ook binnen één dag al verschuift i.p.v. steeds
    /// dezelfde tekst te tonen totdat de datum omslaat.
    static func tip(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return all[(dayOfYear * 24 + hour) % all.count]
    }

}

// MARK: - Bot-als-een-baksteen modus (algemene, plagerige berichten)

enum BluntCoachMessages {

    /// Alleen tonen als er nog niet gelogd is vandaag — anders klopt de tekst gewoon niet.
    static let loggingReminders: [String] = [
        "Nog niet gelogd? De kaboutertjes gaan het niet voor je doen.",
        "Alweer vergeten te loggen? Het zal eens niet.",
        "Niet lullen, maar loggen!"
    ]

    /// Altijd geldig, ongeacht of je vandaag al hebt gelogd.
    static let general: [String] = [
        "Wil je nou gains of niet? Doe wat je moet doen dan, hop!",
        "Dat vetpercentage gaat niet vanzelf omlaag. Aan de bak, joh.",
        "Consistentie. Ooit van gehoord? Dacht ik al."
    ]

    /// Botte versies van de 20 voedingsfeitjes uit NutritionTips — zelfde feit, met een plagerige staart.
    static let bluntFactTips: [String] = [
        "Een appel heeft zo'n 4 g vezels. Dus waar wacht je nog op?",
        "100 g kipfilet levert je zo'n 31 g eiwit. Aan de bak met die kip.",
        "Volkoren brood heeft meer vezels dan wit. Kies gewoon het volkoren, joh.",
        "Eén ei geeft je zo'n 6 g eiwit. Bak er nog eentje bij, hop.",
        "Linzen zitten vol eiwit én vezels. Kom op, in de pan ermee.",
        "Magere kwark is spotgoedkoop eiwit. Geen excuus meer.",
        "Een banaan heeft zo'n 3 g vezels. Eet 'm nou gewoon op.",
        "Vezels houden je langer vol. Dus eet ze, in plaats van erover te lezen.",
        "Noten zitten vol gezonde vetten. Neem een handje, geen hele zak.",
        "100 g Griekse yoghurt geeft je zo'n 10 g eiwit. Simpel, toch?",
        "Komkommer en co. vullen goed voor weinig calorieën. Snap je 'm?",
        "Havermout geeft je langdurig energie. Ideaal voor duursporters — dus waar wacht je nog op?",
        "Spieren groeien tijdens rust, niet tijdens de training. Ga dus ook echt slapen.",
        "Een dieetpauze na een lange cut helpt je metabolisme herstellen. Neem 'm dan ook echt.",
        "Je gewicht schommelt door vocht. Niet elke dag paniekeren, joh.",
        "Geleidelijk zwaarder trainen is de sleutel tot spiergroei. Dus voeg dat gewichtje toe.",
        "Slaap is net zo belangrijk als je voeding. Ga op tijd naar bed, dan.",
        "Consistentie over weken telt, niet die ene perfecte dag. Blijf dus gewoon doorgaan.",
        "Krachttraining tijdens een cut behoudt je spiermassa. Sla die training dus niet over.",
        "Een te streng tekort leidt vaker tot terugval. Rustig aan dus, ja?"
    ]

    static func message(for date: Date, hasLoggedToday: Bool) -> String {
        let pool = hasLoggedToday ? (general + bluntFactTips) : (loggingReminders + general + bluntFactTips)
        let hour = Calendar.current.component(.hour, from: date)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return pool[(dayOfYear * 24 + hour) % pool.count]
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

// MARK: - Nieuwe badge(s) behaald

struct BadgeUnlockBatch: Identifiable {
    let id = UUID()
    let badges: [BadgeTier]
}

struct NewBadgeSheet: View {

    let badges: [BadgeTier]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text(badges.count == 1 ? "Nieuwe badge!" : "Nieuwe badges!")
                .font(.title3.bold())
                .foregroundStyle(Color.wwDarkAccent)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(badges) { badge in
                        VStack(spacing: 10) {

                            ZStack {
                                Circle()
                                    .fill(Color.wwAqua.opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Circle()
                                    .stroke(Color.wwAqua, lineWidth: 3)
                                    .frame(width: 72, height: 72)
                                Text("🏅")
                                    .font(.system(size: 28))
                            }

                            Text(badge.name)
                                .font(.headline)
                                .foregroundStyle(Color.wwAqua)

                            Text(badge.message)
                                .font(.subheadline)
                                .foregroundStyle(Color.wwSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)

                        }
                    }
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Top!")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.wwTeal)

        }
        .padding(30)
        .presentationDetents([.medium, .large])
    }

}

// MARK: - Macro-uitklap (welke producten leverden hoeveel van een macro)

enum MacroBreakdownType: String, Identifiable, CaseIterable {
    case eiwit = "Eiwit"
    case koolhydraten = "Koolhydraten"
    case vet = "Vet"
    case vezels = "Vezels"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .eiwit: return .wwBlue
        case .koolhydraten: return .wwTeal
        case .vet: return .wwOrange
        case .vezels: return .wwMint
        }
    }

    func grams(from entry: FoodLogEntry) -> Double {
        switch self {
        case .eiwit: return entry.proteinGrams
        case .koolhydraten: return entry.carbsGrams
        case .vet: return entry.fatGrams
        case .vezels: return entry.fiberGrams
        }
    }
}

struct MacroBreakdownView: View {

    @State var initialMacro: MacroBreakdownType
    let date: Date
    let entries: [FoodLogEntry]

    @Environment(\.dismiss) private var dismiss

    private var contributions: [(name: String, grams: Double, count: Int)] {
        let grouped = Dictionary(grouping: entries, by: { $0.name })

        return grouped
            .map { name, items in
                (name: name, grams: items.reduce(0) { $0 + initialMacro.grams(from: $1) }, count: items.count)
            }
            .filter { $0.grams > 0 }
            .sorted { $0.grams > $1.grams }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                VStack(spacing: 16) {

                    Picker("Macro", selection: $initialMacro) {
                        ForEach(MacroBreakdownType.allCases) { macro in
                            Text(macro.rawValue).tag(macro)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 12)

                    if contributions.isEmpty {

                        WWPlaceholderCard(
                            icon: "chart.pie",
                            color: initialMacro.color,
                            title: "Nog niks gelogd",
                            message: "Zodra je iets logt met \(initialMacro.rawValue.lowercased()) erin, zie je hier welke producten het meest bijdroegen."
                        )
                        .padding(.horizontal)

                        Spacer()

                    } else {

                        ScrollView {

                            VStack(alignment: .leading, spacing: 0) {

                                ForEach(Array(contributions.enumerated()), id: \.element.name) { index, item in

                                    HStack {

                                        Text(item.count > 1 ? "\(item.name) (\(item.count)x)" : item.name)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.wwDarkAccent)

                                        Spacer()

                                        Text("\(item.grams.roundedInt) g")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(Color.wwMint)

                                    }
                                    .padding(.vertical, 10)

                                    if index < contributions.count - 1 {
                                        Divider()
                                    }

                                }

                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .wwCard()
                            .padding(.horizontal)

                        }

                    }

                }

            }
            .tint(Color.wwTeal)
            .navigationTitle("\(initialMacro.rawValue) — \(date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "nl_NL"))))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }

}
