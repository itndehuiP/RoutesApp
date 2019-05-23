//
//  MapsViewController.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/24/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapsViewController: UIViewController {

    var locationManager: CLLocationManager?
    var routeLines: [ MKPolyline] = [ ]
    var places: [PlaceToVisit ] = [ ]
    var selectedPlace : PlaceToVisit? = nil
    var currentLocation : CLLocation? = CLLocation(latitude: 19.349188, longitude: -99.16351256089476)
    let regionRadius: CLLocationDistance = 2500
    private var saved: Bool = false
    var receivedFromMain = false
    
   
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var addPlaceButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var goBackToMainButton: UIButton!
    ///It configures the view and view controller according to received information.
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters 
        startLocationService()
        mapView.showsUserLocation = true
        goBackToMainButton.layer.cornerRadius = 2.0
        
        if receivedFromMain {
            mapView.addAnnotations(self.places)
            saved = true 
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager?.requestWhenInUseAuthorization()
    }
    /**
     It handles the data received from *LocationsViewController* to configures the map in the view
    */
    func dataBackFrom () {
        guard let place = self.selectedPlace else { print( "theres no selected place")
            return }
        self.places.append(place)
        for place in places {
            place.state = false 
        }
        let region = MKCoordinateRegion(center: place.location.coordinate, latitudinalMeters: self.regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotations(places)
        mapView.register(PlaceMarkerView.self , forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.removeOverlays(routeLines)
        routeLines.removeAll()
    }
    
    ///It checks the authorization status for location, and make a request if it's neccesary
     func startLocationService () {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            activateLocationService()
        } else {
            locationManager?.requestWhenInUseAuthorization()
            if CLLocationManager.authorizationStatus() == .denied {
                        let region = MKCoordinateRegion(center: currentLocation!.coordinate , latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                        mapView.setRegion(region, animated: true )
            }
            
        }
    }
    ///It starts updating location
    private func activateLocationService() {
        locationManager?.startUpdatingLocation()
    }
    ///It assigns the property index to each place in places array
    private func assignIndex () {
        for i in 0..<places.count {
            places[ i ].index = i
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoutePresentationSegue" && places.count > 1 {
            guard let routeController = segue.destination as? RoutePresentationController else { return }
            if places.count > 0 {
                assignIndex()
                routeController.places = self.places
                routeController.saved = saved 
                routeController.delegate = self
                
            }
        } else if segue.identifier == "LocationsVCSegue" {
            guard let locationsController = segue.destination as? LocationsViewController else { return }
            locationsController.delegate = self 
            
        }
    }
    /// It dismiss itself and save the route if it is neccesary
    @IBAction func goBackToMain(_ sender: Any) {
        print("places count: \(places.count) and savedStte: \(saved )")
        if places.count>2 && !saved {
            
            let alert = UIAlertController(title: "Do you want to save the route", message: nil, preferredStyle: .alert)
            alert.addTextField() { textField in
                textField.placeholder = "Type the name of the route"
                textField.autocapitalizationType = .allCharacters
            }
            
            alert.addAction(UIAlertAction(
                title: "Cancel", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
                }
            ) )
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                if let name = alert.textFields?.first?.text {
                        let newRoute = Route(name: name, places: self.places)
                        SavedData.shared.addSavedRoute(newRoute: newRoute)
                    if self.saved {
                        let indexOfRoute = SavedData.shared.selectedRoute
                        SavedData.shared.getSavedRoutes()[ indexOfRoute!].setPlaces(places: self.places)
                    }
                    self.dismiss(animated: true, completion: nil)
                        }
                    }
                ) )
            
             self.present(alert, animated: true )
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func goToSearchVC(_ sender: Any) {
        performSegue(withIdentifier: "LocationsVCSegue", sender: sender )
    }
    
    @IBAction func goToRouteVC(_ sender: Any) {
        if places.count > 1 {
            performSegue(withIdentifier: "RoutePresentationSegue", sender: sender)
        } else {
            let alert = UIAlertController(title: "Please add destinations", message: "You need 2 or more destinations. Touch \"Add destinations button\"", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(alert, animated: true )
        }
    }
    ///It draws the lines received from *routeViewController*
    func drawPolylinesinMap() {
        if !routeLines.isEmpty {
            for polyline in routeLines {
                self.mapView.addOverlay(polyline)
            }
        }
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        let region = MKCoordinateRegion(center: currentLocation!.coordinate , latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true )
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            activateLocationService()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapsViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
}

extension MapsViewController: LocationsViewControllerDelegate {
    func locationsViewControllerWillDismiss(locationVC: LocationsViewController) {
        self.selectedPlace = locationVC.selectedPlace
        dataBackFrom()
    }
}

extension MapsViewController: RoutePresentationControllerDelegate {
    func routePresentationControllerHasSavedRoute(saved: Bool) {
        self.saved = saved 
    }

    func routePresentationControllerWillDisappear(routeLines: [MKPolyline], placesInRoute: [PlaceToVisit]) {
        print("Delegate for rooute presentation is called")
        mapView.removeAnnotations(self.places)
        mapView.removeOverlays(routeLines)
        self.routeLines.removeAll()
        self.routeLines = routeLines
        self.places = placesInRoute
         drawPolylinesinMap()
        mapView.addAnnotations(self.places)
       
    }
    
    
}








