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
        #warning("this shouldn't be called when user simply taps on the screen")
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard addObjectButton.isEnabled && !virtualObjectLoader.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        
        if let filePath = Bundle.main.path(forResource: ACUNit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") {
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
