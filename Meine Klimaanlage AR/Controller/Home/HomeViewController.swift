//
//  HomeViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    //MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
     //MARK: - Data
    let brands: [ACBrand] = [.daikin, .mitsubishiMotors, .panasonic]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        registerTableViewCells()
        
        //set title
        if let currentUserName = Auth.auth().currentUser?.displayName {
            navigationItem.title = "Welcome \(currentUserName)!"
        }
    }
    
    private func registerTableViewCells() {
        tableView.register(UINib(nibName: "ACUnitBrandsTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitBrandsTableViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ACUnitSegue",
            let sender = sender as? ACUnitBrandsTableViewCell,
            let detailPage = segue.destination as? ACUnitListViewController {
            detailPage.title = sender.brand.rawValue
            detailPage.brand = sender.brand
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        if brands[indexPath.row] == .panasonic {
            performSegue(withIdentifier: "ACUnitSegue", sender: selectedCell)
        } else {
            return
        }
    }
    
    
}
