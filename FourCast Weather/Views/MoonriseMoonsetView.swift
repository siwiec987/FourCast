//
//  MoonriseMoonset.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 28/03/2025.
//

import SwiftUI

struct MoonriseMoonsetView: View {
    let weatherData: WeatherData?

    var body: some View {
        HStack {
            Spacer()
            
            Image(systemName: getMoonPhaseIcon())
                .symbolRenderingMode(.monochrome)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
            
            Spacer()
            
            VStack {
                MoonriseMoonsetItem(role: "moonrise", time: weatherData?.daily[0].moonrise, timezoneOffset: weatherData?.timezoneOffset)
                MoonriseMoonsetItem(role: "moonset", time: weatherData?.daily[0].moonset, timezoneOffset: weatherData?.timezoneOffset)
            }
            
            Spacer()
        }
        .padding()
        .foregroundStyle(.white)
        .background(.tertiary.opacity(0.5))
        .clipShape(.rect(cornerRadius: 15))
    }
    
    private func getMoonPhaseIcon() -> String {
        guard let moonPhase = weatherData?.daily[0].moonPhase else {
            return ""
        }
        
        if moonPhase == 0 || moonPhase == 1 {
            return "moonphase.new.moon"
        }
        if moonPhase < 0.25 {
            return "moonphase.waxing.crescent"
        }
        if moonPhase == 0.25 {
            return "moonphase.first.quarter"
        }
        if moonPhase < 0.5 {
            return "moonphase.waxing.gibbous"
        }
        if moonPhase == 0.5 {
            return "moonphase.full.moon"
        }
        if moonPhase < 0.75 {
            return "moonphase.waning.gibbous"
        }
        if moonPhase == 0.75 {
            return "moonphase.last.quarter"
        }
        if moonPhase < 1 {
            return "moonphase.waning.crescent"
        }
        
        return ""
    }
}

private struct MoonriseMoonsetItem: View {
    var role: String
    var time: Int?
    var timezoneOffset: Int?
    
    var body: some View {
        HStack {
//                Image(systemName: role)
//                    .renderingMode(.original)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
            
            Text((role == "moonrise" ? "Wschód" : "Zachód") + " księżyca")
        
            Text(Date.getFormattedHour(from: time ?? 0, with: timezoneOffset ?? 0))
                .bold()
            
        }
//        .padding()
//        .foregroundStyle(.white)
//        .background(.tertiary.opacity(0.5))
//        .clipShape(.rect(cornerRadius: 15))
    }
}

#Preview {
    MoonriseMoonsetView(weatherData: SampleWeatherData().data)
}
