//
//  Buttons.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import SwiftUI
import MapKit


struct Buttons: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    @ObservedObject var locationViewModel = LocationViewModel()
    @Binding var position: MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    
    var visibleRegion: MKCoordinateRegion?

    var body: some View {
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.bordered)
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.bordered)
                   
            Button {
                searchResults = []
            } label: {
                Label("Trash", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            
            Button {
                searchResults = []
                search(for: "Home")
            } label: {
                Label("HOME", systemImage: "homekit")
            }
            .buttonStyle(.bordered)
        
        
            Text("Altitude: \(String(format: "%.0f", locationViewModel.altitude)) m.s.l.")
                    .padding(.vertical, 8) // Match the vertical padding of the buttons
                
                    .frame(minWidth: 0, maxWidth: .infinity) // Make the Text expand to fill the space
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(.system(size: 17)) // Match the font size of the button labels
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Match the shape of the buttons
                    .overlay(
                        RoundedRectangle(cornerRadius: 8) // To match the border style of the buttons
                            .stroke(Color.orange, lineWidth: 1)
                    )
                    .onAppear { locationViewModel.startTracking() }

        }
        .padding(.trailing, 10)
        .labelStyle(.iconOnly)
    }
   
    func search(for query: String) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        guard let region = visibleRegion else { return }
        request.region = region
        
        Task {
               let search = MKLocalSearch(request: request)
               let response = try? await search.start()
               
               // Get the current search results
               var currentSearchResults = response?.mapItems ?? []
               
               // Create the "HOME" placemark with fixed coordinates

               let homeCoordinate = CLLocationCoordinate2D.myHome
               let homePlacemark = MKPlacemark(coordinate: homeCoordinate)
               let homeMapItem = MKMapItem(placemark: homePlacemark)
               homeMapItem.name = "HOME" // Set the name for the pin
               
               // Append the "HOME" map item to the current search results
               currentSearchResults.append(homeMapItem)
               
               // Update the searchResults with the current results including "HOME"
               searchResults = currentSearchResults
           }
    }
    
    
}

//Kitchensink

//Button(action: {
//                // Define the action you want to perform when the button is tapped
//                locationViewModel.startTracking()
//            }) {
//                Text("Altitude: \(String(format: "%.0f", locationViewModel.altitude)) m.s.l.")
//                    .frame(minWidth: 0, maxWidth: .infinity) // Make the button expand to fill the space
//                    .padding()
//                    .background(Color.orange)
//                    .foregroundColor(.white)
//                    .font(.system(size: 17))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            }
//            .buttonStyle(.bordered) // Apply the bordered button style if you wish
//            .onAppear { locationViewModel.startTracking() }



//    func search(for query: String) {
//
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = query
//        request.resultTypes = .pointOfInterest
//
//        guard let region = visibleRegion else { return }
//        request.region = region
//
//        Task {
//            let search = MKLocalSearch(request: request)
//            let response = try? await search.start()
//            searchResults = response?.mapItems ?? []
//        }
//    }
