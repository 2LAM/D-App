//
//  CitySearchViewController.swift
//  DataThere
//
//  Created by Tu Lam Lam on 21/5/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import UIKit

class CitySearchViewController: UITableViewController {
    struct Coordinate: Codable {
        var lon: Double
        var lat: Double
    }
    
    struct City: Codable {
        var id: Int
        var name: String
        var country: String
        var coord: Coordinate
    }
    
    let dispatchGroup = DispatchGroup()
    let searchController = UISearchController(searchResultsController: nil)
    var cities = [City]()
    var filteredCities = [City]()
    var chosenCity = CitiesViewController.City(cityID: "", name: "")
    let fileManager = FileManager.default
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var allCitiesURL: URL!
    var savedCitiesURL: URL!
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    @IBOutlet var cityTableView: UITableView!
    @IBOutlet weak var useLocationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.savedCitiesURL = self.documentsDirectory.appendingPathComponent("cities").appendingPathExtension("json")
        allCitiesURL = documentsDirectory.appendingPathComponent("city.list").appendingPathExtension("json")
        checkFile()
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            if (self.cities.isEmpty) {
                self.loadFromFile()
                self.dispatchGroup.leave()
            }
            
        }
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        
        cityTableView.delegate = self
        cityTableView.dataSource = self
        
        self.tableView.reloadData()
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func checkFile() {
        let path = allCitiesURL.path
        if fileManager.fileExists(atPath: path) {
            print("File exists")
        } else {
            print("File does not exist")
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }
    
    private func loadFromFile() {
        if let cityData = try? Data(contentsOf: allCitiesURL) {
            //print(String(data: contactsData, encoding: .utf8))
            guard let decodedData = try? decoder.decode([City].self, from: cityData) else {
                print("Can not decode")
                return
            }
            cities = decodedData
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCities.count
        }
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        if isFiltering() {
            cell.textLabel?.text = filteredCities[indexPath.row].name
        }
        else {
            cell.textLabel?.text = cities[indexPath.row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCity = CitiesViewController.City(cityID: String(filteredCities[indexPath.row].id), name: filteredCities[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "searchDoneSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CitiesViewController
        {
            let vc = segue.destination as? CitiesViewController
            vc?.viewDidLoad()
            if (chosenCity.cityID != "") {
                vc?.cities.append(chosenCity)
                //vc?.saveToFile()
                //vc?.tableView.reloadData()

                let encodedCities = try? encoder.encode(vc?.cities)
                try? encodedCities?.write(to: savedCitiesURL, options: .noFileProtection)
            }
            
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

extension CitySearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCities = cities.filter({(city: City) -> Bool in return city.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}


