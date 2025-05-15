//
//  MoonriseMoonset.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 28/03/2025.
//

import SwiftUI

struct MoonriseMoonsetView: View {
    let weatherData: WeatherData?

    var iconName: String {
        let (iconName, _) = getMoonPhaseIconAndName()
        
        return iconName
    }
    
    var moonPhaseName: String {
        let (_, moonPhaseName) = getMoonPhaseIconAndName()
        
        return moonPhaseName
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .symbolRenderingMode(.monochrome)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.white)
                .padding(.trailing)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(moonPhaseName)
                    .bold()
                
                MoonriseMoonsetItem(role: "moonrise", time: weatherData?.daily[0].moonrise, timezoneOffset: weatherData?.timezoneOffset)
                MoonriseMoonsetItem(role: "moonset", time: weatherData?.daily[0].moonset, timezoneOffset: weatherData?.timezoneOffset)
            }
        }
        .padding()
        .foregroundStyle(.white)
        .background(.tertiary.opacity(0.5))
        .clipShape(.rect(cornerRadius: 15))
    }
    
    private func getMoonPhaseIconAndName() -> (iconName: String, name: String) {
        guard let moonPhase = weatherData?.daily[0].moonPhase else {
            return ("", "")
        }
        
        if moonPhase == 0 || moonPhase == 1 {
            return ("moonphase.new.moon", "Nów")
        }
        if moonPhase < 0.25 {
            return ("moonphase.waxing.crescent", "Po nowiu")
        }
        if moonPhase == 0.25 {
            return ("moonphase.first.quarter", "Pierwsza kwadra")
        }
        if moonPhase < 0.5 {
            return ("moonphase.waxing.gibbous", "Po pierwszej kwadrze")
        }
        if moonPhase == 0.5 {
            return ("moonphase.full.moon", "Pełnia")
        }
        if moonPhase < 0.75 {
            return ("moonphase.waning.gibbous", "Po pełni")
        }
        if moonPhase == 0.75 {
            return ("moonphase.last.quarter", "Ostatnia kwadra")
        }
        if moonPhase < 1 {
            return ("moonphase.waning.crescent", "Po ostatniej kwadrze")
        }
        
        return ("", "")
    }
}

private struct MoonriseMoonsetItem: View {
    var role: String
    var time: Int?
    var timezoneOffset: Int?
    
    var body: some View {
        HStack {
            Text((role == "moonrise" ? "Wschód" : "Zachód") + " księżyca")
        
            Spacer()
            
            Text(Date.getFormattedHour(from: time ?? 0, with: timezoneOffset ?? 0))
                .bold()
        }
    }
}

#Preview {
    MoonriseMoonsetView(weatherData: SampleWeatherData().data)
}
