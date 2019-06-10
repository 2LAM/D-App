//
//  ViewController.swift
//  DataThere
//
//  Created by Tu Lam Lam on 28/4/19.
//  Copyright © 2019 Tu Lam Lam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let weather = Weather()
        weather.getWeatherInfo()
    }


}

