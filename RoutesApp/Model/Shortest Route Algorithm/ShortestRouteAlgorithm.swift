//
//  ShortestRouteAlgorithm.swift
//  RoutesApp
//
//  Created by Guerson on 5/4/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import Foundation
import MapKit

///It find the shortest route to visit all the destinations, given the start place
class ShortestRouteAlgorithm {
    ///It contains the directioned paths between two places
    var placeEdges: [PlaceEdge] = [ ]
    ///It is the array with all the destinations
    var placesToVisit : [PlaceToVisit ]
    ///It contains the edges within the shortest route
    var EdgesInOptimalRoute : [ PlaceEdge ] = [ ]
    var polylinesInRoute : [ MKPolyline] = [ ]
    ///It saves the places that has been included in the route
    var placesVisited: [PlaceToVisit ] = [ ]
    var startPlace: PlaceToVisit
    var counter = 0
    var totalDistance : Double = 0
    
    
    ///It initializes the object with the places to visit and the place
    init(placesToVisit: [ PlaceToVisit], starPlace: PlaceToVisit) {
        self.placesToVisit = placesToVisit
        self.startPlace = starPlace
       
    }
    
    func createRoute (handler: ((_ finished: Bool) -> Void)?) {
        let quantity = ( placesToVisit.count) * ( placesToVisit.count-1)
        updateEdges { ( finished ) in
            if finished == quantity {
                self.findShortestPath(from: self.startPlace)
                handler?( true )
            }
        }
    }
    
    func getOptimalRoute() -> (placesOrdered: [ PlaceToVisit ], polylinesInRoute: [ MKPolyline], totalDistance: Double) {
        let placesToReturn = self.getPlacesToReturn()
        return (placesToReturn, self.polylinesInRoute, self.totalDistance)
    
    }
    /**
     It creates the edges between all the places, with both directions.
     
     - Parameter handlerRequest: it indicates that a closure is required to handler the result of the request.
     - Remark:
         * the property *totalDistance* is the result of the distance of the route ( according to directions) from start place to destination place.
         * the function doesn't returns anything but updates the placeEdges array
     - Note: this function creates all the posible edges, a better function creates edges just from the last visited place to the unvisited places, and picks the nearer place. That function is not included in this version.

     
     */
    func updateEdges(handlerRequest: ((_ finished: Int) -> Void)?) {
        
        let request = MKDirections.Request()
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        for i in 0..<placesToVisit.count {
            let place = placesToVisit[ i ]
            let startMapItem : MKMapItem = getMapItem(place: place)
            let placesSet = getPlacesArray(actualPlace: place)
            
            for j in 0..<placesSet.count {
                let placeDestination = placesSet[ j ]
                let endMapItem : MKMapItem = getMapItem(place: placeDestination)
                request.source = startMapItem
                request.destination = endMapItem
                let directions = MKDirections(request: request)
                
                directions.calculate() { [ weak self] ( response, error) in
                    if let error = error {
                        print( error.localizedDescription )
                        return
                    }
                    if let route = response?.routes.first {
                        let distance = route.distance
                        let polyline = route.polyline
                        let placeEdge = PlaceEdge(source: place, destination: placeDestination, weight: distance, polyline: polyline)
                        self?.placeEdges.append(placeEdge)
                    handlerRequest?(self!.placeEdges.count)
                    }
                }
            }
        }
    }
    
    /**
     It creates a subset of the original array, when the actual place it is not included.
     
     - Parameter actualPlace: a place from the *placesToVisit* property, for wich the subset will be created.
     - Returns: the array with all the posibles destinations for the parameter
     */
    private func getPlacesArray ( actualPlace : PlaceToVisit ) -> [ PlaceToVisit ] {
        var placesSet : [ PlaceToVisit] = [ ]
        for place in placesToVisit {
            if place.index != actualPlace.index {
                placesSet.append(place)
            }
        }
        return placesSet
    }
    /**
     It is a recursive function wich finds the whole shortest route usign placeEdges array
     - Parameter from place: the current place from wich find the nearest destination
     - Requires: function *updateEdges* must be ran before
     
     - Note: a different version of this calculator it's possible, but noy implemented in this version, the purpose of this is make use of recursion.
     
 */
    private func findShortestPath( from place: PlaceToVisit) {
       
            if self.counter <= self.placesToVisit.count {
                let indexOfPlace = place.index
                var edgesFromPlace : [PlaceEdge] = [ ]
                for edge in self.placeEdges {
                    if edge.source.index == indexOfPlace && !self.placesVisited.contains(edge.destination) {
                        edgesFromPlace.append(edge)
                    }
                }
                edgesFromPlace.sort(by: { $0.weight < $1.weight })
                guard let shortestEdge = edgesFromPlace.first else {
                    return
                }
                self.placesVisited.append(place)
                self.EdgesInOptimalRoute.append(shortestEdge)
                self.counter += 1
                self.findShortestPath(from: shortestEdge.destination)
            }
    }
        
    ///It converts a place in a  MKMapItem
    private func getMapItem( place: PlaceToVisit) -> MKMapItem {
        let placeMark = MKPlacemark(coordinate: place.coordinate)
        return MKMapItem(placemark: placeMark)
    }
    ///It transforms an ordered array of edges into an ordered array of the places tht shows the route.
    /// - Returns: An ordered array of places that indicates the route.
    private func getPlacesToReturn () -> [ PlaceToVisit ] {
        var placesToReturn : [ PlaceToVisit ] = [ ]
        for i in 0..<EdgesInOptimalRoute.count {
            let edge = EdgesInOptimalRoute[ i ]
            let place = edge.source
            place.state = true
            place.index = i
            placesToReturn.append(place)
            totalDistance = totalDistance + edge.weight
            self.polylinesInRoute.append(edge.polyline)
        }
        
        let lastEdgeDestination = EdgesInOptimalRoute.last!.destination
        lastEdgeDestination.index = EdgesInOptimalRoute.count
        lastEdgeDestination.state = true
        placesToReturn.append(lastEdgeDestination)
        return placesToReturn
    }
}
