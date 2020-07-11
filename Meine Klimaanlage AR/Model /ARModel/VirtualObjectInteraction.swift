
import UIKit
import ARKit

/// - Tag: VirtualObjectInteraction
class VirtualObjectInteraction: NSObject, UIGestureRecognizerDelegate {
    
    /// Developer setting to translate assuming the detected plane extends infinitely.
    let translateAssumingInfinitePlane = true
    
    /// The scene view to hit test against when moving virtual content.
    let sceneView: VirtualObjectARView
    
    /// A reference to the view controller.
    let viewController: ARViewController
    
    /**
     The object that has been most recently intereacted with.
     The `selectedObject` can be moved at any time with the tap gesture.
     */
    var selectedObject: VirtualObject?
    
    /// The object that is tracked for use by the pan and rotation gestures.
    var trackedObject: VirtualObject? {
        didSet {
            guard trackedObject != nil else { return }
            selectedObject = trackedObject
        }
    }
    
    /// The tracked screen position used to update the `trackedObject`'s position.
    private var currentTrackingPosition: CGPoint?
    
    init(sceneView: VirtualObjectARView, viewController: ARViewController) {
        self.sceneView = sceneView
        self.viewController = viewController
        super.init()
        
        createPanGestureRecognizer(sceneView)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationGesture.delegate = self
        sceneView.addGestureRecognizer(rotationGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    // - Tag: CreatePanGesture
    func createPanGestureRecognizer(_ sceneView: VirtualObjectARView) {
        let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        sceneView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Gesture Actions
    
    @objc
    func didPan(_ gesture: ThresholdPanGesture) {
        switch gesture.state {
        case .began:
            // Check for an object at the touch location.
            if let object = objectInteracting(with: gesture, in: sceneView) {
                trackedObject = object
            }
            
        case .changed where gesture.isThresholdExceeded:
            guard let object = trackedObject else { return }
            // Move an object if the displacment threshold has been met.
            translate(object, basedOn: updatedTrackingPosition(for: object, from: gesture))

            gesture.setTranslation(.zero, in: sceneView)
            
        case .changed:
            // Ignore the pan gesture until the displacment threshold is exceeded.
            break
            
        case .ended:
            // Update the object's position when the user stops panning.
            guard let object = trackedObject else { break }
            setDown(object, basedOn: updatedTrackingPosition(for: object, from: gesture))
            
            fallthrough
            
        default:
            // Reset the current position tracking.
            currentTrackingPosition = nil
            trackedObject = nil
        }
    }
    
    func updatedTrackingPosition(for object: VirtualObject, from gesture: UIPanGestureRecognizer) -> CGPoint {
        let translation = gesture.translation(in: sceneView)
        
        let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
        let updatedPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
        currentTrackingPosition = updatedPosition
        return updatedPosition
    }

    /**
     For looking down on the object (99% of all use cases), you subtract the angle.
     To make rotation also work correctly when looking from below the object one would have to
     flip the sign of the angle depending on whether the object is above or below the camera.
     - Tag: didRotate */
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        
        trackedObject?.objectRotation -= Float(gesture.rotation)
        
        gesture.rotation = 0
    }
    
    
    
    /// Handles the interaction when the user taps the screen.
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        guard viewController.userIsAddingWire else { return }
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlane)
        
        guard let hitTest = hitTestResults.first else {
            return
        }
        
        addMarker(hitTestResult: hitTest)
        
    
        let mostRecentPoints = Array(viewController.wirePoints.suffix(2))
        
        if mostRecentPoints.count == 2,
            let firstPoint = mostRecentPoints.first,
            let lastPoint = mostRecentPoints.last {
            addLineBetween(start: firstPoint, end: lastPoint)
            addDistanceText(distance: SCNVector3.distanceFrom(vector: firstPoint, toVector: lastPoint), at: lastPoint)
        } else {
            viewController.instructionsLabel.text = "Tap where  you would like the wire to end."
        }
    }
    
   
    func addMarker(hitTestResult: ARHitTestResult) {
        let geometry = SCNSphere(radius: 0.01)
        geometry.firstMaterial?.diffuse.contents = UIColor(named: "PrimaryBlue")
        let markerNode = SCNNode(geometry: geometry)

        let vectorPoint = SCNVector3(
            hitTestResult.worldTransform.columns.3.x,
            hitTestResult.worldTransform.columns.3.y,
            hitTestResult.worldTransform.columns.3.z
        )
        
        viewController.wirePoints.append(vectorPoint)
        
        
        markerNode.position = vectorPoint

        sceneView.scene.rootNode.addChildNode(markerNode)
    }
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) {
        let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
        let lineNode = SCNNode(geometry: lineGeometry)

        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func addDistanceText(distance: Float, at point: SCNVector3) {
        let textGeometry = SCNText(string: "\(distance) meters", extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 10)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black

        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3Make(point.x, point.y + 0.5, point.z);
        textNode.scale = SCNVector3Make(0.005, 0.005, 0.005)

        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow objects to be translated and rotated at the same time.
        return true
    }

    /** A helper method to return the first object that is found under the provided `gesture`s touch locations.
     Performs hit tests using the touch locations provided by gesture recognizers. By hit testing against the bounding
     boxes of the virtual objects, this function makes it more likely that a user touch will affect the object even if the
     touch location isn't on a point where the object has visible content. By performing multiple hit tests for multitouch
     gestures, the method makes it more likely that the user touch affects the intended object.
      - Tag: TouchTesting
    */
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> VirtualObject? {
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)
            
            // Look for an object directly under the `touchLocation`.
            if let object = sceneView.virtualObject(at: touchLocation) {
                return object
            }
        }
        
        // As a last resort look for an object under the center of the touches.
        if let center = gesture.center(in: view) {
            return sceneView.virtualObject(at: center)
        }
        
        return nil
    }
    
    // MARK: - Update object position
    /// - Tag: DragVirtualObject
    func translate(_ object: VirtualObject, basedOn screenPos: CGPoint) {
        object.stopTrackedRaycast()
        
        // Update the object by using a one-time position request.
        if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.allowedAlignment) {
            viewController.createRaycastAndUpdate3DPosition(of: object, from: query)
        }
    }
    
    func setDown(_ object: VirtualObject, basedOn screenPos: CGPoint) {
        object.stopTrackedRaycast()
        
        // Prepare to update the object's anchor to the current location.
        object.shouldUpdateAnchor = true
        
        // Attempt to create a new tracked raycast from the current location.
        if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.allowedAlignment),
            let raycast = viewController.createTrackedRaycastAndSet3DPosition(of: object, from: query) {
            object.raycast = raycast
        } else {
            // If the tracked raycast did not succeed, simply update the anchor to the object's current position.
            object.shouldUpdateAnchor = false
            viewController.updateQueue.async {
                self.sceneView.addOrUpdateAnchor(for: object)
            }
        }
    }
}

/// Extends `UIGestureRecognizer` to provide the center point resulting from multiple touches.
extension UIGestureRecognizer {
    func center(in view: UIView) -> CGPoint? {
        guard numberOfTouches > 0 else { return nil }
        
        let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)

        let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
            return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
        }

        return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
    }
}
