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
    public var brand: ACBrand!
    private var currentACUnitEnvironmentType = ACUnitEnvironmentType.interior
    
    private var units = [ACUnit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getUnits()
    }
    
    private func getUnits() {
        units = NetworkManager.getUnits(for: brand, with: currentACUnitEnvironmentType)
        tableView.reloadData()
    }
    
    private func registerTableViewCellsAndHeader() {
        tableView.register(UINib(nibName: "ACUnitDetailPageTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ACUnitDetailPageTableHeaderView")
        
        tableView.register(UINib(nibName: "ACUnitTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitTableViewCell")
    }
    
    private func setUpUI() {
        registerTableViewCellsAndHeader()
        
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ACUnitDetailPageTableHeaderView") as? ACUnitDetailPageTableHeaderView {
            headerView.delegate = self
            
            headerView.setUpHeaderView(with: brand)
            tableView.tableHeaderView = headerView
        }
    }
}

extension ACUnitListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return units.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ACUnitTableViewCell"
            ) as? ACUnitTableViewCell else {
                return UITableViewCell()
        }
        cell.setUpCell(with: units[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ARSegue", sender: self)
    }
}

extension ACUnitListViewController: ACUnitDetailPageTableHeaderViewDelegate {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType) {
        self.currentACUnitEnvironmentType = newType
        getUnits()
    }
}
