//
//  CalendarEventView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 10/04/2025.
//

import SwiftUI
import EventKit

struct CalendarEventView: View {
    var weatherData: WeatherData?
    var data: EKEvent
    
    var body: some View {
        WeatherView(weatherData: weatherData)
    }
}

#Preview {
    let data = EKEvent(eventStore: EKEventStore())
    data.title = "AAA"
//    data.loca

    return CalendarEventView(weatherData: SampleWeatherData().data, data: data)
        .preferredColorScheme(.dark)
}

//TODO
//pogodę pobierz dla lokalizacji
//wymyśl w jaki sposób chcesz te wydarzenia obsługiwać (kiedy wyświetlasz jakie itp)
//potem wymyśl co chcesz dalej zrobić
