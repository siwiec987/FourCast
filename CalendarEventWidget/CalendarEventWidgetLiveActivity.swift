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
        var temperature: String
//        var iconName: String
        var weatherCondition: WeatherData.WeatherCondition.ConditionType
        
        var timezoneOffset: Int?
//        var weatherIcon: String?
        var sunrise: Int?
        var sunset: Int?
    }

    // Fixed non-changing properties about your activity go here!
}

struct CalendarEventWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CalendarEventWidgetAttributes.self) { context in
            let backgroundView = BackgroundView(timezoneOffset: context.state.timezoneOffset, weatherCondition: context.state.weatherCondition, sunrise: context.state.sunrise, sunset: context.state.sunset, effects: .gradient)
            
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Text(context.state.name)
                        .fontWeight(.semibold)
                        
                    Spacer()
                    
                    Text(context.state.temperature)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Image(systemName: context.state.weatherCondition.iconName)
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
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack {
                        ForEach(0..<6) { _ in
                            Image(systemName: "dog.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            .padding(10)
            .activityBackgroundTint(backgroundView.topColor)
            .foregroundStyle(.white)
            .background(backgroundView)
            

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
                    HStack(spacing: 5) {
                        Text(context.state.temperature)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                        
                        Image(systemName: context.state.weatherCondition.iconName)
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
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack {
                            ForEach(0..<6) { _ in
                                Image(systemName: "dog.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .scaledToFit()
                    }
                }
            } compactLeading: {
                Text(timerInterval: Date.now...context.state.eventDate, pauseTime: nil)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 55)
                    .foregroundStyle(.secondary)
            } compactTrailing: {
                HStack(spacing: 2) {
                    Text(context.state.temperature)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Image(systemName: context.state.weatherCondition.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: 60, alignment: .trailing)
            } minimal: {
                Image(systemName: context.state.weatherCondition.iconName)
                    .font(.system(size: 18))
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
        CalendarEventWidgetAttributes.ContentState(eventDate: Date().addingTimeInterval(60 * 10), name: "Bedzinska 39", temperature: "19°", weatherCondition: .clouds)
     }
    
    fileprivate static var fiveHours: CalendarEventWidgetAttributes.ContentState {
        CalendarEventWidgetAttributes.ContentState(eventDate: Date().addingTimeInterval(60 * 60 * 5), name: "Bedzinska 39", temperature: "109°", weatherCondition: .clouds)
     }
}

#Preview("Notification", as: .content, using: CalendarEventWidgetAttributes.preview) {
   CalendarEventWidgetLiveActivity()
} contentStates: {
//    CalendarEventWidgetAttributes.ContentState.tenMins
    CalendarEventWidgetAttributes.ContentState.fiveHours
}
