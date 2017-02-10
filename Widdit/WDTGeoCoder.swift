//
//  WDTGeoCoder.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 07.12.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import MapKit
import Parse

class WDTGeoCoder {
    
    class func getCity(lat: Double, lon: Double, completion: (place: String) -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            var placeStr = ""
            
            if let city = placeMark.addressDictionary!["City"] as? String {
                placeStr += city
                completion(place: city)
            } else if let locationName = placeMark.addressDictionary!["Name"] as? String {
                placeStr += locationName
                completion(place: locationName)
            }

            completion(place: placeStr)
        })
    }
    
    class func getCountry(lat: Double, lon: Double, completion: (place: String) -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            var placeStr = ""
            
            if let isoCountryCode = placeMark.ISOcountryCode {
                placeStr += isoCountryCode
            }
            
            completion(place: placeStr)
        })
    }
}
