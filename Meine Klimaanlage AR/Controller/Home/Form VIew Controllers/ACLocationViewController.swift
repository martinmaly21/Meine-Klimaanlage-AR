//
//  ACLocationViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import MessageUI

class ACLocationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let acLocation: ACLocation
    
    private var acLocationTableViewCell: ACLocationTableViewCell {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ACLocationTableViewCell else {
            fatalError("Could not get ACLocationTableViewCell")
        }
        return cell
    }
    
    private var location: String? {
        acLocationTableViewCell.locationTextField.text
    }
    
    private var estimatedPrice: String? {
        return acLocationTableViewCell.estimatedPriceTextField.text
    }
    
    private var wifi: Bool {
        return acLocationTableViewCell.wifiSwitch.isOn
    }
    
    private var elZul: Bool {
        return acLocationTableViewCell.elZulSwitch.isOn
    }
    
    private var uv: Bool {
        return acLocationTableViewCell.uvSwitch.isOn
    }
    
    private var dachdecker: Bool {
        return acLocationTableViewCell.dachDeckerSwitch.isOn
    }
    
    private var dachdruchführung: Bool {
        return acLocationTableViewCell.dachdruchführungSwitch.isOn
    }
    
    private var kondensatpumpe: Bool {
        return acLocationTableViewCell.kondensatpumpeSwitch.isOn
    }
    
    private var notes: String? {
        return acLocationTableViewCell.noteTextField.text
    }
    
    init(acLocation: ACLocation) {
        self.acLocation = acLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setUpTableView()
    }
    
    private func updateUI() {
        self.title = "Summary"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let discardButton = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(didPressDiscard))
        navigationItem.leftBarButtonItem = discardButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didPressSave))
        navigationItem.rightBarButtonItem = saveButton
    }

    private func setUpTableView() {
        tableView.register(UINib(nibName: "ACLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "ACLocationTableViewCell")
    }
    
    
    private func updateACLocation() {
        acLocation.name = location
        acLocation.price = (estimatedPrice as NSString?)?.floatValue
        
        acLocation.wifi = wifi
        acLocation.elZul = elZul
        acLocation.uv = uv
        acLocation.dachdecker = dachdecker
        acLocation.dachdruchfuhrung = dachdruchführung
        acLocation.kondensatpumpe = kondensatpumpe
        
        acLocation.notes = notes
    }

    @objc func didPressDiscard() {
        userPressedDiscardLocation()
    }
    
    @objc func didPressSave() {
        userPressedSaveLocation()
    }
}

extension ACLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ACLocationTableViewCell") as? ACLocationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setUpCell(with: acLocation)
        cell.quoteSummaryCellDelegate = self
        
        return cell
    }
}

extension ACLocationViewController: QuoteSummaryCellDelegate {
    func userPressedDiscardLocation() {
        let actionSheet = UIAlertController(
            title: "Are you sure you'd like to discard this location?",
            message: "All your work will be lost.",
            preferredStyle: .actionSheet
        )
        
        let discardAction = UIAlertAction(
            title: "Discard",
            style: .destructive,
            handler: { _ in
                self.dismiss(animated: true, completion: nil)
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
    
    func userPressedSaveLocation() {
        updateACLocation()
        
        guard acLocation.isComplete() else {
            ErrorManager.showMissingFieldsForQuoteError(on: self)
            return
        }


        QuoteManager.currentQuote.locations.insert(acLocation, at: 0)
        
        //TODO reload data upon dismiss?
        dismiss(animated: true, completion: nil)
        
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

extension ACLocationViewController: MFMailComposeViewControllerDelegate {
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
