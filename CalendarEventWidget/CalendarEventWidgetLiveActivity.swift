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
        var eventDate: Date
        var name: String
        var temperature: Int
        var iconName: String
        
        var timezoneOffset: Int?
        var weatherIcon: String?
        var sunrise: Int?
        var sunset: Int?
    }

    // Fixed non-changing properties about your activity go here!
}

struct CalendarEventWidgetLiveActivity: Widget {
    let minScaleFactor = 1.0
    let frameHeight: CGFloat = 70
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CalendarEventWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Text(context.state.name)
                        .fontWeight(.semibold)
                        
                    Spacer()
                    
                    Text("\(context.state.temperature)°")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Image(systemName: context.state.iconName)
//                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .padding(.bottom, -15)
                
                HStack(alignment: .lastTextBaseline) {
                    Text(timerInterval: Date.now...context.state.eventDate, pauseTime: nil)
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        ForEach(0..<3) { _ in
                            Image(systemName: "dog.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .scaledToFit()
                }
            }
            .padding(10)
            .activityBackgroundTint(Color.blue)
            .foregroundStyle(.white)
            .background(BackgroundView(timezoneOffset: context.state.timezoneOffset, weatherIcon: context.state.weatherIcon, sunrise: context.state.sunrise, sunset: context.state.sunset, effects: .gradientOnly))
            

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.name)
                        .fontWeight(.semibold)
                        .padding(.leading, 5)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text("\(context.state.temperature)°")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding(.trailing, -5)
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                        
                        Image(systemName: context.state.iconName)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .padding(.trailing, 5)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(timerInterval: Date.now...context.state.eventDate, pauseTime: nil)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        HStack {
                            ForEach(0..<3) { _ in
                                Image(systemName: "dog.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .scaledToFit()
                    }
                }
            } compactLeading: {
//                Text(timerInterval: Date.now...context.state.eventDate, pauseTime: nil)
                Text(context.state.name)
                    .font(.caption2)
//                    .bold()
            } compactTrailing: {
                HStack {
                    Text("\(context.state.temperature)°")
                        .fontWeight(.semibold)
                        .padding(.trailing, -5)
                    
                    Image(systemName: context.state.iconName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 20)
                }
            } minimal: {
                Image(systemName: context.state.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .overlay {
                        Text("\(context.state.temperature)°")
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 1.5)
                    }
            }
        }
    }
}

extension CalendarEventWidgetAttributes {
    fileprivate static var preview: CalendarEventWidgetAttributes {
        CalendarEventWidgetAttributes()
    }
}

extension CalendarEventWidgetAttributes.ContentState {
    fileprivate static var tenMins: CalendarEventWidgetAttributes.ContentState {
//        CalendarEventWidgetAttributes.ContentState(emoji: "😀")
        CalendarEventWidgetAttributes.ContentState(eventDate: Date().addingTimeInterval(60 * 10), name: "Bedzinska 39", temperature: 19, iconName: "cloud.fill")
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
