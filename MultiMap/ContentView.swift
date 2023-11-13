//
//  ContentView.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import os
import SwiftUI
import MapKit
import CoreLocation


@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager

    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}



class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var altitude: CLLocationDistance = 0.0
    private var locationManager: CLLocationManager?

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation // More suitable for altitude

               // Request location authorization and start updating location
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
    }

    func startTracking() {
        locationManager?.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            DispatchQueue.main.async {
                self.altitude = currentLocation.altitude
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
struct ContentView: View {
    let logger = Logger(subsystem: "net.appsird.multimap", category: "Demo")
    @ObservedObject var locationViewModel = LocationViewModel()
    @ObservedObject var locationsHandler = LocationsHandler.shared

    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    
    var body: some View {
    
       
        Map(position: $position, selection: $selectedResult){
            
            ForEach(searchResults, id: \.self) {result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
            Marker("HOME", coordinate: .myHome)
                .tint(.orange)
                  .tag(9999)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
            UserAnnotation()
            
            Annotation("The Viking Ship Museum", coordinate: .theVikingMuseum) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 2)
                    Image(systemName: "house")
                        .padding(3)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing:0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    Buttons(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                   
                    
                }
                
//
               
             
            }
            .background(.thinMaterial)
        }
        .onChange(of: searchResults) {
            withAnimation{
                position = .automatic
            }
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
       
       
               
    
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let location = locationsHandler.manager.location
        guard let coordinate = location?.coordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}


#Preview {
    ContentView()
}
extension CLLocationCoordinate2D {
   
    static let theVikingMuseum = CLLocationCoordinate2D(latitude: 59.9044, longitude: 10.6829)
    static let myHome = CLLocationCoordinate2D(latitude: 59.9362, longitude: 10.6433)
}

// 59.936251999784155, 10.643378035371752
