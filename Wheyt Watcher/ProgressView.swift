import SwiftUI
import SwiftData
import Charts

struct ProgressViewScreen: View {

    let profile: UserProfile

    @Query(sort: \WeightLog.date) private var weightLogs: [WeightLog]
    @Query(sort: \FoodLogEntry.date) private var foodEntries: [FoodLogEntry]
    @Query(sort: \TrainingSession.date) private var trainings: [TrainingSession]
    @Query(sort: \DailyTargetSnapshot.date) private var snapshots: [DailyTargetSnapshot]
    @Query private var dayStatuses: [DayStatus]
    @Query(sort: \BodyMeasurementLog.date) private var measurementLogs: [BodyMeasurementLog]

    @AppStorage("wwShowBodyMeasurementsChart") private var showBodyMeasurementsChart = false

    @State private var selectedRange: ChartRange = .twoWeeks
    @State private var showingEnlargedWeight = false
    @State private var showingEnlargedCalories = false
    @State private var showingEnlargedProtein = false
    @State private var selectedMeasurementType: BodyMeasurementType = .waist
    @State private var showingEnlargedMeasurement = false

    enum ChartRange: String, CaseIterable, Identifiable {
        case twoWeeks = "14 dagen"
        case month = "30 dagen"
        case all = "Alles"

        var id: String { rawValue }

        var days: Int? {
            switch self {
            case .twoWeeks: return 14
            case .month: return 30
            case .all: return nil
            }
        }
    }

    private var rangeStartDate: Date {
        guard let days = selectedRange.days else { return Date.distantPast }
        return Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Date.distantPast
    }

    private var filteredWeights: [WeightLog] {
        weightLogs.filter { $0.date >= rangeStartDate }
    }

    private var filteredMeasurementLogs: [BodyMeasurementLog] {
        measurementLogs.filter { $0.date >= rangeStartDate }
    }

    private var filteredFood: [FoodLogEntry] {
        foodEntries.filter { $0.date >= rangeStartDate }
    }

    private var filteredTrainings: [TrainingSession] {
        trainings.filter { $0.date >= rangeStartDate }
    }

    private var filteredSnapshots: [DailyTargetSnapshot] {
        snapshots.filter { $0.date >= rangeStartDate }
    }

    // MARK: - Dagelijkse aggregatie

    private var dailyCalories: [Date: Double] {
        Dictionary(grouping: filteredFood) { Calendar.current.startOfDay(for: $0.date) }
            .mapValues { entries in entries.reduce(0) { $0 + $1.calories } }
    }

    private var dailyProtein: [Date: Double] {
        Dictionary(grouping: filteredFood) { Calendar.current.startOfDay(for: $0.date) }
            .mapValues { entries in entries.reduce(0) { $0 + $1.proteinGrams } }
    }

    private var dailyTargetProtein: [Date: Double] {
        Dictionary(grouping: filteredSnapshots) { Calendar.current.startOfDay(for: $0.date) }
            .compactMapValues { $0.first?.proteinGrams }
    }

    private var loggedDays: Set<Date> {
        Set(filteredFood.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private var totalDaysInRange: Int {
        guard let days = selectedRange.days else {
            let earliestDates = [weightLogs.first?.date, foodEntries.first?.date].compactMap { $0 }
            guard let earliest = earliestDates.min() else { return 1 }
            let span = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: earliest),
                to: Calendar.current.startOfDay(for: Date())
            ).day ?? 0
            return max(span + 1, 1)
        }
        return days
    }

    // MARK: - Gewichtstrend (kleinste-kwadraten regressie)

    /// Weegmomenten op gemarkeerde dagen (ziek/vakantie/rustdag) tellen niet mee in de trend —
    /// vaak vocht/ziekte-ruis, geen echte verandering in lichaamssamenstelling.
    private var trendEligibleWeights: [WeightLog] {
        let marked = Set(dayStatuses.map { Calendar.current.startOfDay(for: $0.date) })
        return filteredWeights.filter { !marked.contains(Calendar.current.startOfDay(for: $0.date)) }
    }

