//
//  HomeViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    //MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
     //MARK: - Data
    let brands = ["Daikin","Mitsubishi Motors","Panasonic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        registerTableViewCells()
    }
    
    private func registerTableViewCells() {
        tableView.register(UINib(nibName: "ACUnitBrandsTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitBrandsTableViewCell")
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ACUnitBrandsTableViewCell"
            ) as? ACUnitBrandsTableViewCell else {
            return UITableViewCell()
        }
        cell.setUpCell(with: brands[indexPath.row])
        return cell
    }
    
}
