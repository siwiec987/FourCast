//
//  CalendarView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 10/04/2025.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    var data: EKEvent
    
    var body: some View {
        WeatherView(weatherData: SampleWeatherData().data)
    }
}

#Preview {
    let data = EKEvent(eventStore: EKEventStore())
    data.title = "AAA"
//    data.loca

    return CalendarView(data: data)
        .preferredColorScheme(.dark)
}

//TODO
//pogodę pobierz dla lokalizacji
//wymyśl w jaki sposób chcesz te wydarzenia obsługiwać (kiedy wyświetlasz jakie itp)
//potem wymyśl co chcesz dalej zrobić