    /// Voortschrijdend (exponentieel) gemiddelde, zodat een piek van een paar dagen de trend niet
    /// laat schrikken — dezelfde aanpak die apps als Trendweight/Libra gebruiken.
    private func smoothedPoints(from logs: [WeightLog], alpha: Double = 0.2) -> [(date: Date, value: Double)] {
        let sorted = logs.sorted { $0.date < $1.date }
        guard !sorted.isEmpty else { return [] }

        var result: [(date: Date, value: Double)] = []
        var previous = sorted[0].weightKg

        for (index, log) in sorted.enumerated() {
            let smoothed = index == 0 ? log.weightKg : alpha * log.weightKg + (1 - alpha) * previous
            previous = smoothed
            result.append((date: log.date, value: smoothed))
        }

        return result
    }

    private var weightTrendPoints: [(date: Date, value: Double)] {
        let smoothed = smoothedPoints(from: trendEligibleWeights)

        guard smoothed.count >= 2,
              let referenceDate = smoothed.first?.date else { return [] }

        let xs = smoothed.map { $0.date.timeIntervalSince(referenceDate) / 86400 }
        let ys = smoothed.map { $0.value }

        let n = Double(xs.count)
        let sumX = xs.reduce(0, +)
        let sumY = ys.reduce(0, +)
        let sumXY = zip(xs, ys).reduce(0) { $0 + $1.0 * $1.1 }
        let sumXX = xs.reduce(0) { $0 + $1 * $1 }

        let denominator = n * sumXX - sumX * sumX
        guard denominator != 0, let firstX = xs.first, let lastX = xs.last else { return [] }

        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n

        return [
            (date: smoothed.first!.date, value: slope * firstX + intercept),
            (date: smoothed.last!.date, value: slope * lastX + intercept)
        ]
    }

    private var axisStride: Int {
        max(totalDaysInRange / 5, 1)
    }

    /// Grotere stap voor de smallere, naast-elkaar-staande grafieken (gewicht/eiwit),
    /// anders staan de datum-labels te dicht op elkaar.
    private var compactAxisStride: Int {
        max(totalDaysInRange / 3, 1)
    }

