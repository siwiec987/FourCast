//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/05/2025.
//

import SwiftUI

struct BackgroundView: View {
    var weatherData: WeatherData?
    
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
            LinearGradient(colors: [
                getStops(for: .top).interpolated(amount: time),
                getStops(for: .bottom).interpolated(amount: time)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            CloudsView(thickness: cloudThickness)
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
    
    private func getStops(for type: StopType) -> [Gradient.Stop] {
        var result: [Gradient.Stop] = [
            .init(color: .clearSkyNightStart, location: 0),
            .init(color: .clearSkyNightStart, location: 0.25),
            .init(color: .clearSunriseStart, location: 0.33),
            .init(color: .clearSkyDayStart, location: 0.38),
            .init(color: .clearSkyDayStart, location: 0.7),
            .init(color: .clearSunsetStart, location: 0.78),
            .init(color: .clearSkyNightStart, location: 0.82),
            .init(color: .clearSkyNightStart, location: 1)
        ]
        
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
        
        guard let weatherData else { print("weatherData sie wywaliło"); return result }
        
        let timeZone = TimeZone(secondsFromGMT: weatherData.timezoneOffset) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunrise))
        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunset))

        let startOfDay = calendar.startOfDay(for: sunriseDate)

        let sunriseLocation = sunriseDate.timeIntervalSince(startOfDay) / 86_400
        let sunsetLocation = sunsetDate.timeIntervalSince(startOfDay) / 86_400
        
        guard let iconSubstring = weatherData.current.weather.first?.icon.dropLast() else { print("icon = ... sie wywaliło"); return result }
        let icon = String(iconSubstring)
        
        guard let colors = (type == .top) ? colorsDayNightStart[icon] : colorsDayNightEnd[icon] else { print("colors = ... sie wywaliło"); return result }
        
        let day = colors[0]
        let night = colors[1]
        
        result = [
            .init(color: night, location: 0),
            .init(color: night, location: sunriseLocation - 0.05),
            .init(color: .clearSunriseStart, location: sunriseLocation),
            .init(color: day, location: sunriseLocation + 0.05),
            .init(color: day, location: sunsetLocation - 0.05),
            .init(color: .clearSunsetStart, location: sunsetLocation),
            .init(color: night, location: sunsetLocation + 0.05),
            .init(color: night, location: 1)
        ]
        
        print("Type: \(type)")
        print("Sunrise: \(sunriseLocation) = \(sunriseLocation * 86400/60/60)")
        print("Sunset: \(sunsetLocation) = \(sunsetLocation * 86400/60/60)")
        
        return result
    }
    
    enum StopType {
        case top
        case bottom
    }
}

#Preview {
    NavigationStack {
        BackgroundView(weatherData: SampleWeatherData().data!)
    }
}
