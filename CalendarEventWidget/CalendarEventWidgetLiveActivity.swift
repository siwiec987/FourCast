//
//  CalendarEventWidgetLiveActivity.swift
//  CalendarEventWidget
//
//  Created by Jakub Siwiec on 21/04/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CalendarEventWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
//        var emoji: String
        var endTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CalendarEventWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CalendarEventWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.name)
                        
//                    Text(context.state.endTime, style: .timer)
                    Text(timerInterval: Date.now...context.state.endTime, pauseTime: nil)
                        .bold()
                }
                
                Spacer()
                
//                HStack {
//                    if let data = SampleWeatherData().data {
//                        HourlyForecastItem(hourlyForecast: data.hourly[10], timezoneOffset: data.timezoneOffset)
//                        HourlyForecastItem(hourlyForecast: data.hourly[11], timezoneOffset: data.timezoneOffset)
//                        HourlyForecastItem(hourlyForecast: data.hourly[12], timezoneOffset: data.timezoneOffset)
//                    }
//                }
//                .scaleEffect(0.8)
            }
            .padding(.leading)
//            .activityBackgroundTint(Color.red)
//            .activitySystemActionForegroundColor(Color.white)
            .foregroundStyle(.white)
            .background(BackgroundView())
            

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.endTime)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.endTime)")
            } minimal: {
                Image(systemName: "cloud.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
    }
}

extension CalendarEventWidgetAttributes {
    fileprivate static var preview: CalendarEventWidgetAttributes {
        CalendarEventWidgetAttributes(name: "Będzińska 39")
    }
}

extension CalendarEventWidgetAttributes.ContentState {
    fileprivate static var tenMins: CalendarEventWidgetAttributes.ContentState {
//        CalendarEventWidgetAttributes.ContentState(emoji: "😀")
        CalendarEventWidgetAttributes.ContentState(endTime: Date().addingTimeInterval(60 * 10))
     }
     
//     fileprivate static var starEyes: CalendarEventWidgetAttributes.ContentState {
//         CalendarEventWidgetAttributes.ContentState(emoji: "🤩")
//     }
}

#Preview("Notification", as: .content, using: CalendarEventWidgetAttributes.preview) {
   CalendarEventWidgetLiveActivity()
} contentStates: {
    CalendarEventWidgetAttributes.ContentState.tenMins
//    CalendarEventWidgetAttributes.ContentState.starEyes
}
