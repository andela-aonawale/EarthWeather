//
//  Extensions.swift
//  EarthWeather
//
//  Created by Ahmed Onawale on 1/14/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit
import Foundation

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        return self
    }
}

extension MKMapView {
    func popoverSourceRectForCoordinate(coordinate: CLLocationCoordinate2D) -> CGRect {
        let popoverSourceRectCenter = self.convertCoordinate(coordinate, toPointToView: self)
        return CGRect(origin: popoverSourceRectCenter, size: CGSizeZero)
    }
    
    func setCameraCoordinate(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, animated: Bool) {
        let camera = MKMapCamera()
        camera.centerCoordinate = coordinate
        camera.altitude = altitude
        self.setCamera(camera, animated: animated)
    }
}
extension NSDate {
    class func formatDateWithUnixTime(unixTime: Int, format: String) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(weatherDate)
    }
}
