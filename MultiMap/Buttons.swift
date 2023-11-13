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
            
            Button(action: {
                // Define the action you want to perform when the button is tapped
                locationViewModel.startTracking()
            }) {
                Text("Altitude: \(String(format: "%.0f", locationViewModel.altitude))")
                    .frame(minWidth: 0, maxWidth: .infinity) // Make the button expand to fill the space
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.bordered) // Apply the bordered button style if you wish
//            .onAppear {
//                locationViewModel.startTracking()
//            }

            
//            Text("\(String(format: "%.0f", locationViewModel.altitude))")
//                .padding(.vertical, 8) // Match vertical padding to the buttons' default
//                .padding(.horizontal, 16) // Match horizontal padding to the buttons' default
//                .frame(minHeight: 44) // Default minimum tap target for buttons in iOS
//                .background(Color.white)
//                .foregroundColor(.blue)
//                .font(.system(size: 17)) // Match the default font size of button labels
//                .clipShape(RoundedRectangle(cornerRadius: 8)) // Match the corner radius to the buttons' default
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.blue, lineWidth: 1) // Add a border similar to the bordered button style
//                )
//                .onAppear { locationViewModel.startTracking() }

        }
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
            searchResults = response?.mapItems ?? []
        }
    }
    
}
