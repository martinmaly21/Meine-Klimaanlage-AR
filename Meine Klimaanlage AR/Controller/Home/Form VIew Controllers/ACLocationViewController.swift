//
//  ACLocationViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import MessageUI
import PhotosUI

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
        acLocation.dachdruchführung = dachdruchführung
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
        
        dismiss(animated: true, completion: nil)
    }
    
    func userPressedPhoto(with image: UIImage) {
        imageTapped(with: image)
    }
    
    func userPressedAddPhoto(from cell: UICollectionViewCell) {
        presentImagePickerChoice(from: cell)
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

extension ACLocationViewController {
    private func presentImagePickerChoice(from cell: UICollectionViewCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhotoPickerAction = UIAlertAction(
            title: "Take photo",
            style: .default,
            handler: { _ in
                self.presentImagePicker(.camera)
            }
        )

        let photoLibraryPickerAction = UIAlertAction(
            title: "Choose photo",
            style: .default,
            handler: { _ in
                self.presentImagePicker(.photoLibrary)
            }
        )
        
        let alignmentMode = CATextLayerAlignmentMode.left
        let alignmentKey = "titleTextAlignment"
        
        takePhotoPickerAction.setValue(alignmentMode, forKey: alignmentKey)
        photoLibraryPickerAction.setValue(alignmentMode, forKey: alignmentKey)
        
        takePhotoPickerAction.setValue(UIImage(systemName: "camera"), forKey: "image")
        photoLibraryPickerAction.setValue(UIImage(systemName: "photo"), forKey: "image")

        alert.addAction(takePhotoPickerAction)
        alert.addAction(photoLibraryPickerAction)

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "CANCEL",
                    value: "Cancel",
                    comment: "Generic 'Cancel' string"
                ),
                style: .cancel,
                handler: nil
            )
        )

        alert.popoverPresentationController?.sourceView = cell

        present(alert, animated: true, completion: nil)
    }
    
    private func presentImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        if #available(iOS 14.0, *), sourceType != .camera {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
            return
        }

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = false
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    private func updateCell(with newImage: UIImage) {
        acLocation.screenshots.append(newImage)
        
        DispatchQueue.main.async {
            self.updateACLocation()
            self.tableView.reloadData()
        }
    }
}

extension ACLocationViewController: UINavigationControllerDelegate { }

extension ACLocationViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let returnedImage = (
            info[UIImagePickerController.InfoKey.editedImage] as? UIImage ??
                info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            ) else {

                ErrorManager.showInvalidImage(on: self)
                return
        }
        
        updateCell(with: returnedImage)
    }
}

@available(iOS 14, *)
extension ACLocationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            guard let returnedImage = image as? UIImage else { return }
            
            self.updateCell(with: returnedImage)
        }
    }
}
