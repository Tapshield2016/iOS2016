//
//  MKMapItem.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import MapKit
import Contacts
import ContactsUI
import UIKit
import AddressBook
import AddressBookUI

public class RVTMapItemAnnotation: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    public var groupTag: String?
    
    public var firstAdd: Bool = true
    
    public init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let annotation = object as? RVTMapItemAnnotation {
            
            return (self.coordinate.latitude == annotation.coordinate.latitude &&
                self.coordinate.longitude == annotation.coordinate.longitude &&
                self.title == annotation.title &&
                self.subtitle == annotation.subtitle &&
                self.groupTag == annotation.groupTag)
        }
        
        return false
    }
}

public extension CLPlacemark {
    
    @available(iOS 9.0, *)
    var postalAddress: CNPostalAddress? {
        
        let address = CNMutablePostalAddress()
        
        var hasAddress: Bool = false
        
        if let thoroughfare = self.thoroughfare where thoroughfare.characters.count > 0 {
            
            var street = thoroughfare
            if let subThoroughfare = self.subThoroughfare where subThoroughfare.characters.count > 0  {
                street = subThoroughfare + " " + street
            }
            address.street = street
            
            hasAddress = true
        }
        
        if let city = self.locality where city.characters.count > 0 {
            address.city = city
            hasAddress = true
        }
        
        if let state = self.administrativeArea where state.characters.count > 0 {
            address.state = state
            hasAddress = true
        }
        
        if let code = self.postalCode?.numeric where code.characters.count > 0 {
            address.postalCode = code
            hasAddress = true
        }
        
        if !hasAddress {
            return nil
        }
        
        return address
    }
}

public extension MKMapItem {
    
    var annotation: RVTMapItemAnnotation {
        
        return RVTMapItemAnnotation(coordinate: self.placemark.coordinate, title: self.name, subtitle: self.placemark.title)
    }
    
    var formattedAddress: String? {
        
        if (self.placemark.addressDictionary == nil) {
            return nil
        }
        
        if #available(iOS 9.0, *) {
            
            if let postalAddress = self.placemark.postalAddress {
                return CNPostalAddressFormatter.stringFromPostalAddress(postalAddress, style: CNPostalAddressFormatterStyle.MailingAddress)
            }
        } else {
            // Fallback on earlier versions
            if let dict = self.placemark.addressDictionary {
                return ABCreateStringWithAddressDictionary(dict, false)
            }
        }
        
        return nil
    }
    
    var formattedAddressSingleLine: String {
        
        if let string = self.formattedAddress {
            return string.stringByReplacingOccurrencesOfString("\n", withString:", ");
        }
        return ""
    }
    
    
    public func openInGoogleMapsWithDirectionsMode(MKLaunchOptionsDirectionsMode: String) -> Bool {
        
        let testURL = NSURL(string: "comgooglemaps://")!
        
        if !UIApplication.sharedApplication().canOpenURL(testURL) {
            return self.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsMode])
        }
        
        var googleMode = MKMapItem.kGoogleMapDirectionsTypeDriving;
        if (MKLaunchOptionsDirectionsMode == MKLaunchOptionsDirectionsModeWalking) {
            googleMode = MKMapItem.kGoogleMapDirectionsTypeWalking;
        }
        
        let directionsRequest = "comgooglemaps://?daddr=" + "\(self.formattedAddressSingleLine)&directionsmode=\(googleMode)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let directionsURL = NSURL(string: directionsRequest)!
        
        return UIApplication.sharedApplication().openURL(directionsURL)
    }
    
    public func openInWazeWithDirectionsMode(MKLaunchOptionsDirectionsMode: String) -> Bool {
        
        let testURL = NSURL(string: "waze://")!
        
        if !UIApplication.sharedApplication().canOpenURL(testURL) {
            return self.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsMode])
        }
        
        let directionsRequest = "waze://?ll=" + "\(self.placemark.coordinate.latitude),\(self.placemark.coordinate.longitude)&navigate=yes".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let directionsURL = NSURL(string: directionsRequest)!
        
        return UIApplication.sharedApplication().openURL(directionsURL)
    }
    
//    private static var kAddress = "delivery_line"
    private static var kAddress1 = "line1"
    private static var kAddress2 = "line2"
    private static var kCity = "city"
    private static var kState = "state"
    private static var kCountry = "country"
    private static var kZipcode = "zip"
    
    private static var kName = "company_name"
    private static var kEmail = "company_email"
    private static var kPhone = "contact_phone"
    
    private static var kLatitude = "latitude"
    private static var kLongitude = "longitude"
    
    private static var kGoogleMapsBaseURL = "comgooglemaps://"
    private static var kGoogleMapsURLFormat = "comgooglemaps://?daddr=%@&directionsmode=%"
    
    private static var kGoogleMapDirectionsTypeDriving = "driving"
    private static var kGoogleMapDirectionsTypeWalking = "walking"
    
    private static var kWazeBaseURL = "waze://"
    private static var kWazeURLFormat = "waze://?ll=%f,%f&navigate=yes"
    
    public class func mapItem(attributes: [String: AnyObject], name: String? = nil) -> MKMapItem {
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
        if let latitude = attributes[MKMapItem.kLatitude] as? CLLocationDegrees, let longitude = attributes[MKMapItem.kLongitude] as? CLLocationDegrees {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        var addressDictionary: [String: String] = [:]
        
        if let street = attributes[MKMapItem.kAddress1] as? String {
            var address = street
            if let street2 = attributes[MKMapItem.kAddress2] as? String {
                address += " " + street2
            }
            if #available(iOS 9.0, *) {
                addressDictionary[CNPostalAddressStreetKey] = address
            } else {
                addressDictionary[String(kABPersonAddressStreetKey)] = address
            }
        }
        
        if let city = attributes[MKMapItem.kCity] as? String {
            if #available(iOS 9.0, *) {
                addressDictionary[CNPostalAddressCityKey] = city
            } else {
                addressDictionary[String(kABPersonAddressCityKey)] = city
            }
        }
        if let state = attributes[MKMapItem.kState] as? String {
            if #available(iOS 9.0, *) {
                addressDictionary[CNPostalAddressStateKey] = state
            } else {
                addressDictionary[String(kABPersonAddressStreetKey)] = state
            }
        }
        
        if let zip = attributes[MKMapItem.kZipcode] {
            let zipString = String(zip)
            if #available(iOS 9.0, *) {
                addressDictionary[CNPostalAddressPostalCodeKey] = zipString
            } else {
                addressDictionary[String(kABPersonAddressZIPKey)] = zipString
            }
        }
        
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        
        if (name == nil) {
            mapItem.name = attributes[MKMapItem.kName] as? String
        }
        else {
            mapItem.name = name
        }
        
        mapItem.phoneNumber = attributes[MKMapItem.kPhone] as? String
        
        return mapItem
    }
}