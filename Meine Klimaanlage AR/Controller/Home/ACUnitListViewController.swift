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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func registerTableViewCellsAndHeader() {
        tableView.register(UINib(nibName: "ACUnitDetailPageTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ACUnitDetailPageTableHeaderView")
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

extension ACUnitListViewController: ACUnitDetailPageTableHeaderViewDelegate {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType) {
        self.currentACUnitEnvironmentType = newType
    }
}
