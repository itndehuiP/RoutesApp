//
//  PlaceMarkerView.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/28/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import Foundation
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            if let placeAnnotation = newValue as? PlaceToVisit {
                glyphText = placeAnnotation.title
                markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
            }
        }
    }
}
