//
//  ItemInfoView.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import SwiftUI
import MapKit


struct ItemInfoView: View {
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    var selectedResult: MKMapItem
    var route: MKRoute?

    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }

    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                    if let travelDistance {
                        Text(travelDistance)
                    }
                    if let tollImage = tollImage {
                        tollImage
                            .resizable() // Make the image resizable
                            .scaledToFit() // Scale the image to fit the frame
                            .frame(width: 30, height: 30) // Set the frame of the image
                            // Additional modifiers as needed
                    }
                    if let highwayImage = highwayImage {
                        highwayImage
                            .resizable() // Make the image resizable
                            .scaledToFit() // Scale the image to fit the frame
                            .frame(width: 30, height: 30) // Set the frame of the image
                            // Additional modifiers as needed
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        
        return formatter.string(from: route.expectedTravelTime)
    }
    private var travelDistance: String? {
        guard let route else { return nil }
        let distanceInMeters = route.distance
        
        let distanceInKilometers = distanceInMeters / 1000
        let formattedDistance = String(format: "%.1f km", distanceInKilometers)

        return formattedDistance
        
    }
    private var tollImage: Image? {
        guard let route = route, route.hasTolls else { return nil }
        return Image(systemName: "creditcard")
    }
    private var highwayImage: Image? {
        guard let route = route, route.hasHighways else { return nil }
        return Image(systemName: "arrow.triangle.turn.up.right.circle")
    }
    
}
