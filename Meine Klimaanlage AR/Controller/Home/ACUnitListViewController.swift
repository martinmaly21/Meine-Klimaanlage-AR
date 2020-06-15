//
//  ACUnitListViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ACUnitListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var currentACUnitEnvironmentType = ACUnitEnvironmentType.interior
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
