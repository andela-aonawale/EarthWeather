//
//  ShowWeatherViewController.swift
//  EarthWeather
//
//  Created by Ahmed Onawale on 1/14/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class ShowWeatherViewController: UIViewController {
    
    // MARK: - Properties
    
    var location: Location?
    var apiClient: APIClient
    
    // MARK: - Outlets
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBAction func dissmissViewController(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateUIWithCurrentWeather(currentWeather: CurrentWeather) {
        humidityLabel.text = "\(currentWeather.humidity)%"
        pressureLabel.text = "\(currentWeather.pressure)mb"
        descriptionLabel.text = currentWeather.description
        dateLabel.text = NSDate.formatDateWithUnixTime(currentWeather.unixTime, format: "EEEE, LLLL d")
        temperatureLabel.text = "\(currentWeather.temperature)\u{00B0}"
        apiClient.getWeatherIconWithIconName(currentWeather.iconName) { [weak self] data in
            guard let imageData = data else { return }
            dispatch_async(dispatch_get_main_queue()) {
                self?.weatherImage.image = UIImage(data: imageData)
            }
        }
    }
    
    private func getNameForLocation(location: Location) {
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] in
            guard ($1 == nil),
                let placemark = $0?.first else {
                return
            }
            self?.locationNameLabel.text = "\(placemark.name ?? ""), \(placemark.subAdministrativeArea ?? "") \(placemark.country ?? "")"
        }
    }
    
    private func displayErrorMessage() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        label.font = UIFont(name: "Palatino-Italic", size: 20)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.text = "Cannot get weather for the selected location."
        label.numberOfLines = 0
        label.sizeToFit()
        view = label
    }
    
    private func getCurrentWeatherForLocation(location: Location) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.frame = CGRect(origin: CGPoint(x: view.center.x - 25, y: view.center.y - 25), size: CGSize(width: 50, height: 50))
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        apiClient.getCurrentWeatherForLatitude(location.latitude, longitude: location.longitude) { [weak self] result, error in
            dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.removeFromSuperview()
                guard error == nil, let result = result as? [String: AnyObject] else {
                    print(error)
                    self?.displayErrorMessage()
                    return
                }
                guard let weatherArray = result["weather"] as? [[String: AnyObject]],
                    main = result["main"] as? [String: AnyObject],
                    weather = weatherArray.first,
                    date = result["dt"] as? Int else {
                    self?.displayErrorMessage()
                    print(error)
                    return
                }
                let currentWeather = CurrentWeather(weather: weather, main: main, date: date)
                self?.getNameForLocation(location)
                self?.updateUIWithCurrentWeather(currentWeather)
            }
        }
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        apiClient = APIClient.sharedInstance
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let location = location else { return }
        getCurrentWeatherForLocation(location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
