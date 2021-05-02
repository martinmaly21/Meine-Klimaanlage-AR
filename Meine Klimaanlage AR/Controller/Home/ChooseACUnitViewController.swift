//
//  ChooseACUnitViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ChooseACUnitViewController: UIViewController {
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
    
    private func registerTableViewCells() {
        tableView.register(UINib(nibName: "ACUnitDetailHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitDetailHeaderTableViewCell")
        tableView.register(UINib(nibName: "ACUnitTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitTableViewCell")
    }
    
    private func setUpUI() {
        tableView.separatorStyle = .none
        
        registerTableViewCells()
    }
}

extension ChooseACUnitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfHeaders = 1
        return numberOfHeaders + units.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != 0 else {
            //header
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ACUnitDetailHeaderTableViewCell"
                ) as? ACUnitDetailHeaderTableViewCell else {
                    return UITableViewCell()
            }
            cell.delegate = self
            cell.setUpHeaderView(with: brand)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ACUnitTableViewCell"
            ) as? ACUnitTableViewCell else {
            return UITableViewCell()
        }
        //+ 1 to offset header
        cell.setUpCell(
            with: units[indexPath.row - 1]
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        //+ 1 to offset header
        
        let selectedUnit = units[indexPath.row - 1]
        
        if selectedUnit.displayName == "Wandgerät Baureihe TZ" {
            //update quote
            let acLocation = ACLocation(acUnit: selectedUnit)
            
            performSegue(withIdentifier: "ARSegue", sender: acLocation)
        } else {
            ErrorManager.showFeatureNotSupported(on: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ARSegue",
           let arViewController = segue.destination as? ARQuoteViewController,
           let acLocation = sender as? ACLocation {
            arViewController.acLocation = acLocation
        }
    }
}

extension ChooseACUnitViewController: ACUnitDetailPageTableHeaderViewDelegate {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType) {
        self.currentACUnitEnvironmentType = newType
        getUnits()
    }
}
