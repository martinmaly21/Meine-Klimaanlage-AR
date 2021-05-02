//
//  QuoteInformationTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class QuoteInformationTableViewCell: UITableViewCell {
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var employeeNameTextField: UITextField!
    @IBOutlet weak var appointmentDateTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    public func setUpUI() {
        employeeNameTextField.text = Auth.auth().currentUser?.displayName
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        
        appointmentDateTextField.text = formatter.string(from: currentDateTime)
    }
}
