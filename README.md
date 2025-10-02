# PlaceNotes

A convenient app for the iOS platform to record notes, set reminders for locations, and visualising them on a map.
This app is designed for the iPhone 16 or higher.

Every note the user makes can act as a time-wise reminder or as a way to keep track of important nearby locations on the map.
Any number of notes can be attached to important places, and some of these places can be marked as a favourite.
The map tool can be used to add notes to new places nearby, while also visualising where existing notes have been attached.

All version control and commit history for **PlaceNotes** can be found in this [GitHub repository](https://github.com/TianLangHin/PlaceNotes).

## Core Functionalities

* View and edit notes while keeping track of their urgency,
* Visualise favourite locations and existing notes on a map,
* Browsing through notes and locations through a search bar.

## Dependencies

* Swift/SwiftUI 5.9 and iOS 17+ language Features
* MapKit package (SwiftUI)
* SQLite3 package (Swift)
* [Geoapify API](https://apidocs.geoapify.com), specifically the Geocoding and Places API.

## Minimum Deployment

The minimum deployment of this project is iOS 18.1.

## Usage and Starting Up Details

To enable the usage of the app, the user must first create a Geoapify API Key and place it in the `PlaceNotes/ApiKey.swift` file.
The steps for this are as follows:

1. Go to [Geoapify.com](https://www.geoapify.com) and **log in**. If the user does not have an account, sign up with an email to make one.
2. Add a new project (with any project name) and press **OK**.
3. The user will be redirected to the project's page, which will come with an automatically generated API Key at the top of the page.
(If an API key is not present, generate one by clicking the `+` button.)
4. Copy the API key to the keyboard, and place it as the value of a global `API_KEY` immutable variable in `PlaceNotes/ApiKey.swift`.
For example, if this key has the value `1234567890abcdef`,
the user must add the line `let API_KEY = "1234567890abcdef"` to that file.


