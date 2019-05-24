//
//  RouteLocation.swift
//  RoutesApp
//
//  Created by Guerson on 5/23/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import Foundation
import MapKit

class RouteLocation: Codable {
    let rlLatitude: Double
    let rlLongitude: Double
    
    init(latitude: Double, longitude: Double) {
        rlLatitude.self = latitude
        rlLongitude.self = longitude
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.rlLatitude, self.rlLongitude)
    }
}
