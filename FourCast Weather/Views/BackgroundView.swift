//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/05/2025.
//

import SwiftUI

struct BackgroundView: View {
    let timezoneOffset: Int?
//    let weatherIcon: String?
    let weatherCondition: WeatherData.WeatherCondition.ConditionType?
    let sunrise: Int?
    let sunset: Int?
    let windSpeed: Double?
    let effects: Effects
    let miniature: Bool
    
    #if DEBUG
    @State private var debugCloudThickness = Cloud.Thickness.regular
    @State private var debugTime = 0.0 
    @State private var useDebugTime = false
    @State private var useDebugCloudThickness = false
    @State private var showingDebug = false
    @State private var debugStormType = Storm.Contents.rain
    @State private var useDebugStormType = false
    @State private var debugRainIntensity = 350.0
    @State private var useDebugRainIntensity = false
    @State private var debugWindSpeed = 0.0
    @State private var useDebugWindSpeed = false
    
    var useDebug: Binding<Bool> {
        Binding (
            get: {
                useDebugTime ||
                useDebugStormType ||
                useDebugWindSpeed ||
                useDebugRainIntensity ||
                useDebugCloudThickness
            },
            set: {
                if !$0 {
                    useDebugTime = false
                    useDebugStormType = false
                    useDebugWindSpeed = false
                    useDebugRainIntensity = false
                    useDebugCloudThickness = false
                }
            }
        )
    }
    
    var formattedTime: String {
        let start = Calendar.current.startOfDay(for: .now)
        let advanced = start.addingTimeInterval(debugTime * 24 * 60 * 60)
        return advanced.formatted(date: .omitted, time: .shortened)
    }
    #endif
    
    var time: Double {
        #if DEBUG
        if useDebugTime {
            return debugTime
        }
        #endif
        
        let timeZone = TimeZone(secondsFromGMT: timezoneOffset ?? 0) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let startOfDay = calendar.startOfDay(for: .now)
        return abs(startOfDay.timeIntervalSinceNow / 86_400)
    }
    
    var cloudThickness: Cloud.Thickness {
        #if DEBUG
        if useDebugCloudThickness {
            return debugCloudThickness
        }
        #endif

        guard let weatherCondition else { return .none }
        
        let result: Cloud.Thickness
        
        switch weatherCondition {
        case .fewClouds: result = .light
        case .clouds: result = .regular
        case .drizzle: result = .regular
        case .rain: result = .regular
        case .thunderstorm: result = .thick
        default: result = .thin
        }
        
        return result
    }
    
    var topColor: Color {
        getStops(type: .top).interpolated(amount: time)
    }
    
    var bottomColor: Color {
        getStops(type: .bottom).interpolated(amount: time)
    }
    
    var starOpacity: Double {
        let color = getStarStops(for: getStops(type: .top)).interpolated(amount: time)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(color)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return alpha
    }
    
    var stormType: Storm.Contents {
        #if DEBUG
        if useDebugStormType {
            return debugStormType
        }
        #endif
        
        guard let weatherCondition else { return .none }
        
        let result: Storm.Contents
        
        switch weatherCondition {
        case .drizzle: result = .rain
        case .rain: result = .rain
        case .thunderstorm: result = .rain
        case .snow: result = .snow
        default: result = .none
        }
        
        return result
    }
    
    var rainIntensity: Double {
        #if DEBUG
        if useDebugRainIntensity {
            return debugRainIntensity
        }
        #endif
        
        guard let weatherCondition else { return 350.0 }
        
        let result: Double
        
        switch weatherCondition {
        case .drizzle: result = 100
        case .rain: result = 300
        case .thunderstorm: result = 450
        case .snow: result = 250
        default: result = 350
        }
        
        return miniature ? result / 10 : result
    }
    
    var rainAngleWindSpeed: Double {
        #if DEBUG
        if useDebugWindSpeed {
            return debugWindSpeed
        }
        #endif
        
        guard let windSpeed, windSpeed > 0 else {
            return 0.001
        }
        
        return windSpeed
    }
    
    var rainAngle: Double {
        var result = atan(9 / rainAngleWindSpeed)
        result = result * 180 / .pi
        
        result = 90 - result
        
        return result
    }
    
