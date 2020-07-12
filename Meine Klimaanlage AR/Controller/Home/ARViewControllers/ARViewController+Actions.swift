/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ARViewController: UIGestureRecognizerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
    }
    
    // MARK: - Interface Actions
    
    /// Displays the `VirtualObjectSelectionViewController` from the `addObjectButton` or in response to a tap gesture in the `sceneView`.
    @IBAction func userPressedAddUnit() {
        guard !acUnitHasBeenPlaced else {
            acUnitWasConfirmed()
            return
        }
        
        #warning("this shouldn't be called when user simply taps on the screen")
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard addObjectButton.isEnabled && !virtualObjectLoader.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        
        if let filePath = Bundle.main.path(forResource: currentACUnit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") {
            // ReferenceNode path -> ReferenceNode URL
            let referenceURL = URL(fileURLWithPath: filePath)
            
            // let url = URL(fileReferenceLiteralResourceName: "Panasonic.scn")
            let virtualObject = VirtualObject(url: referenceURL)!
            
            if let query = sceneView.getRaycastQuery(for: virtualObject.allowedAlignment),
                let result = sceneView.castRay(for: query).first {
                virtualObject.mostRecentInitialPlacementResult = result
                virtualObject.raycastQuery = query
            }
            
            virtualObjectSelectionViewController(didSelectObject: virtualObject)
        }
    }
    
    @IBAction func userPressedAddWire() {
        wirePoints.removeAll()
        
        let chooseWireVC = ChooseTypeOfWireViewController()
        let navigationController = UINavigationController(rootViewController: chooseWireVC)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func didPressSaveUnit(_ sender: UIButton) {
        instructionsLabel.text = "Place the AC UNit and all wires in view and then click 'Capture' to take a screenshot."
        wireButtonStackView.isHidden = true
        captureButton.isHidden = false
        
    }
    
    @IBAction func didPressCapture(_ sender: UIButton)  {
        //take screenshot
        let capture = sceneView.snapshot()
        quote.screenshots.append(capture)
        
        instructionsLabel.textColor = UIColor.green
        instructionsLabel.text = "Success!"
        
        //hide capture button
        captureButton.isHidden = true
        
        //show buttons: finsih or add another unit
        addAnotherUnitOrFinishStackView.isHidden = false
    }
    
    @IBAction func didPressAddAnotherUnit(_ sender: UIButton) {
        
    }
    
    @IBAction func didPressFinish(_ sender: UIButton) {
        //present end view controller
    }
    
    /// Determines if the tap gesture for presenting the `VirtualObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectLoader.loadedObjects.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        virtualObjectLoader.removeAllVirtualObjects()

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
            self.upperControlsView.isHidden = false
        }
    }
}
