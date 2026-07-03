# FourCast

FourCast is a weather application for iOS built with SwiftUI.

It provides current weather conditions, hourly and daily forecasts for the user's current location and saved locations. The app also integrates weather information with calendar events, offers clothing recommendations, and supports Live Activities.

This project was created as part of an engineering thesis focused on the design and implementation of a weather application for the iOS platform.

## Technologies

- Swift
- SwiftUI
- OpenWeather One Call API
- CoreLocation
- MapKit
- EventKit
- WidgetKit
- ActivityKit
- BackgroundTasks
- UserDefaults
- Swift Testing

## Features

### Forecast

- Current weather conditions based on the device location
- Hourly and daily weather forecasts
- Weather details, including:
  - temperature
  - sunrise and sunset
  - moon phase, moonrise and moonset
  - wind speed
  - atmospheric pressure
  - humidity
  - UV index
  - visibility
- Clothing recommendations based on weather conditions and user preferences

<img width="320" alt="Weather View" src="https://github.com/user-attachments/assets/c74b0127-1b37-40f1-95b6-ae02a6cfd127" />

### Multiple Locations

- Support for multiple locations
- Search and add locations using MapKit
- Quickly switch between the current location and saved locations

<img width="320" alt="All Locations View " src="https://github.com/user-attachments/assets/fa6c2c64-58a3-4644-913e-2121ac078718" />

### Settings and Personalization

- Configurable temperature, wind speed, pressure, and distance units
- Customizable Live Activity start time for calendar events
- Clothing preferences used for personalized recommendations
- Local storage of user preferences and saved locations

<img width="320" alt="Settings View" src="https://github.com/user-attachments/assets/84c78313-ed15-43e7-bd05-8effb76914c2" />

### Live Activities

- Live Activity support for upcoming calendar events
- Event location
- Weather condition icon and expected temperature at the event start time
- Clothing recommendations based on the expected weather

**Lock Screen:**                                    
<img width="400" alt="Live Activity – Lock Screen" src="https://github.com/user-attachments/assets/615a82e5-1675-41e4-9eb4-314927ac139a" />


**Expanded:**                                    
<img width="400" alt="Live Activity – Expanded" src="https://github.com/user-attachments/assets/631dbf6e-d5c0-4b3d-adc6-3671b5abc8bb" />


**Compact:**                                    
<img width="400" alt="Live Activity – Compact" src="https://github.com/user-attachments/assets/c3fc69a1-89cf-4bef-8c0f-9646290fc0db" />