    var body: some View {
        ZStack {
            if effects.contains(.gradient) {
                LinearGradient(colors: [
                    topColor,
                    bottomColor
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            }
            
            if effects.contains(.stars) {
                StarsView()
                    .opacity(starOpacity)
            }
            
            if effects.contains(.clouds) {
                CloudsView(
                    thickness: cloudThickness,
                    topTint: getCloudStops(for: getStops(type: .top), type: .top).interpolated(amount: time),
                    bottomTint: getCloudStops(for: getStops(type: .bottom), type: .bottom).interpolated(amount: time)
                )
            }
            
            if effects.contains(.storm) && stormType != .none {
                StormView(type: stormType, direction: .degrees(rainAngle), strength: Int(rainIntensity))
            }
        }
        #if DEBUG
        .onChange(of: debugTime) {
            useDebugTime = true
        }
        .onChange(of: debugCloudThickness) {
            useDebugCloudThickness = true
        }
        .onChange(of: debugStormType) {
            useDebugStormType = true
        }
        .onChange(of: debugRainIntensity) {
            useDebugRainIntensity = true
            useDebugStormType = true
        }
        .onChange(of: debugWindSpeed) {
            useDebugWindSpeed = true
            useDebugStormType = true
        }
        .toolbar {
            if !miniature {
                ToolbarItem(placement: .bottomBar) {
                    Button("Debug") {
                        showingDebug.toggle()
                    }
                }
            }
        }
        .onTapGesture(count: 2) {
            if miniature {
                showingDebug.toggle()
            }
        }
        .sheet(isPresented: $showingDebug) {
            Form {
                Toggle("Enable debug", isOn: useDebug)
                Section("CLOUDS") {
                    Toggle("Use debug cloud thickness", isOn: $useDebugCloudThickness)
                    Picker("Thickness", selection: $debugCloudThickness) {
                        ForEach(Cloud.Thickness.allCases, id: \.self) { thickness in
                            Text(String(describing: thickness).capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("STORM") {
                    Toggle("Use debug storm type", isOn: $useDebugStormType)
                    Picker("Type", selection: $debugStormType) {
                        ForEach(Storm.Contents.allCases, id: \.self) { stormType in
                            Text(String(describing: stormType).capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Use debug rain intensity", isOn: $useDebugRainIntensity)
                    Text("Intensity: \(debugRainIntensity)")
                    Slider(value: $debugRainIntensity, in: 0...1000)
                    Toggle("Use debug wind speed", isOn: $useDebugWindSpeed)
                    Text("Wind speed: \(debugWindSpeed)")
                    Slider(value: $debugWindSpeed, in: 0...150)
                }
                
                Section("TIME") {
                    Toggle("Use debug time", isOn: $useDebugTime)
                    Text("Time: \(formattedTime)")
                    Slider(value: $debugTime, in: 0...1)
                }
            }
            .presentationDetents([.medium])
        }
        #endif
    }
    
    private func getStops(type: StopType, default: Bool = false) -> [Gradient.Stop] {
        let resultTop: [Gradient.Stop] = [
            .init(color: .clearSkyNightStart, location: 0),
            .init(color: .clearSkyNightStart, location: 0.25),
            .init(color: .sunriseStart, location: 0.33),
            .init(color: .clearSkyDayStart, location: 0.38),
            .init(color: .clearSkyDayStart, location: 0.7),
            .init(color: .sunsetStart, location: 0.78),
            .init(color: .clearSkyNightStart, location: 0.82),
            .init(color: .clearSkyNightStart, location: 1)
        ]
        
        let resultBottom: [Gradient.Stop] = [
            .init(color: .clearSkyNightEnd, location: 0),
            .init(color: .clearSkyNightEnd, location: 0.25),
            .init(color: .sunriseEnd, location: 0.33),
            .init(color: .clearSkyDayEnd, location: 0.38),
            .init(color: .clearSkyDayEnd, location: 0.7),
            .init(color: .sunsetEnd, location: 0.78),
            .init(color: .clearSkyNightEnd, location: 0.82),
            .init(color: .clearSkyNightEnd, location: 1)
        ]
        
        var result = (type == .top) ? resultTop : resultBottom
        
        guard let timezoneOffset else { return result }
        guard let weatherCondition else { return result }
        guard let sunrise else { return result }
        guard let sunset else { return result }
        
        let colorsDayNightStart: [WeatherData.WeatherCondition.ConditionType: [Color]] = [
            .clear(isDaytime: true): [.clearSkyDayStart, .clearSkyNightStart],
            .fewClouds(isDaytime: true): [.fewCloudsDayStart, .fewCloudsNightStart],
            .clouds: [.brokenCloudsDayStart, .brokenCloudsNightStart],
            .drizzle: [.showerRainDayStart, .showerRainNightStart],
            .rain: [.rainDayStart, .rainNightStart],
            .thunderstorm: [.thunderStormDayStart, .thunderStormNightStart],
            .snow: [.snowDayStart, .snowNightStart],
            .haze(isDaytime: true): [.mistDayStart, .mistNightStart],
        ]
        
        let colorsDayNightEnd: [WeatherData.WeatherCondition.ConditionType: [Color]] = [
            .clear(isDaytime: false): [.clearSkyDayEnd, .clearSkyNightEnd],
            .fewClouds(isDaytime: false): [.fewCloudsDayEnd, .fewCloudsNightEnd],
            .clouds: [.brokenCloudsDayEnd, .brokenCloudsNightEnd],
            .drizzle: [.showerRainDayEnd, .showerRainNightEnd],
            .rain: [.rainDayEnd, .rainNightEnd],
            .thunderstorm: [.thunderStormDayEnd, .thunderStormNightEnd],
            .snow: [.snowDayEnd, .snowNightEnd],
            .haze(isDaytime: false): [.mistDayEnd, .mistNightEnd],
        ]
        
        let timeZone = TimeZone(secondsFromGMT: timezoneOffset) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(sunrise))
        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(sunset))

        let startOfDay = calendar.startOfDay(for: sunriseDate)

        let sunriseLocation = sunriseDate.timeIntervalSince(startOfDay) / 86_400
        let sunsetLocation = sunsetDate.timeIntervalSince(startOfDay) / 86_400
        
        guard let colors = (type == .top) ? colorsDayNightStart[weatherCondition] : colorsDayNightEnd[weatherCondition] else { return result }
        
        let day = colors[0]
        let night = colors[1]
        
        let sunriseColor: Color = (type == .top) ? .sunriseStart : .sunriseEnd
        let sunsetColor: Color = (type == .top) ? .sunsetStart : .sunsetEnd
        
        result = [
            .init(color: night, location: 0),
            .init(color: night, location: sunriseLocation - 0.05),
            .init(color: sunriseColor, location: sunriseLocation),
            .init(color: day, location: sunriseLocation + 0.05),
            .init(color: day, location: sunsetLocation - 0.05),
            .init(color: sunsetColor, location: sunsetLocation),
            .init(color: night, location: sunsetLocation + 0.05),
            .init(color: night, location: 1)
        ]
        
        return result
    }
    
    private func getCloudStops(for backgroundStops: [Gradient.Stop], type: StopType) -> [Gradient.Stop] {
        let cloudTopColors: [Color] = [
            .darkCloudStart,
            .darkCloudStart,
            .sunriseCloudStart,
            .lightCloudStart,
            .lightCloudStart,
            .sunsetCloudStart,
            .darkCloudStart,
            .darkCloudStart
        ]
        
        let cloudBottomColors: [Color] = [
            .darkCloudEnd,
            .darkCloudEnd,
            .sunriseCloudEnd,
            .lightCloudEnd,
            .lightCloudEnd,
            .sunsetCloudEnd,
            .darkCloudEnd,
            .darkCloudEnd
        ]
        
        let result: [Gradient.Stop]
        
        var i = -1
        switch type {
        case .top:
            result = backgroundStops.map { stop in
                i += 1
                return Gradient.Stop(color: cloudTopColors[i], location: stop.location)
            }
        case .bottom:
            result = backgroundStops.map { stop in
                i += 1
                return Gradient.Stop(color: cloudBottomColors[i], location: stop.location)
            }
        }
        
        return result
    }
    
    private func getStarStops(for backgroundStops: [Gradient.Stop]) -> [Gradient.Stop] {
        let starColors: [Color] = [
            .white,
            .white,
            .clear,
            .clear,
            .clear,
            .clear,
            .white,
            .white
        ]
        
        let result: [Gradient.Stop]
        
        var i = -1
        result = backgroundStops.map { stop in
            i += 1
            return Gradient.Stop(color: starColors[i], location: stop.location)
        }
        
        return result
    }
    
    enum StopType {
        case top
        case bottom
    }
    
    struct Effects: OptionSet {
        let rawValue: Int
        
        static let gradient = Effects(rawValue: 1 << 0)
        static let clouds = Effects(rawValue: 1 << 1)
        static let stars = Effects(rawValue: 1 << 2)
        static let storm = Effects(rawValue: 1 << 3)
        
        static let all: Effects = [.gradient, .stars, .clouds, .storm]
    }
    
    init(
        timezoneOffset: Int? = nil,
        weatherCondition: WeatherData.WeatherCondition.ConditionType? = nil,
        sunrise: Int? = nil,
        sunset: Int? = nil,
        windSpeed: Double? = nil,
        effects: Effects = .all,
        miniature: Bool = false,
        debugCloudThickness: Cloud.Thickness = .regular,
        debugTime: Double = 0.0,
        useDebugTime: Bool = false,
        useDebugCloudThickness: Bool = false
    ) {
        self.timezoneOffset = timezoneOffset
        self.weatherCondition = weatherCondition
        self.sunrise = sunrise
        self.sunset = sunset
        self.effects = effects
        self.debugCloudThickness = debugCloudThickness
        self.debugTime = debugTime
        self.useDebugTime = useDebugTime
        self.useDebugCloudThickness = useDebugCloudThickness
        self.windSpeed = windSpeed
        self.miniature = miniature
    }
}

#Preview {
    NavigationStack {
//        BackgroundView(weatherData: SampleWeatherData().data!)
    }
}
