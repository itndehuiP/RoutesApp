//
//  RoutePresentationController.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/29/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit
import MapKit

class RoutePresentationController: UIViewController {

    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calculateRoute: UIButton!
    @IBOutlet weak var showRouteButton : UIButton!
    @IBOutlet weak var saveRouteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var deleteInRouteButton: UIButton!
    @IBOutlet weak var nameRoute: UILabel!
    
    
    var delegate: RoutePresentationControllerDelegate?
    ///Contains the places that conform a route
    var places: [PlaceToVisit ] = [ ]
    ///Contains the lines into the route
    var polylinesInRoute: [ MKPolyline ] = [ ]
    ///It is the total distance calculated to visit all the places in the route
    var totalDistance: Double = 0
    ///It is the selected place marked as the start.
    var startPlace : PlaceToVisit? = nil
    ///It indicates if the actual routes is saved
    var saved : Bool = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameRoute.isHidden = true
        if !places.isEmpty {
            if startPlace == nil {
                startPlace = places.first
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        distanceLabel.text = "Select the start of the route"
        showRouteButton.isHidden = true
        if saved {
            saveRouteButton.isHidden = true
            let indexSaved = SavedData.shared.selectedRoute
            nameRoute.isHidden = false
            nameRoute.text = SavedData.shared.getSavedRoutes()[ indexSaved!].name
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
            collectionView.allowsMultipleSelection = editing
            let indexPaths = collectionView.indexPathsForVisibleItems
            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
            for indexPath in indexPaths {
                let cell = collectionView.cellForItem(at: indexPath) as! RouteCollectionViewCell
                cell.isEditing = editing
            }
    }
    /// It implements the calculator to find the shortest route for visit all the places 
    @IBAction func createOptimalRoute(_ sender: Any) {
        guard let startPlace = self.startPlace else {return }
        let actInd = self.showActivityIndicatory(uiView: self.view )
        let calculator = ShortestRouteAlgorithm(placesToVisit: self.places, starPlace: startPlace)
        calculator.createRoute() { (finished) in
            
            if finished {
                ( self.places, self.polylinesInRoute, self.totalDistance ) =  calculator.getOptimalRoute()
                if !self.places.isEmpty {
                    self.collectionView.reloadData()
                    let distance = self.totalDistance / 1000
                    self.distanceLabel.text = "Total distance is \(distance) Km"
                    self.showRouteButton.isHidden = false
                    actInd.stopAnimating()
                }
            }
        }
    }
    
    ///It sets editing configuration and triggers setEditing function
    @IBAction func editRoute(_ sender: Any) {
        editButton.isHidden = true
        calculateRoute.isHidden = true
        backButton.isHidden = true
        doneEditingButton.isHidden = false
        deleteInRouteButton.isHidden = false
        isEditing = true
    }
    
    /// It sets non editing configuration
    @IBAction func doneEditingRoute(_ sender: Any) {
        isEditing = false
        editButton.isHidden = false
        doneEditingButton.isHidden = true
        deleteInRouteButton.isHidden = true
        calculateRoute.isHidden = false
        backButton.isHidden = false
        showRouteButton.isHidden = true
    }
    

    /// It deletes from singleton and collection view the items selected
    @IBAction func deleteItemsInRoute(_ sender: Any) {
        if let indexPathsSelected = collectionView.indexPathsForSelectedItems {
            let items = indexPathsSelected.map { $0.item}.sorted().reversed()
            for item in items {
                print("item is: \(item)")
                places.remove(at: item)
                distanceLabel.text = "select the start of the route"
                totalDistance = 0
            }
            if saved {
                let indexOfRoute = SavedData.shared.selectedRoute
                SavedData.shared.getSavedRoutes()[ indexOfRoute!].setPlaces(places: places)
            }
            polylinesInRoute.removeAll()
            delegate?.routePresentationControllerWillDisappear(routeLines: polylinesInRoute, placesInRoute: places)
            collectionView.deleteItems(at: indexPathsSelected)
        }
        
    }
    
     ///It saves information for the **Map Controller** and dismiss itself
    @IBAction func showRouteinMap(_ sender: Any) {
        delegate?.routePresentationControllerWillDisappear(routeLines: polylinesInRoute, placesInRoute: places)
        dismiss(animated: true, completion: nil)
    }
    ///It dismiss itself without passing any information
    @IBAction func backToHome(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    ///It saves the actual route with its places and name
    @IBAction func saveRoute(_ sender: Any) {
        let alert = UIAlertController(title: "Save the Route", message: nil, preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.autocapitalizationType = .allCharacters
            textField.placeholder = "Type the name of the route"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                if let name = alert.textFields?.first?.text {
                    self.nameRoute.isHidden = false
                    self.nameRoute.text = "\(name)"
                    let newRoute = Route(name: name, places: self.places)
                    SavedData.shared.addSavedRoute(newRoute: newRoute)
                    SavedData.shared.selectedRoute = SavedData.shared.countRoutes()-1
                    self.saveRouteButton.isHidden = true
                    self.delegate?.routePresentationControllerHasSavedRoute(saved: true)
            }
        })
            
        )
        self.present(alert, animated: true )
    }
    
    /// It creates an activity indicator and add it while the route`s been calculated
    func showActivityIndicatory( uiView: UIView ) -> UIActivityIndicatorView {
        let actInd = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.style = .gray
        uiView.addSubview(actInd)
        actInd.startAnimating()
        return actInd
    }
}

extension RoutePresentationController: UICollectionViewDataSource {
    ///It obtains the number of items to load in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    ///It obtains the data and configure each cell, the cell is custom as *RouteCollectionCell*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCellIdentifier", for: indexPath) as? RouteCollectionViewCell else { print("cant cast")
            return UICollectionViewCell() }
        cell.indexLabel.text = "\(indexPath.row)"
        cell.titleLabel.text = places[ indexPath.row].name
        return cell
    }

    ///It sets the selected place as the start place
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.startPlace = places[ indexPath.row ]
    }
    
   
}

extension RoutePresentationController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// It configures some constraint for cells.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width)-8
        return CGSize(width: width, height: 60)
    }
}

protocol RoutePresentationControllerDelegate: NSObjectProtocol {
    func routePresentationControllerWillDisappear ( routeLines: [ MKPolyline ], placesInRoute: [ PlaceToVisit])
    func routePresentationControllerHasSavedRoute ( saved: Bool ) 

}


