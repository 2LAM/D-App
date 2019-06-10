//
//  Weather.swift
//  DataThere
//
//  Created by Tu Lam Lam on 28/4/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import Foundation
protocol WeatherDelegate {
    func didGetData(weatherArray: [WeatherInfo.Weather])
    func didGetCity(city: CitiesViewController.City)
    func didNotGetData(error: Error)
}

class WeatherInfo {
    let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    let apiKey = "aca8b9c610ebb71c452df3a608453b8d"
    var delegate: WeatherDelegate
   
    struct Weather: Codable {
        var cityID: String
        var name: String
        var weather: String
        var icon: String
        var currentTemp: Double
        var details: String
        var dt: TimeInterval
        
        private enum CodingKeys: String, CodingKey {
            case cityID = "city_id"
            case name = "city_name"
            case weather = "weather"
            case icon = "icon"
            case currentTemp = "current_temperature"
            case details = "details"
            case dt = "date_time"
        }
    }
    
    init(delegate: WeatherDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherInfo(_ cityID: String) -> [Weather] {
        var weatherArray = [Weather]()
        var weather: Weather = Weather(cityID: "", name: "", weather: "", icon: "", currentTemp: 0, details: "", dt: 0)
        let url = URL.init(string: "http://api.openweathermap.org/data/2.5/forecast?id=\(cityID)&APPID=\(apiKey)")!
        print(url)
        let session = URLSession.shared
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if let error = error {
                print(error)
            }
            else {
                do {
                    let weatherData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    print(weatherData)
                    let weatherInfo = weatherData["list"]! as! [Dictionary<String, AnyObject>]
//                    self.mapToWeatherInfo(weatherInfo)
                    for i in 0 ..< weatherInfo.count {
                        weather = Weather(cityID: cityID,
                                          name: (weatherData["city"]! as! Dictionary<String, AnyObject>)["name"] as! String,
                                          weather: (weatherInfo[i]["weather"]![0] as! Dictionary<String, AnyObject>)["main"]! as! String,
                                          icon: (weatherInfo[i]["weather"]![0] as! Dictionary<String, AnyObject>)["icon"]! as! String,
                                          currentTemp: round(((weatherInfo[i]["main"]) as! Dictionary<String, AnyObject>)["temp"] as! Double - 273.15),
                                          details: self.convertToDetails(weatherInfo[i]),
                                          dt: weatherInfo[i]["dt"] as! Double)
                        weatherArray.append(weather)
                        self.printWeatherInfo(weatherInfo[i])
                    }
                    //weather = Weather(city: weatherInfo["name"] as! String, weather: (weatherInfo["weather"]![0] as! [String: AnyObject])["main"]! as! String, temp: round(((weatherInfo["main"]) as! [String: AnyObject])["temp"] as! Double - 273.15), details: self.convertToDetails(weatherInfo))
                    
                    self.delegate.didGetData(weatherArray: weatherArray)
                }
                catch {
                    self.delegate.didNotGetData(error: error)
                }
            }
        }
        task.resume()
        return weatherArray
    }
    
    func getCityID(_ lat: Double, _ long: Double) -> CitiesViewController.City {
        var city: CitiesViewController.City = CitiesViewController.City(cityID: "", name: "")
        let url = URL.init(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(long)&APPID=\(apiKey)")!
        print(url)
        let session = URLSession.shared
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if let error = error {
                print(error)
            }
            else {
                do {
                    let weatherData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    print(weatherData)
                    city = CitiesViewController.City(cityID: "\((weatherData["city"]! as! Dictionary<String, AnyObject>)["id"] as! NSNumber)",
                                                      name: (weatherData["city"]! as! Dictionary<String, AnyObject>)["name"] as! String)
                    self.delegate.didGetCity(city: city)
                }
                catch {
                    self.delegate.didNotGetData(error: error)
                }
            }
        }
        task.resume()
        return city
    }
    
    func printWeatherInfo(_ weatherInfo: Dictionary<String, AnyObject>) {
        //print("City: \(weatherInfo["name"]!)")
        print("Date and time: \(weatherInfo["dt"]!)")
        let weather = weatherInfo["weather"]![0] as! [String: AnyObject]
        print("Weather: \(weather["main"]!)")
        print("Description: \(weather["description"]!)")
//        print("Temperature: \(weatherInfo["main"]!["temp"]!!)")
//        print("Sunrise: \(weatherInfo["sys"]!["sunrise"]!!)")
//        print("Sunset: \(weatherInfo["sys"]!["sunset"]!!)")
    }
    
    func convertToDetails(_ weatherInfo: Dictionary<String, AnyObject>) -> String {
        var details: String = ""
        //details += "City: \(weatherInfo["name"]!)\n"
        details += "Date and time: \(Date.init(timeIntervalSince1970: weatherInfo["dt"]! as! TimeInterval))\n"
        let weather = weatherInfo["weather"]![0] as! Dictionary<String, AnyObject>
        details += "Weather: \(weather["main"]!)\n"
        //details += "Temperature: \(weatherInfo["main"]!["temp"]!! as! Double - 273.15)\n"
        //details += "Sunrise: \(Date.init(timeIntervalSince1970:  weatherInfo["sys"]!["sunrise"]!! as! TimeInterval))\n"
        //details += "Sunset: \(Date.init(timeIntervalSince1970:  weatherInfo["sys"]!["sunset"]!! as! TimeInterval))\n"
        details += "Description: \(weather["description"]!)\n"
        return details
    }
    
//    func mapToWeatherInfo(_ weatherInfo: [String: AnyObject]) {
//        dateTime = Date(timeIntervalSince1970: weatherInfo["dt"] as! TimeInterval)
//        weather = ((weatherInfo["weather"]![0] as! [String: AnyObject])["main"]! as! String)
//        print(weather)
//        temp = (((weatherInfo["main"]) as! [String: AnyObject])["temp"] as! Double - 273.15)
//        print(temp)
//        sunrise = Date(timeIntervalSince1970: weatherInfo["sys"]!["sunrise"]!! as! TimeInterval)
//        sunset = Date(timeIntervalSince1970: weatherInfo["sys"]!["sunset"]!! as! TimeInterval)
//    }
}

/**
 ["dt": 1556428627,
 "weather": <__NSArrayM 0x280376490>
 (
     {
         description = "light rain";
         icon = 10d;
         id = 500;
         main = Rain;
     }
 ),
 "name": Melbourne,
 "id": 2158177,
 "rain": {
    1h = "0.25";
 },
 "coord": {
     lat = "-37.81";
     lon = "144.96";
 },
 "main": {
     humidity = 82;
     pressure = 1025;
     temp = "289.25";
     "temp_max" = "290.37";
     "temp_min" = "287.59";
 },
 "sys": {
     country = AU;
     id = 9554;
     message = "0.0078";
     sunrise = 1556398658;
     sunset = 1556437058;
     type = 1;
 },
 "base": stations,
 "clouds": {
    all = 75;
 },
 "cod": 200,
 "visibility": 10000,
 "wind": {
     deg = 240;
     speed = "6.2";
 }]
 **/

