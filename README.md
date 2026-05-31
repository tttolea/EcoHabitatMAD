# EcoHabitat Reserve Operations Center


## Description
This application has been developed to assist environmental inspectors with logging, tracking, and simulating ecological reserves. 
EcoHabitat allows users to track the reserve's health via an interactive dashboard, geolocate anomalies directly on an OpenStreetMap, and securely sync findings. 
The primary aim of this project is to gamify and raise environmental awareness based on local climate data.

While there are many similar tracking applications, EcoHabitat stands out due to its real-time OpenWeather API integration and offline local SQLite caching for field operations in remote areas.

## Features
**Functional Features:**
* Live ecosystem simulation based on environmental metrics.
* Interactive OpenStreetMap with live GPS geolocation.
* Real-time weather data integration for accurate tracking.
* Field log capturing and exporting to CSV.

**Technical Features:**
* Persistence in SQLite (Room-equivalent for Flutter) to store historical logs.
* Persistence in CSV files (export and share via `share_plus`).
* Firebase Authentication (Email/Password registration).
* Maps integration via `flutter_map` and OpenStreetMap.
* External RESTful API usage (OpenWeather API).
* Sensors: Live GPS coordinates tracking via `geolocator`.

## How to Use
When launching the app, users must authenticate via the Firebase login screen. Once logged in, the inspector can navigate the four main modules:
1. **Dashboard:** Monitor ecosystem health and simulate environmental anomalies.
2. **Field Map:** Geolocate your position and log physical observations to the local database.
3. **Rank Score:** View a chronological history of logs and export them to a CSV file.
4. **Config Panel:** Update API tokens and inspector details using SharedPreferences.

## Participants
**Developer:** Tudor-Andrei Țolea
**Developer:** Andrei-Horia Cretu

## Releases
* **v1.0.0** - Final release (Includes Firebase, OpenStreetMap, REST API, SQLite, and CSV export).
