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
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(userPressedCancel))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func userPressedCancel() {
        let actionSheet = UIAlertController(
            title: "Are you sure you'd like to discard this quote?",
            message: "All your work will be lost.",
            preferredStyle: .actionSheet
        )
        
        let discardAction = UIAlertAction(
            title: "Discard",
            style: .destructive,
            handler: { _ in
                self.userConfirmedDiscard()
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: nil
        )
        
        actionSheet.addAction(discardAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func userConfirmedDiscard() {
        navigationController?.popViewController(animated: true)
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

        let composeVC = MFMailComposeViewController()

        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([Constants.Quote.quoteEmail])
        composeVC.setSubject("AC Quote")
        
        guard let quote = QuoteManager.currentQuote else {
            fatalError("Could not get quote")
        }

        var messageBody = """
        Customer's Name: \(quote.customerName ?? "")
        Employee's Name: \(quote.employeeName ?? "")
        Date of Appointment: \(quote.appointmentDate ?? "")
        """
        
        for location in quote.locations {
            var wireInformation = ""
            for wire in location.wires {
                let wireLength = String(format: "%.2f", Double(wire.wireLength))
                let wireName = String(describing: wire.wireDisplayName)
                wireInformation += "\(wireLength) meters of \(wireName).\n"
            }
            
            messageBody += """

            \n---------------------
            Location: \(location.name?.isEmpty ?? true ? "Not provided" : "\(location.name!)")
            AC Unit: \(location.acUnit.displayName)
            Estimated price: \(location.price ?? "0") Euro

            Wire(s):
            \(wireInformation.isEmpty ? "None provided" : "\(wireInformation)")

            Wifi: \(location.wifi ? "Yes" : "No")
            El. Zul.: \(location.elZul ? "Yes" : "No")
            UV: \(location.uv ? "Yes" : "No")
            Dachdecker: \(location.dachdecker ? "Yes" : "No")
            Dachdruchführung: \(location.dachdruchführung ? "Yes" : "No")
            Kondensatpumpe: \(location.kondensatpumpe ? "Yes" : "No")

            Notes:
            \(location.notes?.isEmpty ?? true ? "None provided" : "\(location.notes!)")
            """
        }
        
        composeVC.setMessageBody(messageBody, isHTML: false)
        
        let screenshotsData = quote.locations.flatMap { $0.screenshots.compactMap { $0.pngData() } }

        for (index, screenshotData) in screenshotsData.enumerated() {
            composeVC.addAttachmentData(
                screenshotData,
                mimeType: "image/png",
                fileName: "Screenshot_\(index)"
            )
        }

        self.present(composeVC, animated: true, completion: nil)
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

extension QuoteViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        self.dismiss(animated: true) {
            switch result {
            case .sent:
                let successAlert = UIAlertController(
                    title: "Success!",
                    message: "Your quote was successfully sent.",
                    preferredStyle: .alert
                )
                
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                successAlert.addAction(okayAction)
                
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.present(successAlert, animated: true, completion: nil)
            case .failed, .saved, .cancelled:
                let informationlert = UIAlertController(
                    title: "Error",
                    message: "Your quote was not sent.",
                    preferredStyle: .alert
                )
                
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                informationlert.addAction(okayAction)
                
                self.present(informationlert, animated: true, completion: nil)
            @unknown default:
                fatalError()
            }
        }
    }
}
