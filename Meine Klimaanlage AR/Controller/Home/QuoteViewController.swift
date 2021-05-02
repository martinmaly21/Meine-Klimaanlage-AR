//
//  QuoteViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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
        tableView.register(
            UINib(
                nibName: "SendQuoteTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "SendQuoteTableViewCell"
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
        case is SendQuoteTableViewCell:
            userPressedSendQuoteTableViewCell()
        default:
            fatalError("Unexpected cell type")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func userPressedCreateANewLocationTableViewCell() {
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
        let navigationController = UINavigationController(rootViewController: acLocationViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    private func userPressedSendQuoteTableViewCell() {
        guard let customerName = self.customerName, !customerName.isEmpty,
              let employeeName = self.employeeName, !employeeName.isEmpty,
              let appointmentDate = self.appointmentDate, !appointmentDate.isEmpty else {
            ErrorManager.showMissingFieldsForQuoteError(on: self)
            return
        }
        
        QuoteManager.currentQuote.customerName = customerName
        QuoteManager.currentQuote.employeeName = employeeName
        QuoteManager.currentQuote.appointmentDate = appointmentDate
        
        guard !QuoteManager.currentQuote.locations.isEmpty else {
            ErrorManager.showMissingLocationError(on: self)
            return
        }
        
        //show email
        guard MFMailComposeViewController.canSendMail() else {
            ErrorManager.showCannotOpenEmail(on: self)
            return
        }
        
//
//        let composeVC = MFMailComposeViewController()
//
//        composeVC.mailComposeDelegate = self
//
//        composeVC.setToRecipients([Constants.Quote.quoteEmail])
//        composeVC.setSubject("AC Quote")
//
//        var wireInformation = ""
//        for wire in quote.wires {
//            let wireLength = String(format: "%.2f", Double(wire.wireLength))
//            let wireName = String(describing: wire.wireDisplayName)
//            wireInformation += "\(wireLength) meters of \(wireName).\n"
//        }
//
//        var unitsInformation = ""
//        for unit in quote.units {
//            unitsInformation += "\(unit.displayName) (Quantity: \(unit.quantity))\n"
//        }
//
//        let messageBody = """
//        Customer's Name: \(quote.customerName ?? "")
//        Employee's Name: \(quote.employeeName ?? "")
//        Date of Appointment: \(quote.appointmentDate ?? "")
//        Estimated Price: \(quote.price ?? "") Euro
//
//        Wire(s):
//        \(wireInformation)
//        AC Unit's:
//        \(unitsInformation)
//        Wifi: \(quote.wifi ? "Yes" : "No")
//        El. Zul.: \(quote.elZul ? "Yes" : "No")
//        UV: \(quote.uv ? "Yes" : "No")
//        Dachdecker: \(quote.dachdecker ? "Yes" : "No")
//        Dachdruchführung: \(quote.dachdruchfuhrung ? "Yes" : "No")
//        Kondensatpumpe: \(quote.kondensatpumpe ? "Yes" : "No")
//
//        Notes:
//        \(quote.notes ?? "")
//        """
//        composeVC.setMessageBody(messageBody, isHTML: false)
//
//        if let screenshot = quote.screenshots.first,
//           let screenshotImageData = screenshot.pngData() {
//            composeVC.addAttachmentData(screenshotImageData, mimeType: "image/png", fileName: "\(quote.units.first?.displayName ?? "Unit")_Screenshot")
//        }
//
//        self.present(composeVC, animated: true, completion: nil)
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
            let numberOfSendQuoteCells = 1
            return numberOfCreateACLocationCells + QuoteManager.currentQuote.locations.count + numberOfSendQuoteCells
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
            case QuoteManager.currentQuote.locations.count + 1:
                //+1 is to account for QuoteCreateANewLocationTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SendQuoteTableViewCell") as? SendQuoteTableViewCell else {
                    fatalError("Could not create SendQuoteTableViewCell")
                }
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteLocationTableViewCell") as? QuoteLocationTableViewCell else {
                    fatalError("Could not create QuoteLocationTableViewCell")
                }
                //the '-1' is to account for QuoteCreateANewLocationTableViewCell
                let acLocation = QuoteManager.currentQuote.locations[indexPath.row - 1]
                cell.setUpCell(with: acLocation)
                return cell
            }
        }
    }
}
