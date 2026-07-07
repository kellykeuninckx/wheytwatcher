import SwiftUI
import SwiftData
import Charts

struct ProgressViewScreen: View {

    let profile: UserProfile

    @Query(sort: \WeightLog.date) private var weightLogs: [WeightLog]
    @Query(sort: \FoodLogEntry.date) private var foodEntries: [FoodLogEntry]
    @Query(sort: \TrainingSession.date) private var trainings: [TrainingSession]
    @Query(sort: \DailyTargetSnapshot.date) private var snapshots: [DailyTargetSnapshot]

    @State private var selectedRange: ChartRange = .twoWeeks

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

    private var weightTrendPoints: [(date: Date, value: Double)] {
        guard filteredWeights.count >= 2,
              let referenceDate = filteredWeights.first?.date else { return [] }

        let xs = filteredWeights.map { $0.date.timeIntervalSince(referenceDate) / 86400 }
        let ys = filteredWeights.map { $0.weightKg }

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
            (date: filteredWeights.first!.date, value: slope * firstX + intercept),
            (date: filteredWeights.last!.date, value: slope * lastX + intercept)
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
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Progressie")
        }
    }

    // MARK: - Coach-kaart (1 roterend bericht per dag)

    private enum CoachMessageType: Int, CaseIterable {
        case traject, streak, voeding, gewicht, training
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
            guard let rate = weeklyWeightChangeRate, abs(rate) >= 0.05 else { return nil }
            let verb = rate < 0 ? "verliest" : "wint"
            return ("⚖️", "Je \(verb) gemiddeld \(formattedWeeklyRate(rate)) kg per week.")

        case .training:
            guard trainingsThisWeekCount > 0 else { return nil }
            return ("🏋️", "Je trainde deze week \(trainingsThisWeekCount) keer.")

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

    private var loggingStreak: Int {
        let loggedDaysSet = Set(foodEntries.map { Calendar.current.startOfDay(for: $0.date) })
        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())

        while loggedDaysSet.contains(day) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }

    private var proteinAdherenceThisWeek: (met: Int, total: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var met = 0
        var total = 0
        var day = currentWeekStart

        while day <= today {
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
        trainings.filter { $0.date >= currentWeekStart }.count
    }

    private var weeklyWeightChangeRate: Double? {
        let sixWeeksAgo = Calendar.current.date(byAdding: .day, value: -42, to: Date()) ?? Date.distantPast
        let recentWeights = weightLogs.filter { $0.date >= sixWeeksAgo }

        guard recentWeights.count >= 2, let referenceDate = recentWeights.first?.date else { return nil }

        let xs = recentWeights.map { $0.date.timeIntervalSince(referenceDate) / 86400 }
        let ys = recentWeights.map { $0.weightKg }

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

    private func formattedWeeklyRate(_ value: Double) -> String {
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
                        .foregroundStyle(Color.wwBlue)
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
    }

    // MARK: - Calorieën vs. doel

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
                    ForEach(dailyCalories.sorted(by: { $0.key < $1.key }), id: \.key) { day, calories in
                        BarMark(
                            x: .value("Datum", day, unit: .day),
                            y: .value("Calorieën", calories)
                        )
                        .foregroundStyle(Color.wwOrange.opacity(0.7))
                        .cornerRadius(3)
                    }
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
    }

    // MARK: - Eiwit-trend

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
    }

}

//  ProgressView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//
