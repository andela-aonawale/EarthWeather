//
//  APIClient.swift
//  EarthWeather
//
//  Created by Ahmed Onawale on 1/14/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation

class APIClient {
    
    var session: NSURLSession
    
    // MARK: - Shared Instance
    
    static let sharedInstance = APIClient()
    
    // MARK: - Initialization
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    // MARK: - URLs
    
    private struct OpenWeather {
        static let BaseURL = "http://api.openweathermap.org"
        static let IconBaseURL = "http://openweathermap.org"
        static let APPID = "a2b64071ef1c1fbe15c51fa82b06e90d"
        static let IconFormat = ".png"
        struct Path {
            static let CurrentWeather = "/data/2.5/weather"
            static let Icon = "/img/w/"
        }
    }
    
    typealias CompletionHandler = (result: AnyObject?, error: NSError?) -> Void
    
    private lazy var URLWithPath: (String, query: [String: String]) -> NSURL = {
        let URLComponents = NSURLComponents(string: OpenWeather.BaseURL)!
        URLComponents.path = $0
        URLComponents.queryItems = $1.map() {
            return NSURLQueryItem(name: $0.0, value: $0.1)
        }
        return URLComponents.URL!
    }
    
    // MARK: - Request
    
    func getCurrentWeatherForLatitude(latitude: Double, longitude: Double, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let units = NSUserDefaults.standardUserDefaults().stringForKey("units")!
        let url = URLWithPath(OpenWeather.Path.CurrentWeather, query: ["units": units, "lat": "\(latitude)", "lon": "\(longitude)", "appid": OpenWeather.APPID])
        let task = session.dataTaskWithURL(url) { data, response, error in
            guard error == nil, let data = data else {
                completionHandler(result: nil, error: error)
                return
            }
            APIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    func getWeatherIconWithIconName(iconName: String, completionHandler: (imageData: NSData?) -> Void) {
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        let url = NSURL(string: OpenWeather.IconBaseURL + OpenWeather.Path.Icon + iconName + OpenWeather.IconFormat)!
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            guard let data = NSData(contentsOfURL: url) else {
                completionHandler(imageData: nil)
                return
            }
            completionHandler(imageData: data)
        }
    }
    
    // Parse the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            guard parsedResult!["cod"] as? Int == 200 else {
                completionHandler(result: nil, error: nil)
                return
            }
            completionHandler(result: parsedResult, error: nil)
        } catch let error as NSError {
            completionHandler(result: nil, error: error)
        }
    }
}
