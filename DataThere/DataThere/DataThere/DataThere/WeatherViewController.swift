//
//  WeatherViewController.swift
//  DataThere
//
//  Created by Tu Lam Lam on 28/4/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import UIKit
import Network
import CoreLocation

class WeatherViewController: UITableViewController, CLLocationManagerDelegate, WeatherDelegate {
    
    struct City: Codable {
        var cityID: String
        var name: String
        
        private enum CodingKeys: String, CodingKey {
            case cityID = "city_id"
            case name = "name"
        }
    }
    var cities = [City]()
    var currentCity = City(cityID: "7839805", name: "Melbourne")
    var cityLocation = City(cityID: "", name: "")
    
    let fileManager = FileManager.default
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var archiveURL: URL!
    var currentCityURL: URL!
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    func didGetData(weatherArray: [WeatherInfo.Weather]) {
    }
    
    func didGetCity(city: WeatherViewController.City) {
        DispatchQueue.main.async {
            self.cityLocation = city
            self.tableView.reloadData()
        }
    }
    
    func didNotGetData(error: Error) {
        print(error)
    }
    
    override func viewDidLoad() {

        self.archiveURL = self.documentsDirectory.appendingPathComponent("cities").appendingPathExtension("json")
        self.currentCityURL = self.documentsDirectory.appendingPathComponent("currentcity").appendingPathExtension("json")
        //self.clearFile()
//        var city: City = City(cityID: "7839805", name: "Melbourne")
//        cities.append(city)
//        city = City(cityID: "2163782", name: "Hawthorn")
//        cities.append(city)
//        city = City(cityID: "5128638", name: "New York")
//        cities.append(city)
//        self.saveToFile()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
            currentLocation = locationManager.location
            let weatherInfo = WeatherInfo(delegate: self)
            cityLocation = weatherInfo.getWeatherInfoWithCoordinates(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)
            
        }
        self.checkFile()
        self.loadFromFile()
        self.loadCurrentCity()
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cities.count + 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        if indexPath.row == 0 {
            if cityLocation.cityID != "" {
                cell.textLabel?.text = "Current Location: \(cityLocation.name)"
            }
            else {
                cell.textLabel?.text = "Location is not available"
            }
        }
        else {
            cell.textLabel?.text = "\(cities[indexPath.row - 1].name)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            saveCurrentCity(cityLocation)
            currentCity = cityLocation
        }
        else {
            saveCurrentCity(cities[indexPath.row - 1])
            currentCity = cities[indexPath.row - 1]
        }
        
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CurrentWeatherViewController
        {
            let vc = segue.destination as? CurrentWeatherViewController
            vc?.currentCity.cityID = currentCity.cityID
        }
    }

    @IBAction func done(_ segue: UIStoryboardSegue) {
        saveToFile()
    }

    func checkFile() {
        let path = archiveURL.path
        if fileManager.fileExists(atPath: path) {
            print("File exists")
        } else {
            print("File does not exists")
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }

    func clearFile() {
        let path = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: path + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }

    func saveToFile() {
        let encodedCities = try? encoder.encode(cities)
        try? encodedCities?.write(to: archiveURL, options: .noFileProtection)
    }

    func loadFromFile() {
        if let citiesData = try? Data(contentsOf: archiveURL) {
            print(String(data: citiesData, encoding: .utf8) ?? "error")
            guard let decodedData = try? decoder.decode([City].self, from: citiesData) else { return }
            cities = decodedData

        }
    }

    func saveCurrentCity(_ city: City) {
        let encodedCity = try? encoder.encode(city)
        try? encodedCity?.write(to: currentCityURL, options: .noFileProtection)
    }
    
    func loadCurrentCity() {
        if let currentCityData = try? Data(contentsOf: currentCityURL) {
            print(String(data: currentCityData, encoding: .utf8) ?? "error")
            guard let decodedData = try? decoder.decode(City.self, from: currentCityData) else { return }
            currentCity = decodedData
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
