//
//  PlaceEdge.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/23/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import Foundation
import MapKit

///An directioned edge or path defined between two places
class PlaceEdge {
    ///The origin of the path
    let source: PlaceToVisit
    ///The destination of the path
    let destination: PlaceToVisit
    ///The distance in meters between the places
    let weight: Double
    let polyline: MKPolyline
    ///Initializes a placeEdge
    init( source: PlaceToVisit, destination: PlaceToVisit, weight: Double, polyline: MKPolyline) {
        self.source = source
        self.destination = destination
        self.weight = weight
        self.polyline = polyline
      
       
    }
    
}
