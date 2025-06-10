//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/05/2025.
//


// TODO: make clouds' movement according to speed and direction of the wind
import SwiftUI

struct BackgroundView: View {
    var weatherData: WeatherData?
    var style: Style = .allEffects
    
    #if DEBUG
    @State private var debugCloudThickness = Cloud.Thickness.regular
    @State private var debugTime = 0.0 
    @State private var useDebugTime = false
    @State private var useDebugCloudThickness = false
    
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
        guard let weatherData else { return 0.0 }
        
        let timeZone = TimeZone(secondsFromGMT: weatherData.timezoneOffset) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let startOfDay = calendar.startOfDay(for: .now)
        print("Time: \(startOfDay.timeIntervalSinceNow / 60/60)")
        return abs(startOfDay.timeIntervalSinceNow / 86_400)
    }
    
    var cloudThickness: Cloud.Thickness {
        #if DEBUG
        if useDebugCloudThickness {
            return debugCloudThickness
        }
        #endif
        guard let icon = weatherData?.current.weather.first?.icon else { return .regular }

        let result: Cloud.Thickness
        switch icon.dropLast() {
        case "02": result = .thin
        case "03": result = .light
        case "04": fallthrough
        case "09": fallthrough
        case "10": fallthrough
        case "11": result = .regular
        default: result = .none
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            let topStops = getStops(type: .top)
            let bottomStops = getStops(type: .bottom)
            LinearGradient(colors: [
                topStops.interpolated(amount: time),
                bottomStops.interpolated(amount: time)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            if style == .allEffects {
                CloudsView(
                    thickness: cloudThickness,
                    topTint: getCloudStops(for: topStops, type: .top).interpolated(amount: time),
                    bottomTint: getCloudStops(for: bottomStops, type: .bottom).interpolated(amount: time)
                )
            }
        }
        #if DEBUG
        .onChange(of: debugTime) {
            useDebugTime = true
        }
        .onChange(of: debugCloudThickness) {
            useDebugCloudThickness = true
        }
        .toolbar {
            Menu("Debug") {
                Toggle("Use debug cloud thickness", isOn: $useDebugCloudThickness)
                Picker("Thickness", selection: $debugCloudThickness) {
                    ForEach(Cloud.Thickness.allCases, id: \.self) { thickness in
                        Text(String(describing: thickness).capitalized)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Use debug time", isOn: $useDebugTime)
                Stepper("Time: \(formattedTime)", value: $debugTime, in: 0...1, step: 0.05)
            }
        }
        #endif
    }
    
    private func getStops(type: StopType) -> [Gradient.Stop] {
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
        
        let colorsDayNightStart: [String: [Color]] = [
            "01": [.clearSkyDayStart, .clearSkyNightStart],
            "02": [.fewCloudsDayStart, .fewCloudsNightStart],
            "03": [.scatteredCloudsDayStart, .scatteredCloudsNightStart],
            "04": [.brokenCloudsDayStart, .brokenCloudsNightStart],
            "09": [.showerRainDayStart, .showerRainNightStart],
            "10": [.rainDayStart, .rainNightStart],
            "11": [.thunderStormDayStart, .thunderStormNightStart],
            "13": [.snowDayStart, .snowNightStart],
            "50": [.mistDayStart, .mistNightStart],
        ]
        
        let colorsDayNightEnd: [String: [Color]] = [
            "01": [.clearSkyDayEnd, .clearSkyNightEnd],
            "02": [.fewCloudsDayEnd, .fewCloudsNightEnd],
            "03": [.scatteredCloudsDayEnd, .scatteredCloudsNightEnd],
            "04": [.brokenCloudsDayEnd, .brokenCloudsNightEnd],
            "09": [.showerRainDayEnd, .showerRainNightEnd],
            "10": [.rainDayEnd, .rainNightEnd],
            "11": [.thunderStormDayEnd, .thunderStormNightEnd],
            "13": [.snowDayEnd, .snowNightEnd],
            "50": [.mistDayEnd, .mistNightEnd],
        ]
        
        guard let weatherData else { return result }
        
        let timeZone = TimeZone(secondsFromGMT: weatherData.timezoneOffset) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunrise))
        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunset))

        let startOfDay = calendar.startOfDay(for: sunriseDate)

        let sunriseLocation = sunriseDate.timeIntervalSince(startOfDay) / 86_400
        let sunsetLocation = sunsetDate.timeIntervalSince(startOfDay) / 86_400
        
        guard let iconSubstring = weatherData.current.weather.first?.icon.dropLast() else { return result }
        let icon = String(iconSubstring)
        
        guard let colors = (type == .top) ? colorsDayNightStart[icon] : colorsDayNightEnd[icon] else { return result }
        
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
        
        print("Type: \(type)")
        print("Sunrise: \(sunriseLocation) = \(sunriseLocation * 24)")
        print("Sunset: \(sunsetLocation) = \(sunsetLocation * 24)")
        
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
        
        print(result)
        print(cloudTopColors)
        print(cloudBottomColors)
        return result
    }
    
    enum StopType {
        case top
        case bottom
    }
    
    enum Style {
        case gradientOnly
        case allEffects
    }
}

#Preview {
    NavigationStack {
        BackgroundView(weatherData: SampleWeatherData().data!)
    }
}
