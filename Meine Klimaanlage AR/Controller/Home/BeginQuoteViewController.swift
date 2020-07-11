//
//  BeginQuoteViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class BeginQuoteViewController: UIViewController {
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var employeeNameTextField: UITextField!
    @IBOutlet weak var appointmentDateTextField: UITextField!
    
    public var quote: ACQuote!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        unitNameLabel.text = quote.units.first?.displayName

        employeeNameTextField.text = Auth.auth().currentUser?.displayName
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        appointmentDateTextField.text = formatter.string(from: currentDateTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arViewController = segue.destination as? ARViewController {
           
            quote.customerName = customerNameTextField.text
            quote.employeeName = employeeNameTextField.text
            quote.appointmentDate = appointmentDateTextField.text
            
            arViewController.quote = quote
        }
    }
    
    @IBAction func didPressARMode(_ sender: Any) {
        performSegue(withIdentifier: "ARsegue", sender: nil)
    }
}
