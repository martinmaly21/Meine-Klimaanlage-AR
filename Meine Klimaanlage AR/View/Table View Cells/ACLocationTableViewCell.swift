//
//  PreviewQuoteTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit


protocol QuoteSummaryCellDelegate: class {
    func userPressedAddPhoto(from cell: UICollectionViewCell)
    func userPressedPhoto(with image: UIImage)
    
    func userPressedSaveLocation()
    func userPressedDiscardLocation()
}

class ACLocationTableViewCell: UITableViewCell {
   
    public var screenshots: [UIImage]!
    
    public weak var quoteSummaryCellDelegate: QuoteSummaryCellDelegate?
    //MARK: - IBOutlets
    
    @IBOutlet weak var unitTitle: UILabel!
    
    @IBOutlet weak var locationTextField: UITextField!
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
        
        screenshotsCollectionView.showsHorizontalScrollIndicator = false
        
        screenshotsCollectionView.register(
            UINib(
                nibName: "ScreenshotCollectionViewCell", bundle: nil
            ), forCellWithReuseIdentifier: "ScreenshotCollectionViewCell"
        )
        
        screenshotsCollectionView.register(
            UINib(
                nibName: "AddPhotoCollectionViewCell", bundle: nil
            ), forCellWithReuseIdentifier: "AddPhotoCollectionViewCell"
        )
    }
    
    
    public func setUpCell(with location: ACLocation) {
        unitTitle.text = location.acUnit.displayName
        
        locationTextField.text = location.name
        estimatedPriceTextField.text = "\(String(describing: location.price))"
        
        addWires(with: location.wires)
        
        screenshots = location.screenshots
        screenshotsCollectionView.reloadData()
        
        wifiSwitch.isOn = location.wifi
        elZulSwitch.isOn = location.elZul
        uvSwitch.isOn = location.uv
        dachDeckerSwitch.isOn = location.dachdecker
        dachdruchführungSwitch.isOn = location.dachdruchführung
        kondensatpumpeSwitch.isOn = location.kondensatpumpe
        
        noteTextField.text = location.notes
    }
    
    private func addWires(with wires: [ACWire]) {
        for arrangedSubview in wiresStackView.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
        
        guard !wires.isEmpty else {
            wiresStackView.isHidden = true
            return
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Wire Info"
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        titleLabel.textColor = Constants.Color.primaryTextDark
        
        wiresStackView.addArrangedSubview(titleLabel)
        
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
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        quoteSummaryCellDelegate?.userPressedSaveLocation()
    }
    
    @IBAction func discardButtonClicked(_ sender: Any) {
        quoteSummaryCellDelegate?.userPressedDiscardLocation()
    }
}

extension ACLocationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfAddPhotos = 1
        return screenshots.count + numberOfAddPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.row < screenshots.count else {
            //show add screenshot cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCollectionViewCell", for: indexPath) as? AddPhotoCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCollectionViewCell", for: indexPath) as? ScreenshotCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setUpCell(with: screenshots[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < screenshots.count else {
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                fatalError("Could not get cell")
            }
            quoteSummaryCellDelegate?.userPressedAddPhoto(from: cell)
            return
        }
        
        quoteSummaryCellDelegate?.userPressedPhoto(with: screenshots[indexPath.row])
    }
}

