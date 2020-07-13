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
    
    func customerNameUpdated(with customerName: String)
    func employeeNameUpdated(with employeeName: String)
    func appointmentDateUpdated(with appointmentDate: String)
    func estimatedPriceUpdated(with estimatedPrice: String)
    
    func noteUpdated(with note: String)
}

class QuoteSummaryTableViewCell: UITableViewCell {
   
    public var screenshots: [UIImage]!
    
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
        self.screenshots = quote.screenshots
        
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
            
            let wireLength = UILabel()
            wireLength.font = UIFont.systemFont(ofSize: 17)
            wireLength.textColor = UIColor(named: "PrimaryBlue")
            wireLength.textAlignment = .right
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
            
            let quantityTextField = UILabel()
            quantityTextField.font = UIFont.systemFont(ofSize: 17)
            quantityTextField.textColor = UIColor(named: "PrimaryBlue")
            quantityTextField.textAlignment = .right
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
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCollectionViewCell", for: indexPath) as? ScreenshotCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setUpCell(with: screenshots[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        quoteSummaryCellDelegate?.userPressedPhoto(with: screenshots[indexPath.row])
    }
}

extension QuoteSummaryTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        switch textField {
        case customerNameTextField:
            quoteSummaryCellDelegate?.customerNameUpdated(with: textFieldText)
        case employeeNameTextField:
            quoteSummaryCellDelegate?.employeeNameUpdated(with: textFieldText)
        case appointmentDateTextField:
            quoteSummaryCellDelegate?.appointmentDateUpdated(with: textFieldText)
        case estimatedPriceTextField:
            quoteSummaryCellDelegate?.estimatedPriceUpdated(with: textFieldText)
        case noteTextField:
            quoteSummaryCellDelegate?.noteUpdated(with: textFieldText)
        default:
            assertionFailure()
        }
    }
}
