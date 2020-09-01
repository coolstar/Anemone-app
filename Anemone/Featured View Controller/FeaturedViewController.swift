//
//  FeaturedViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class FeaturedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openSileo(_: Any?){
        UIApplication.shared.open(URL(string: "sileo://")!, options: [:], completionHandler: nil)
    }
}
