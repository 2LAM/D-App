//
//  WeatherDetailViewController.swift
//  DataThere
//
//  Created by Tu Lam Lam on 30/4/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import UIKit

class WeatherDetailViewController: UIViewController {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var weatherDetailsTextView: UITextView!
    var weatherDetails: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherDetailsTextView.text = weatherDetails
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
