//
//  PlaceToVisit.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/22/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/// A place geographically defined
class PlaceToVisit: NSObject  {
    let location: CLLocation
    ///The index occuppied by the place in a Route
    var index: Int
    ///Address of the place
    let name: String
    //Indicates if the index of the place has been set.
    var state: Bool
    
    /**
     Initializes a new place with the provided location and name
     */
    init(latitude: Double, longitude: Double, name: String) {
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.name = name
        self.state = false
        index = 1
    }
}
///Made a place customable to MKAnnotation
extension PlaceToVisit: MKAnnotation {

    var coordinate : CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    
    ///The title that will be shown in MKAnnotation
    var title: String? {
        get {
            if state {
                return ("\(index+1)")
            } else {
                return ("📍")
            }

        }
    }

}
