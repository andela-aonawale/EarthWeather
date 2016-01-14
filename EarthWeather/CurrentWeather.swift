//
//  CurrentWeather.swift
//  EarthWeather
//
//  Created by Ahmed Onawale on 1/14/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation

struct CurrentWeather {
    var main: String
    var humidity: Int
    var temperature: Int
    var iconName: String
    var pressure: Double
    var description: String
    var unixTime: Int
    
    init(weather: [String: AnyObject], main: [String: AnyObject], date: Int) {
        self.main = weather["main"] as? String ?? ""
        humidity = main["humidity"] as? Int ?? 0
        temperature = Int(main["temp"] as? Double ?? 0)
        iconName = weather["icon"] as? String ?? ""
        pressure = main["pressure"] as? Double ?? 0.0
        description = weather["description"] as? String ?? ""
        unixTime = date
    }
}