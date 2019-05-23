//
//  MainViewController.swift
//  RoutesApp
//
//  Created by ItandehuiP on 5/10/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var addRouteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var deleteInRouteButton: UIButton!
    
    ///Indicates if a saved rooute has been selected
    var isSavedRoute: Bool = false
    var selectedRoute: [ PlaceToVisit ] = [ ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print( "view will appear")
        if SavedData.shared.getSavedRoutes().count != 0 {
            editButton.isHidden = false 
            collectionView.reloadData()
            SavedData.shared.selectedRoute = nil 
        }
        isSavedRoute = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! SavedRouteCollectionViewCell
            cell.isEditing = editing
        }
    }
    
    func configureButton() {
        addRouteButton.layer.cornerRadius = 2.0
    }
    
    ///Performs segue to next view and adding new route configuration
    @IBAction func addNewRoute(_ sender: Any) {
        performSegue(withIdentifier: "MapAddRouteSegue", sender: sender )
    }
    
    ///It sets editing configuration and triggers setEditing function
    @IBAction func editRoute(_ sender: Any) {
        editButton.isHidden = true
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
    }
    
    /// It deletes from singleton and collection view the items selected
    @IBAction func deleteRoutes(_ sender: Any) {
        if let indexPathsSelected = collectionView.indexPathsForSelectedItems {
            let items = indexPathsSelected.map { $0.item}.sorted().reversed()
            for item in items {
                print("this is the item \(item )")
                SavedData.shared.deleteRoute(index: item)
            }
            collectionView.deleteItems(at: indexPathsSelected)
            if SavedData.shared.countRoutes() == 0 {
                isEditing = false
                editButton.isHidden = false
                doneEditingButton.isHidden = true
                deleteInRouteButton.isHidden = true
            }
        }
        
    }
    
    /// It configures segue to next view depending on *isSavedRoute*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapAddRouteSegue" {
            guard let controller = segue.destination as? MapsViewController else { return }
            if isSavedRoute {
                controller.receivedFromMain = true
                controller.places = selectedRoute
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    ///It obtains number of items in section to the collection view from the singleton data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SavedData.shared.getSavedRoutes().count
    }
    ///It configure each cell with the corresponding data, and custom it as *SavedRouteCell*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedRouteCellIdentifier", for: indexPath) as?
            SavedRouteCollectionViewCell else { return UICollectionViewCell() }
            cell.nameLabel.text = SavedData.shared.getSavedRoutes()[ indexPath.row].name
            return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderIdentifier", for: indexPath) as? SectionHeaderCollectionReusableView else { return UICollectionReusableView()}
        return sectionHeader
    }
    
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    ///it manages the selection of items in collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
        self.isSavedRoute = true
        SavedData.shared.selectedRoute = indexPath.row
        selectedRoute = SavedData.shared.getSavedRoutes()[indexPath.row ].placesInOrder
        self.performSegue(withIdentifier: "MapAddRouteSegue", sender: nil)
        }
    }
    /// It configures some constraint for cells.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width)-40
        return CGSize(width: width, height: 60)
    }
}





