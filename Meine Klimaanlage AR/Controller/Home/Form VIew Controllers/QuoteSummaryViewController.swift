//
//  QuoteSummaryViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import MessageUI

class QuoteSummaryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    public var quote: ACQuote!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setUpTableView()
    }
    
    private func updateUI() {
        self.title = "Quote Summary"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setUpTableView() {
        tableView.register(UINib(nibName: "QuoteSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteSummaryTableViewCell")
    }

}

extension QuoteSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteSummaryTableViewCell") as? QuoteSummaryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setUpCell(with: quote)
        cell.quoteSummaryCellDelegate = self
        
        return cell
    }
}

extension QuoteSummaryViewController: QuoteSummaryCellDelegate {

    func userPressedDiscardQuote() {
        let actionSheet = UIAlertController(
            title: "Are you sure you'd like to discard this quote?",
            message: "All your work will be lost.",
            preferredStyle: .actionSheet
        )
        
        let discardAction = UIAlertAction(
            title: "Discard",
            style: .destructive,
            handler: { _ in
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popToRootViewController(animated: true)
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
    
    func userPressedSubmitQuote() {
        guard quote.isComplete() else {
            ErrorManager.showMissingFieldsForQuoteError(on: self)
            return
        }
        
        guard MFMailComposeViewController.canSendMail() else {
            ErrorManager.showCannotOpenEmail(on: self)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        
        composeVC.mailComposeDelegate = self
        
        composeVC.setToRecipients([Constants.Quote.quoteEmail])
        #warning("need to change")
        composeVC.setSubject("AC Quote")
        
        var wireInformation = ""
        for wire in quote.wires {
            let wireLength = String(format: "%.2f", Double(wire.wireLength))
            let wireName = String(describing: wire.wireDisplayName)
            wireInformation += "\(wireLength) meters of \(wireName).\n"
        }
        
        var unitsInformation = ""
        for unit in quote.units {
            unitsInformation += "\(unit.displayName) (Quantity: \(unit.quantity))\n"
        }
        
        let messageBody = """
        Customer's Name: \(quote.customerName ?? "")
        Employee's Name: \(quote.employeeName ?? "")
        Date of Appointment: \(quote.appointmentDate ?? "")
        Estimated Price: \(quote.price ?? "") Euro
        
        Wire(s):r
        \(wireInformation)
        AC Unit's:
        \(unitsInformation)
        Wifi: \(quote.wifi ? "Yes" : "No")
        El. Zul.: \(quote.elZul ? "Yes" : "No")
        UV: \(quote.uv ? "Yes" : "No")
        Dachdecker: \(quote.dachdecker ? "Yes" : "No")
        Dachdruchführung: \(quote.dachdruchfuhrung ? "Yes" : "No")
        Kondensatpumpe: \(quote.kondensatpumpe ? "Yes" : "No")
        
        Notes:
        \(quote.notes ?? "")
        """
//        composeVC.addAttachmentData(<#T##attachment: Data##Data#>, mimeType: <#T##String#>, fileName: <#T##String#>)
        composeVC.setMessageBody(messageBody, isHTML: false)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func customerNameUpdated(with customerName: String) {
        quote.customerName = customerName
    }
    
    func employeeNameUpdated(with employeeName: String) {
        quote.employeeName = employeeName
    }
    
    func appointmentDateUpdated(with appointmentDate: String) {
        quote.appointmentDate = appointmentDate
    }
    
    func estimatedPriceUpdated(with estimatedPrice: String) {
        quote.price = estimatedPrice
    }
    
    func noteUpdated(with note: String) {
        quote.notes = note
    }
    
    func wifiUpdated() {
        quote.wifi.toggle()
    }
    
    func elZulUpdated() {
        quote.elZul.toggle()
    }
    
    func uvUpdated() {
        quote.uv.toggle()
    }
    
    func dachdeckerUpdated() {
        quote.dachdecker.toggle()
    }
    
    func dachdruchführungUpdated() {
        quote.dachdruchfuhrung.toggle()
    }
    
    func kondensatpumpeUpdated() {
        quote.kondensatpumpe.toggle()
    }
    
    func userPressedPhoto(with image: UIImage) {
        imageTapped(with: image)
    }
    
    @IBAction func imageTapped(with image: UIImage) {
        let newImageView = UIImageView(image: image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        let swipe = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        newImageView.addGestureRecognizer(swipe)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
}

extension QuoteSummaryViewController: MFMailComposeViewControllerDelegate {
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
                self.tabBarController?.tabBar.isHidden = false
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
