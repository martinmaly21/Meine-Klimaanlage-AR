//
//  PreviewQuoteTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit


protocol QuoteSummaryCellDelegate: class {
    func userPressedPhoto(with image: UIImage)
}

class QuoteSummaryTableViewCell: UITableViewCell {
   
    public var quote: ACQuote!
    public weak var quoteSummaryCellDelegate: QuoteSummaryCellDelegate?
    //MARK: - IBOutlets
    
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var employeeNameTextField: UITextField!
    @IBOutlet weak var appointmentDateTextField: UITextField!
    @IBOutlet weak var estimatedPriceTextField: UITextField!
    
    @IBOutlet weak var wiresStackView: UIStackView!
    @IBOutlet weak var unitsStackView: UIStackView!
    
    @IBOutlet weak var screenshotsCollectionView: UICollectionView!
    
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var elZulButton: UIButton!
    @IBOutlet weak var uvButton: UIButton!
    @IBOutlet weak var dachDeckerButton: UIButton!
    @IBOutlet weak var dachdruchführungButton: UIButton!
    @IBOutlet weak var kondensatpumpeButton: UIButton!
    
    @IBOutlet weak var noteTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        
    }
    
    
    private func setUpUI() {
        selectionStyle = .none
        
        screenshotsCollectionView.delegate = self
        screenshotsCollectionView.dataSource = self
        
        screenshotsCollectionView.register(
            UINib(
                nibName: "ScreenshotCollectionViewCell", bundle: nil
            ), forCellWithReuseIdentifier: "ScreenshotCollectionViewCell"
        )
    }
    
    
    public func setUpCell(with quote: ACQuote) {
        self.quote = quote
        
        customerNameTextField.text = quote.customerName
        employeeNameTextField.text = quote.employeeName
        appointmentDateTextField.text = quote.appointmentDate
        
        addWires(with:quote.wires)
        addUnits(with: quote.units)
    }
    
    private func addWires(with wires: [Wire]) {
         #warning("handle multiple wires here (i.e. picking the same wire twice)")
        for wire in wires {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            
            let wireLabel = UILabel()
            wireLabel.font = UIFont.systemFont(ofSize: 17)
            wireLabel.textColor = UIColor(named: "PrimaryTextDark")
            
            
            switch wire.wireType {
            case .rohrleitungslänge:
                wireLabel.text = "Rohrleitungslänge"
            case .kabelkanal:
                wireLabel.text = "Kabelkanal"
            case .kondensatleitung:
                wireLabel.text = "Kondensatleitung"
            default:
                assertionFailure()
            }
            
            stackView.addArrangedSubview(wireLabel)
            
            let wireLength = UITextField()
            wireLength.delegate = self
            
            wireLength.font = UIFont.systemFont(ofSize: 17)
            wireLength.textColor = UIColor(named: "PrimaryBlue")
            stackView.addArrangedSubview(wireLength)
            
            #warning("handle multiple units here (i.e. picking the same unit twice)")
            let length = String(format: "%.2f", Double(wire.wireLength))
            wireLength.text = "\(length) meters"
            
            #warning("handle wire location (outside/inside)")
            
            wiresStackView.addArrangedSubview(stackView)
        }
    }
    
    private func addUnits(with units: [ACUnit]) {
        for unit in units {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            
            let unitLabel = UILabel()
            unitLabel.font = UIFont.systemFont(ofSize: 17)
            unitLabel.textColor = UIColor(named: "PrimaryTextDark")
            unitLabel.text = unit.displayName
            stackView.addArrangedSubview(unitLabel)
            
            let quantityTextField = UITextField()
            quantityTextField.delegate = self
            
            quantityTextField.font = UIFont.systemFont(ofSize: 17)
            quantityTextField.textColor = UIColor(named: "PrimaryBlue")
            stackView.addArrangedSubview(quantityTextField)
        
            #warning("handle multiple units here (i.e. picking the same unit twice)")
            quantityTextField.text = "1"
            
            unitsStackView.addArrangedSubview(stackView)
        }
        
        
       
    }
    
    @IBAction func sendQuoteButton(_ sender: UIButton) {
    }
}

extension QuoteSummaryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quote.screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCollectionViewCell", for: indexPath) as? ScreenshotCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setUpCellI(with: quote.screenshots[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        quoteSummaryCellDelegate?.userPressedPhoto(with: quote.screenshots[indexPath.row])
    }
}

extension QuoteSummaryTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        //check textfield
    }
}
