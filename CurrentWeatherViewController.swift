//
//  CurrentWeatherViewController.swift
//  DataThere
//
//  Created by Tu Lam Lam on 22/5/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import UIKit

class CurrentWeatherViewController: UIViewController, WeatherDelegate {
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var weatherImage: UIImageView!
    
    var currentCity = CitiesViewController.City(cityID: "7839805", name: "Melbourne")
    var weatherArray: [WeatherInfo.Weather]?
    let fileManager = FileManager.default
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var currentCityURL: URL!
    var imageURL: URL!
    var forecastIcons: [Data] = [Data]()
    let dateFormatter = DateFormatter()
    let decoder = JSONDecoder()
    var spinner = UIView()
    var dispatchGroup = DispatchGroup()
    
    func didGetData(weatherArray: [WeatherInfo.Weather]) {
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            self.weatherArray = weatherArray
            self.imageURL = URL.init(string: "http://openweathermap.org/img/w/\(self.weatherArray![0].icon).png")!
            self.downloadImages(self.weatherArray!)
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        DispatchQueue.main.async  {
            self.currentTempLabel.text = "\(String(format:"%.0f", self.weatherArray?[0].currentTemp ?? 0))°"
            self.navigationItem.title = self.weatherArray![0].name
            let imageData: Data = try! Data(contentsOf: self.imageURL)
            self.weatherImage.image = UIImage(data: imageData as Data)
            self.weatherImage.contentMode = UIView.ContentMode.scaleAspectFit
            self.forecastTableView.reloadData()
            self.dispatchGroup.leave()
        }
        self.removeSpinner()
        
        dispatchGroup.notify(queue: .main) {
            self.forecastTableView.reloadData()
        }
    }
    
    func didGetCity(city: CitiesViewController.City) {
    }
    
    func didNotGetData(error: Error) {
        print(error)
    }
    
    override func viewDidLoad() {
        showSpinner(onView: self.view)
        dateFormatter.dateFormat = "dd/MM HH"
        self.currentCityURL = self.documentsDirectory.appendingPathComponent("currentcity").appendingPathExtension("json")
        checkFile()
        loadFromFile()
        let weatherInfo = WeatherInfo(delegate: self)
        weatherArray = weatherInfo.getWeatherInfo(currentCity.cityID)
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        super.viewDidLoad()
        //removeSpinner()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WeatherDetailViewController {
            let vc = segue.destination as? WeatherDetailViewController
            vc?.weatherDetails = weatherArray![0].details
        }
        
    }
    
    @IBAction func done(_ sender: Any) {
    }
    
    private func checkFile() {
        let path = currentCityURL.path
        if fileManager.fileExists(atPath: path) {
            print("File exists")
        } else {
            print("File does not exists")
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }
    
    private func loadFromFile() {
        if let currentCityData = try? Data(contentsOf: currentCityURL) {
            print(String(data: currentCityData, encoding: .utf8) ?? "error")
            guard let decodedData = try? decoder.decode(CitiesViewController.City.self, from: currentCityData) else { return }
            if decodedData.cityID != "" {
                currentCity = decodedData
            }
        }
    }
    
    private func downloadImages(_ weatherArray: [WeatherInfo.Weather]) {
        for i in 0 ..< weatherArray.count {
            let url = URL.init(string:"http://openweathermap.org/img/w/\(weatherArray[i].icon).png")!
            try! self.forecastIcons.append(Data(contentsOf: url))
        }
        
    }
   
}

extension CurrentWeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastTableViewCell
        cell.timeLabel.text = "\(dateFormatter.string(from: Date.init(timeIntervalSince1970: weatherArray![indexPath.row].dt)))"
        cell.tempLabel.text = "\(String(format:"%.0f",weatherArray![indexPath.row].currentTemp))°"
        if indexPath.row < forecastIcons.count {
            cell.forecastImage.image = UIImage(data: self.forecastIcons[indexPath.row])
            cell.forecastImage.contentMode = UIView.ContentMode.scaleAspectFit
        }
        
        return cell
    }
}

extension CurrentWeatherViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        spinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.spinner.removeFromSuperview()
            //vSpinner = nil
        }
    }
}
