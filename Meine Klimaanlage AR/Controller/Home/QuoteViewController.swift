//
//  QuoteViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class QuoteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var customerName: String? {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? QuoteInformationTableViewCell
        return cell?.customerNameTextField.text
    }
    
    private var employeeName: String? {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? QuoteInformationTableViewCell
        return cell?.employeeNameTextField.text
    }
    
    private var appointmentDate: String? {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? QuoteInformationTableViewCell
        return cell?.appointmentDateTextField.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        setUpUI()
    }
    
    private func registerTableViewCells() {
        tableView.register(
            UINib(
                nibName: "QuoteInformationTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "QuoteInformationTableViewCell"
        )
        tableView.register(
            UINib(
                nibName: "QuoteCreateANewLocationTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "QuoteCreateANewLocationTableViewCell"
        )
        tableView.register(
            UINib(
                nibName: "QuoteLocationTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "QuoteLocationTableViewCell"
        )
        
        //register header
        tableView.register(
            UINib(
                nibName: "QuoteSectionHeader",
                bundle: nil
            ),
            forHeaderFooterViewReuseIdentifier: "QuoteSectionHeader"
        )
    }
    
    private func setUpUI() {
        tableView.tableFooterView = UIView()
    }
}

extension QuoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case is QuoteInformationTableViewCell: break
        case is QuoteCreateANewLocationTableViewCell:
            userPressedCreateANewLocationTableViewCell()
        case let cell as QuoteLocationTableViewCell:
            userPressedQuoteLocationTableViewCell(with: cell)
        default:
            fatalError("Unexpected cell type")
        }
    }
    
    private func userPressedCreateANewLocationTableViewCell() {
        guard let customerName = self.customerName, !customerName.isEmpty,
              let employeeName = self.employeeName, !employeeName.isEmpty,
              let appointmentDate = self.appointmentDate, !appointmentDate.isEmpty else {
            ErrorManager.showMissingFieldsForACLocationError(on: self)
            return
        }
        guard let vc = UIStoryboard(name: "ACLocation", bundle: nil).instantiateInitialViewController() else {
            fatalError("Couldn't get storyboard")
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func userPressedQuoteLocationTableViewCell(with cell: QuoteLocationTableViewCell) {
        guard let acLocation = cell.acLocation else {
            fatalError("Error getting acLocation")
        }
        
        let acLocationViewController = ACLocationViewController(acLocation: acLocation)
        navigationController?.pushViewController(acLocationViewController, animated: true)
    }
}

extension QuoteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "QuoteSectionHeader") as? QuoteSectionHeader
        
        header?.titleLabel.text = section == 0 ? "Information" : "Locations"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let numberOfQuoteInformationCells = 1
            return numberOfQuoteInformationCells
        } else {
            //section 1
            let numberOfCreateACLocationCells = 1
            return numberOfCreateACLocationCells + QuoteManager.currentQuote.locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteInformationTableViewCell") as? QuoteInformationTableViewCell else {
                fatalError("Could not create QuoteInformationTableViewCell")
            }
            cell.setUpUI()
            return cell
        } else {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCreateANewLocationTableViewCell") as? QuoteCreateANewLocationTableViewCell else {
                    fatalError("Could not create QuoteCreateANewLocationTableViewCell")
                }
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteLocationTableViewCell") as? QuoteLocationTableViewCell else {
                    fatalError("Could not create QuoteLocationTableViewCell")
                }
                //the '-1' is to account for QuoteCreateANewLocationTableViewCell
                let acLocation = QuoteManager.currentQuote.locations[indexPath.row - 1]
                cell.acLocation = acLocation
                cell.setUpCell(with: acLocation.name)
                return cell
            }
        }
    }
}
