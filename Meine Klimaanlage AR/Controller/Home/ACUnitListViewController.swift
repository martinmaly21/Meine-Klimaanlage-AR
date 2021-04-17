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
    
    private func registerTableViewCells() {
        tableView.register(UINib(nibName: "ACUnitDetailHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitDetailHeaderTableViewCell")
        tableView.register(UINib(nibName: "ACUnitTableViewCell", bundle: nil), forCellReuseIdentifier: "ACUnitTableViewCell")
    }
    
    private func setUpUI() {
        tableView.separatorStyle = .none
        
        registerTableViewCells()
    }
}

extension ACUnitListViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.setUpCell(with: units[indexPath.row - 1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        //+ 1 to offset header
        
        let selectedUnit = units[indexPath.row - 1]
        if selectedUnit.displayName == "Wandgerät Baureihe TZ" {
            
            if let tabBarController = presentingViewController as? UITabBarController,
               let navigationController = tabBarController.selectedViewController as? UINavigationController,
               let arQuoteViewController = navigationController.topViewController as? ARQuoteViewController {
                //user is selecting a second/third or fourth unit!
                arQuoteViewController.quote.units.append(selectedUnit)
                
                dismiss(
                    animated: true,
                    completion: {
                        arQuoteViewController.addVerticalAnchorCoachingView()
                    }
                )
            } else {
                performSegue(withIdentifier: "newQuoteSegue", sender: selectedUnit)
            }
        } else {
            ErrorManager.showFeatureNotSupported(on: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let beginQuoteViewController = segue.destination as? BeginQuoteViewController, let ACUnit = sender as? ACUnit else { return }
        
        beginQuoteViewController.quote = ACQuote(units: [ACUnit])
    }
}

extension ACUnitListViewController: ACUnitDetailPageTableHeaderViewDelegate {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType) {
        self.currentACUnitEnvironmentType = newType
        getUnits()
    }
}