    var body: some View {
        NavigationStack {
            WWScreen(accent: .wwBlue) {
                ScrollView {
                    VStack(spacing: 16) {
                        rangePicker
                        progressCoachCard

                        HStack(alignment: .top, spacing: 16) {
                            weightCard
                            proteinCard
                        }

                        caloriesCard

                        if showBodyMeasurementsChart && !filteredMeasurementLogs.isEmpty {
                            bodyMeasurementsCard
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Progressie")
            .sheet(isPresented: $showingEnlargedWeight) {
                EnlargedChartSheet(title: "Gewicht") {
                    Chart {
                        weightChartMarks
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                            AxisValueLabel()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEnlargedCalories) {
                EnlargedChartSheet(title: "Calorieën") {
                    Chart {
                        caloriesChartMarks
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                            AxisValueLabel()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEnlargedProtein) {
                EnlargedChartSheet(title: "Eiwit-trend") {
                    Chart {
                        proteinChartMarks
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                            AxisValueLabel()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEnlargedMeasurement) {
                EnlargedChartSheet(title: selectedMeasurementType.rawValue) {
                    Chart {
                        measurementChartMarks
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                            AxisValueLabel()
                                .foregroundStyle(Color.wwDarkAccent.opacity(0.7))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Coach-kaart (1 roterend bericht per dag)

    private enum CoachMessageType: Int, CaseIterable {
        case traject, streak, voeding, gewicht, training, wandelen
    }

    private var dailyRotationIndex: Int {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return dayOfYear % CoachMessageType.allCases.count
    }

    private var coachMessage: (icon: String, text: String)? {
        let order = CoachMessageType.allCases
        for offset in 0..<order.count {
            let type = order[(dailyRotationIndex + offset) % order.count]
            if let message = coachMessage(for: type) {
                return message
            }
        }
        return nil
    }

    private func coachMessage(for type: CoachMessageType) -> (icon: String, text: String)? {
        switch type {

        case .traject:
            guard let period = profile.activeGoalPeriod else { return nil }
            return ("🎯", "Week \(period.currentWeekNumber) van \(period.durationWeeks), je ligt op schema.")

        case .streak:
            guard loggingStreak > 0 else { return nil }
            return ("🔥", "Je hebt al \(loggingStreak) \(loggingStreak == 1 ? "dag" : "dagen") op rij gelogd.")

        case .voeding:
            guard let adherence = proteinAdherenceThisWeek, adherence.total > 0 else { return nil }
            return ("🥩", "Je haalde deze week \(adherence.met) van de \(adherence.total) dagen je eiwitdoel.")

        case .gewicht:
            if let sudden = suddenWeightChange {
                let direction = sudden.kg < 0 ? "gedaald" : "gestegen"
                return ("💧", "Je gewicht is de afgelopen \(sudden.days) dagen best snel \(direction) (\(formattedOneDecimal(sudden.kg)) kg). Dat is meestal vocht of even minder fit zijn, geen echte verandering — je onderliggende trend telt, niet deze ene meting.")
            }

            guard let rate = weeklyWeightChangeRate, abs(rate) >= 0.05 else { return nil }
            let verb = rate < 0 ? "verliest" : "wint"
            return ("⚖️", "Je \(verb) gemiddeld \(formattedOneDecimal(rate)) kg per week.")

        case .training:
            guard trainingsThisWeekCount > 0 else { return nil }
            return ("🏋️", "Je trainde deze week \(trainingsThisWeekCount) keer.")

        case .wandelen:
            guard walkingHoursThisWeek > 0 else { return nil }
            return ("🚶", "Je hebt deze week \(formattedOneDecimal(walkingHoursThisWeek)) uur gewandeld. \(walkingDistanceEquivalent(hours: walkingHoursThisWeek))")

        }
    }

    private var progressCoachCard: some View {
        Group {
            if let message = coachMessage {
                HStack(alignment: .top, spacing: 10) {
                    Text(message.icon)
                        .font(.title3)

                    Text(message.text)
                        .font(.subheadline)
                        .foregroundStyle(Color.wwDarkAccent)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .wwCard()
            }
        }
    }

    private var currentWeekStart: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -6,
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Calendar.current.startOfDay(for: Date())
    }

    private var markedDaysSet: Set<Date> {
        Set(dayStatuses.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private var loggingStreak: Int {
        let loggedDaysSet = Set(foodEntries.map { Calendar.current.startOfDay(for: $0.date) })
        let marked = markedDaysSet
        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())

        while true {
            if loggedDaysSet.contains(day) {
                streak += 1
            } else if !marked.contains(day) {
                break
            }
            // gemarkeerde dag (ziek/vakantie/rustdag): telt niet mee, maar breekt de streak ook niet
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }

    private var proteinAdherenceThisWeek: (met: Int, total: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let marked = markedDaysSet

        var met = 0
        var total = 0
        var day = currentWeekStart

        while day <= today {

            if marked.contains(day) {
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = nextDay
                continue
            }

            let dayProtein = foodEntries
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.proteinGrams }

            if let targetProtein = snapshots.first(where: { calendar.isDate($0.date, inSameDayAs: day) })?.proteinGrams,
               targetProtein > 0 {
                total += 1
                if dayProtein >= targetProtein {
                    met += 1
                }
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        return total > 0 ? (met, total) : nil
    }

    private var trainingsThisWeekCount: Int {
        trainings.filter { $0.date >= currentWeekStart && $0.type != .walking }.count
    }

    private var walkingHoursThisWeek: Double {
        let totalMinutes = trainings
            .filter { $0.date >= currentWeekStart && $0.type == .walking }
            .reduce(0) { $0 + $1.durationMinutes }
        return Double(totalMinutes) / 60.0
    }

    /// Zet gewandelde uren om naar een leuke afstandsvergelijking, uitgaand van ~5 km/u.
    private func walkingDistanceEquivalent(hours: Double) -> String {
        let km = hours * 5.0

        let milestones: [(maxKm: Double, text: String)] = [
            (5, "Dat is ongeveer een rondje door de buurt."),
            (15, "Dat is ongeveer de afstand tussen Utrecht en Amersfoort."),
            (30, "Dat is ongeveer Den Haag naar Rotterdam."),
            (50, "Dat is ongeveer van Scheveningen naar Noordwijk én terug."),
            (80, "Dat is verder dan Amsterdam naar Utrecht én terug.")
        ]

        for milestone in milestones where km <= milestone.maxKm {
            return milestone.text
        }

        return "Dat is verder dan een marathon — knap gedaan!"
    }

    private var weeklyWeightChangeRate: Double? {
        let sixWeeksAgo = Calendar.current.date(byAdding: .day, value: -42, to: Date()) ?? Date.distantPast
        let marked = Set(dayStatuses.map { Calendar.current.startOfDay(for: $0.date) })
        let recentWeights = weightLogs.filter {
            $0.date >= sixWeeksAgo && !marked.contains(Calendar.current.startOfDay(for: $0.date))
        }

        let smoothed = smoothedPoints(from: recentWeights)

        guard smoothed.count >= 2, let referenceDate = smoothed.first?.date else { return nil }

        let xs = smoothed.map { $0.date.timeIntervalSince(referenceDate) / 86400 }
        let ys = smoothed.map { $0.value }

        let n = Double(xs.count)
        let sumX = xs.reduce(0, +)
        let sumY = ys.reduce(0, +)
        let sumXY = zip(xs, ys).reduce(0) { $0 + $1.0 * $1.1 }
        let sumXX = xs.reduce(0) { $0 + $1 * $1 }

        let denominator = n * sumXX - sumX * sumX
        guard denominator != 0 else { return nil }

        let slopePerDay = (n * sumXY - sumX * sumY) / denominator
        return slopePerDay * 7
    }

    /// Detecteert een opvallend snelle verandering (bv. door ziekte/vocht) in de laatste 5 dagen,
    /// zodat de coach een geruststellend bericht kan geven i.p.v. het gewone weekgemiddelde.
    private var suddenWeightChange: (kg: Double, days: Int)? {
        let calendar = Calendar.current
        let windowStart = calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date.distantPast
        let marked = Set(dayStatuses.map { calendar.startOfDay(for: $0.date) })

        let recent = weightLogs
            .filter { $0.date >= windowStart && !marked.contains(calendar.startOfDay(for: $0.date)) }
            .sorted { $0.date < $1.date }

        guard let first = recent.first, let last = recent.last, first.date != last.date else { return nil }

        let diff = last.weightKg - first.weightKg
        let days = calendar.dateComponents([.day], from: first.date, to: last.date).day ?? 0

        guard days > 0, days <= 5, abs(diff) >= 1.5 else { return nil }

        return (kg: diff, days: days)
    }

    private func formattedOneDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: abs(value))) ?? String(format: "%.1f", abs(value))
    }

    // MARK: - Periode-kiezer

    private var rangePicker: some View {
        Picker("Periode", selection: $selectedRange) {
            ForEach(ChartRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Gewicht

    @ChartContentBuilder
    private var weightChartMarks: some ChartContent {
        ForEach(filteredWeights) { log in
            PointMark(
                x: .value("Datum", log.date, unit: .day),
                y: .value("Gewicht", log.weightKg)
            )
            .foregroundStyle(Color.wwBlue.opacity(0.6))
            .symbolSize(20)
        }

        ForEach(weightTrendPoints, id: \.date) { point in
            LineMark(
                x: .value("Datum", point.date, unit: .day),
                y: .value("Trend", point.value)
            )
            .foregroundStyle(Color.wwTeal)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
    }

    private var weightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Gewicht")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.wwDarkAccent)

                Spacer()

                if let latest = filteredWeights.last?.weightKg {
                    Text("\(latest.roundedInt) kg")
                        .font(.caption.bold())
                        .foregroundStyle(Color.wwTeal)
                }
            }

            if filteredWeights.isEmpty {
                WWPlaceholderCard(
                    icon: "scalemass",
                    color: .wwBlue,
                    title: "Nog geen gewicht",
                    message: "Log je gewicht om je trend te zien."
                )
            } else {
                Chart {
                    weightChartMarks
                }
                .frame(height: 130)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: compactAxisStride)) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
        .contentShape(Rectangle())
        .onTapGesture {
            guard !filteredWeights.isEmpty else { return }
            showingEnlargedWeight = true
        }
    }

    // MARK: - Calorieën vs. doel

    @ChartContentBuilder
    private var caloriesChartMarks: some ChartContent {
        ForEach(dailyCalories.sorted(by: { $0.key < $1.key }), id: \.key) { day, calories in
            BarMark(
                x: .value("Datum", day, unit: .day),
                y: .value("Calorieën", calories)
            )
            .foregroundStyle(Color.wwOrange.opacity(0.7))
            .cornerRadius(3)
        }
    }

    private var caloriesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calorieën")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)

            if dailyCalories.isEmpty {
                WWPlaceholderCard(
                    icon: "flame",
                    color: .wwOrange,
                    title: "Nog geen data",
                    message: "Log maaltijden om je intake te zien."
                )
            } else {
                Chart {
                    caloriesChartMarks
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
            }
        }
        .wwCard()
        .contentShape(Rectangle())
        .onTapGesture {
            guard !dailyCalories.isEmpty else { return }
            showingEnlargedCalories = true
        }
    }

    // MARK: - Eiwit-trend

    @ChartContentBuilder
    private var proteinChartMarks: some ChartContent {
        ForEach(dailyProtein.sorted(by: { $0.key < $1.key }), id: \.key) { day, protein in
            LineMark(
                x: .value("Datum", day, unit: .day),
                y: .value("Eiwit", protein)
            )
            .foregroundStyle(Color.wwTeal)
            .symbol(.circle)
        }

        ForEach(dailyTargetProtein.sorted(by: { $0.key < $1.key }), id: \.key) { day, target in
            LineMark(
                x: .value("Datum", day, unit: .day),
                y: .value("Doel", target)
            )
            .foregroundStyle(Color.wwPurple.opacity(0.6))
            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
        }
    }

    private var proteinCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Eiwit-trend")
                .font(.subheadline.bold())
                .foregroundStyle(Color.wwDarkAccent)

            if dailyProtein.isEmpty {
                WWPlaceholderCard(
                    icon: "leaf",
                    color: .wwTeal,
                    title: "Nog geen data",
                    message: "Log maaltijden om je eiwit te zien."
                )
            } else {
                Chart {
                    proteinChartMarks
                }
                .frame(height: 130)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: compactAxisStride)) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
        .contentShape(Rectangle())
        .onTapGesture {
            guard !dailyProtein.isEmpty else { return }
            showingEnlargedProtein = true
        }
    }

    // MARK: - Lichaamsmaten (optioneel, uit te zetten in Profiel)

    private var availableMeasurementTypes: [BodyMeasurementType] {
        BodyMeasurementType.allCases.filter { type in
            filteredMeasurementLogs.contains { $0.value(for: type) != nil }
        }
    }

    private var measurementPoints: [(date: Date, value: Double)] {
        filteredMeasurementLogs.compactMap { log in
            guard let value = log.value(for: selectedMeasurementType) else { return nil }
            return (date: log.date, value: value)
        }
    }

    @ChartContentBuilder
    private var measurementChartMarks: some ChartContent {
        ForEach(measurementPoints, id: \.date) { point in
            LineMark(
                x: .value("Datum", point.date, unit: .day),
                y: .value(selectedMeasurementType.rawValue, point.value)
            )
            .foregroundStyle(Color.wwPurple)
            .symbol(.circle)
        }
    }

    private var bodyMeasurementsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Lichaamsmaten")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.wwDarkAccent)

                Spacer()

                Menu {
                    ForEach(availableMeasurementTypes) { type in
                        Button(type.rawValue) {
                            selectedMeasurementType = type
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedMeasurementType.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(Color.wwPurple)
                }

                if let latest = measurementPoints.last?.value {
                    Text("\(latest.roundedInt) cm")
                        .font(.caption.bold())
                        .foregroundStyle(Color.wwPurple)
                }
            }

            if measurementPoints.isEmpty {
                WWPlaceholderCard(
                    icon: "ruler",
                    color: .wwPurple,
                    title: "Geen data voor \(selectedMeasurementType.rawValue.lowercased())",
                    message: "Kies hierboven een andere maat, of log deze bij je volgende weegmoment."
                )
            } else {
                Chart {
                    measurementChartMarks
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.15))
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
                    }
                }
            }
        }
        .wwCard()
        .contentShape(Rectangle())
        .onTapGesture {
            guard !measurementPoints.isEmpty else { return }
            showingEnlargedMeasurement = true
        }
        .onAppear {
            if let first = availableMeasurementTypes.first,
               !availableMeasurementTypes.contains(selectedMeasurementType) {
                selectedMeasurementType = first
            }
        }
    }

}

//  ProgressView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

// MARK: - Uitvergrote grafiek (bij tikken op een kaart)

struct EnlargedChartSheet<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                VStack {
                    content
                        .frame(maxHeight: .infinity)
                        .padding()
                        .wwCard()

                    Spacer()
                }
                .padding()

            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }

        }
    }

}
