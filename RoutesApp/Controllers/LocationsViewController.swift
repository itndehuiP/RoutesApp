//
//  LocationsViewController.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/23/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    var initialLocation = CLLocationCoordinate2D(latitude: 40.730610, longitude: 40.730610)
    var matchingItems : [ MKMapItem ] = []
    let searchRadius: CLLocationDistance = 1000
    let searchController = UISearchController(searchResultsController: nil)
    var selectedPlace : PlaceToVisit? = nil
    var delegate: LocationsViewControllerDelegate? 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search the address of the destination"
        searchBar.addSubview(searchController.searchBar)
        cancelButton.layer.cornerRadius = 4.0
    }
    ///It dismiss itself and go back to *mapsViewController*
    @IBAction func backToMapsVC(_ sender: Any) {
        dismiss(animated: true, completion: nil )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension LocationsViewController: MKMapViewDelegate {
    ///It does the request to find matching addresses to the search, and load them in the table view
    func searchAddress(addressString: String ) {
        matchingItems = []
        tableView.reloadData()
        
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
        request.naturalLanguageQuery = addressString
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                for item in response.mapItems {
                    self.matchingItems.append(item)
                }
                self.tableView.reloadData()
            }
           
        }
        
    }
    
}


extension LocationsViewController: UITableViewDataSource {
    /// - Returns: the number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return matchingItems.count
    }
    /// It configures the cell as *LocationsTableViewCell* with the data resulted from the search
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationsTableViewCell else { return UITableViewCell() }
        
        let selectedItem = matchingItems[indexPath.row]
        let placemark = selectedItem.placemark
    
        cell.addressLabel.text = placemark.title
        cell.iconImageV.image = UIImage(named: "locationIcon")
        
        return cell
    }
    ///It sets the selected item and sent it to *MapsViewController* to be added in the map view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        let location = selectedItem.placemark.location!
        selectedPlace = PlaceToVisit(latitude: location.coordinate.latitude , longitude: location.coordinate.longitude, name: selectedItem.placemark.title!)
        delegate?.locationsViewControllerWillDismiss(locationVC: self)
        dismiss(animated: true, completion: nil )
    }
}
    
    extension LocationsViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
        }
    }

extension LocationsViewController:  UISearchResultsUpdating {
    ///It calls the funtion to serch places with the text received
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
            if !searchString!.isEmpty {
                
            searchAddress(addressString: searchString!)
            }
        }
    }

protocol LocationsViewControllerDelegate: NSObjectProtocol {
    func locationsViewControllerWillDismiss(locationVC: LocationsViewController )
}



