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
    
    func userPressedSubmitQuote()
    func userPressedDiscardQuote()
}

class ACLocationTableViewCell: UITableViewCell {
   
    public var screenshots: [UIImage]!
    
    public weak var quoteSummaryCellDelegate: QuoteSummaryCellDelegate?
    //MARK: - IBOutlets
    
    @IBOutlet weak var unitTitle: UILabel!
    
    @IBOutlet weak var estimatedPriceTextField: UITextField!
    
    @IBOutlet weak var wiresStackView: UIStackView!
    
    @IBOutlet weak var screenshotsCollectionView: UICollectionView!
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    @IBOutlet weak var elZulSwitch: UISwitch!
    @IBOutlet weak var uvSwitch: UISwitch!
    @IBOutlet weak var dachDeckerSwitch: UISwitch!
    @IBOutlet weak var dachdruchführungSwitch: UISwitch!
    @IBOutlet weak var kondensatpumpeSwitch: UISwitch!
    
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
    
    
    public func setUpCell(with location: ACLocation) {
        unitTitle.text = location.acUnit.displayName
        
        self.screenshots = location.screenshots
        
        addWires(with: location.wires)
    }
    
    private func addWires(with wires: [ACWire]) {
        guard !wires.isEmpty else {
            wiresStackView.isHidden = true
            return
        }
        
        for wire in wires {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            
            let wireLabel = UILabel()
            wireLabel.font = UIFont.systemFont(ofSize: 17)
            wireLabel.textColor = UIColor(named: "PrimaryTextDark")
            
            wireLabel.text = "\(wire.wireDisplayName) \(wire.wireLocation == .insideWall ? "(Inside)" : "(Outside)") wall"
            
            stackView.addArrangedSubview(wireLabel)
            
            let wireLength = UILabel()
            wireLength.font = UIFont.systemFont(ofSize: 17)
            wireLength.textColor = UIColor(named: "PrimaryBlue")
            wireLength.textAlignment = .right
            stackView.addArrangedSubview(wireLength)
            
            #warning("handle multiple units here (i.e. picking the same unit twice)")
            let length = String(format: "%.2f", Double(wire.wireLength))
            wireLength.text = "\(length) meters"
            
            wiresStackView.addArrangedSubview(stackView)
        }
    }
    
    
    @IBAction func sendQuoteButton(_ sender: Any) {
        quoteSummaryCellDelegate?.userPressedSubmitQuote()
    }
    
    @IBAction func discardButtonClicked(_ sender: Any) {
        quoteSummaryCellDelegate?.userPressedDiscardQuote()
    }
}

extension ACLocationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

