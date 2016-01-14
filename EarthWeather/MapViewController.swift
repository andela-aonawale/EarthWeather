//
//  MapViewController.swift
//  EarthWeather
//
//  Created by Ahmed Onawale on 1/14/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Segue
    
    struct Segue {
        static let ShowWeather = "Show Weather"
    }
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Actions
    
    @IBAction func zoomToUserLocation(sender: UIBarButtonItem) {
        mapView.setCameraCoordinate(mapView.userLocation.coordinate, altitude: 1500, animated: true)
    }
    
    @IBAction func showSettings(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "\n\n", message: nil, preferredStyle: .ActionSheet)
        let segmentedControl = UISegmentedControl(items: ["Celsius", "Fahrenheit", "Kelvin"])
        segmentedControl.addTarget(self, action: "changeUnit:", forControlEvents: .ValueChanged)
        let units = NSUserDefaults.standardUserDefaults().stringForKey("units")
        if units == "metric" {
           segmentedControl.selectedSegmentIndex = 0
        } else if units == "imperial" {
            segmentedControl.selectedSegmentIndex = 1
        } else {
            segmentedControl.selectedSegmentIndex = 2
        }
        segmentedControl.frame = CGRect(x: 8.0, y: 20.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 30.0)
        actionSheet.view.addSubview(segmentedControl)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func changeUnit(sender: UISegmentedControl) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if sender.selectedSegmentIndex == 0 {
            userDefaults.setObject("metric", forKey: "units")
        } else if sender.selectedSegmentIndex == 1 {
            userDefaults.setObject("imperial", forKey: "units")
        } else {
            userDefaults.setObject("", forKey: "units")
        }
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func handleTapGesture(sender: UITapGestureRecognizer) {
        switch sender.state {
        case.Ended:
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
            performSegueWithIdentifier(Segue.ShowWeather, sender: location)
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            location = sender as? Location else {
            return
        }
        switch identifier {
        case Segue.ShowWeather:
            guard let showWeatherVC = segue.destinationViewController.contentViewController as? ShowWeatherViewController else {
                return
            }
            showWeatherVC.location = location
            guard let popoverPresentationController = showWeatherVC.popoverPresentationController else { return }
            popoverPresentationController.sourceRect = mapView.popoverSourceRectForCoordinate(location.coordinate)
            let minimumSize = showWeatherVC.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            showWeatherVC.preferredContentSize = CGSize(width: 320, height: minimumSize.height)
            popoverPresentationController.delegate = self
        default:
            break
        }
    }
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, atIndex: 0)
        return navcon
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .OverFullScreen
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.setCameraCoordinate(userLocation.coordinate, altitude: 1500, animated: false)
    }
    
}
