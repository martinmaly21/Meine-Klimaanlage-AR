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
    
    private var quote: ACQuote {
        guard let homeNavigationController = navigationController as? HomeNavigationController,
              let currentQuote = homeNavigationController.currentQuote else {
            fatalError("Error retrieving quote")
        }
        return currentQuote
    }
    
    private var arViewController: ARQuoteViewController? {
        guard let tabBarController = presentingViewController as? UITabBarController,
              let navigationController = tabBarController.selectedViewController as? UINavigationController,
              let arViewController = navigationController.topViewController as? ARQuoteViewController else {
            return nil
        }
        return arViewController
    }
    
    private var presentedOverARSession: Bool {
        return arViewController != nil
    }
    
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
        
        if presentedOverARSession {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(didPressCancel)
            )
        }
    }
    
    @objc func didPressCancel() {
        dismiss(animated: true, completion: nil)
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
            with: units[indexPath.row - 1],
            shouldAddChevron: !presentedOverARSession
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        //+ 1 to offset header
        
        let selectedUnit = units[indexPath.row - 1]
        
        if selectedUnit.displayName == "Wandgerät Baureihe TZ" {
            //update quote
            let location = ACLocation(acUnit: selectedUnit)
            quote.locations.append(location)
            
            performSegue(withIdentifier: "ARSegue", sender: nil)
        } else {
            ErrorManager.showFeatureNotSupported(on: self)
        }
    }
}

extension ChooseACUnitViewController: ACUnitDetailPageTableHeaderViewDelegate {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType) {
        self.currentACUnitEnvironmentType = newType
        getUnits()
    }
}