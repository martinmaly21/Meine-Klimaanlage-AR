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
    
    private var indexOfACLocationInQuote: Int? {
        return QuoteManager.currentQuote.locations.firstIndex(where: { return $0.id == acLocation.id })
    }
    
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
        acLocation.price = estimatedPrice
        
        acLocation.wifi = wifi
        acLocation.elZul = elZul
        acLocation.uv = uv
        acLocation.dachdecker = dachdecker
        acLocation.dachdruchführung = dachdruchführung
        acLocation.kondensatpumpe = kondensatpumpe
        
        acLocation.notes = notes
    }

    @objc func didPressDiscard() {
        userPressedDiscardLocation(from: nil)
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
    func userPressedDiscardLocation(from view: UIView?) {
        let actionSheet = UIAlertController(
            title: "Are you sure you'd like to discard this location?",
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
        
        if let sender = view {
            actionSheet.popoverPresentationController?.sourceView = sender
        } else {
            actionSheet.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func userConfirmedDiscard() {
        if let indexOfACLocationInQuote = indexOfACLocationInQuote {
            //remove discarded location
            QuoteManager.currentQuote.locations.remove(at: indexOfACLocationInQuote)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func userPressedSaveLocation() {
        updateACLocation()
        
        guard acLocation.isComplete() else {
            ErrorManager.showMissingFieldsForQuoteError(on: self)
            return
        }
        
        //only add acLocation if it's nil
        if indexOfACLocationInQuote == nil {
            QuoteManager.currentQuote.locations.insert(acLocation, at: 0)
        }
        
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
        picker.dismiss(animated: true, completion: nil)
        
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
