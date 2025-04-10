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
        VStack {
            Text(data.location ?? "pusto")
            Text("\(data.structuredLocation.unsafelyUnwrapped.geoLocation.unsafelyUnwrapped.coordinate)")
        }
        .onAppear{print("kalendarz sie pojawia")}
    }
}

#Preview {
    let data = EKEvent(eventStore: EKEventStore())
    data.title = "AAA"
//    data.loca

    return CalendarView(data: data)
        .preferredColorScheme(.dark)
}
