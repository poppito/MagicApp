//
//  ARViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 22/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import Vision
import ARKit
import CoreML
import SpriteKit

class MLViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var viewMainScene: ARSCNView!
    @IBOutlet weak var lblStatusText: UILabel!
    @IBOutlet weak var btnClassify: UIButton!
    
    private var lblTap: UILabel!
    
    private var analysisRequests = [VNRequest]()
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    private var currentBuffer: CVPixelBuffer?
    private var inceptionModel: VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isAutoFocusEnabled = true
        config.isLightEstimationEnabled = true
        viewMainScene.session.run(config, options: [])
        viewMainScene.session.delegate = self
        inceptionModel = try? VNCoreMLModel(for: finModel2().model)
        btnClassify.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        viewMainScene.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard case .normal = frame.camera.trackingState else {
            return
        }
        
        let pixelBuffer = frame.capturedImage
        currentBuffer = pixelBuffer
        if (self.previousPixelBuffer == nil) {
            self.previousPixelBuffer = pixelBuffer
            self.transpositionHistoryPoints.removeAll()
            return
        }
        
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
        do {
            try sequenceRequestHandler.perform([registrationRequest], on: previousPixelBuffer!)
        } catch let error as NSError {
            print("Failed to process request: \(error.localizedDescription).")
            return
        }
        
        previousPixelBuffer = pixelBuffer
        
        if let results = registrationRequest.results {
            if let alignmentObservation = results.first as? VNImageTranslationAlignmentObservation {
                let alignmentTransform = alignmentObservation.alignmentTransform
                self.recordTransposition(CGPoint(x: alignmentTransform.tx, y: alignmentTransform.ty))
            }
        }
        
        if (self.sceneStabilityAchieved()) {
            if (self.currentBuffer == nil) {
                self.currentBuffer = pixelBuffer
            }
            DispatchQueue.main.async {[weak self] in
                self?.btnClassify.isEnabled = true
            }
        } else {
            DispatchQueue.main.async {[weak self] in
                self?.btnClassify.isEnabled = false
            }
        }
    }
    
    fileprivate func recordTransposition(_ point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }
    
    fileprivate func sceneStabilityAchieved() -> Bool {
        // Determine if we have enough evidence of stability.
        if transpositionHistoryPoints.count == maximumHistoryLength {
            // Calculate the moving average.
            var movingAverage: CGPoint = CGPoint.zero
            for currentPoint in transpositionHistoryPoints {
                movingAverage.x += currentPoint.x
                movingAverage.y += currentPoint.y
            }
            let distance = abs(movingAverage.x) + abs(movingAverage.y)
            print("distance is \(distance)")
            if distance < 50 {
                return true
            }
        }
        return false
    }
    
    func runImageClassification() {
        if (inceptionModel != nil) {
            let inceptionRequest = VNCoreMLRequest(model: inceptionModel!) { [weak self] request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("unexpected result type from VNCoreMLRequest")
                }
                if let result = results.first {
                    if (result.confidence > 0.99) {
                        DispatchQueue.main.async { [weak self] in
                            if (result.identifier == "buy buttons") {
                                self?.lblStatusText.text = "What are we buying today?"
                            } else if (result.identifier == "bpay") {
                                self?.lblStatusText.text = "Bills suck 😩!"
                            }
                            else {
                                self?.lblStatusText.text = "Looking around..."
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            print("\(result) for undetected")
                            self?.lblStatusText.text = "Looking around..."
                        }
                    }
                }
            }
            
            inceptionRequest.imageCropAndScaleOption = .centerCrop
            
            let inceptionRequestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: CGImagePropertyOrientation.up)
            
            let classificationQueue = DispatchQueue(label: "classificationQueue")
            
            classificationQueue.async { [weak self] in
                do {
                    defer {
                        self?.currentBuffer = nil
                    }
                    try inceptionRequestHandler.perform([inceptionRequest])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK:- actions
    @objc private func didTapView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: viewMainScene)
        lblTap.center = location
    }
    
    
    @IBAction func didTapClassify(_ sender: Any) {
        runImageClassification()
    }
    
    func getTwoButtonAlert(yesButton: UIAlertAction,
                           noButton: UIAlertAction,
                           title: String,
                           body: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(yesButton)
        alert.addAction(noButton)
        return alert
    }
}
