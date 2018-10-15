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

    
    @IBOutlet weak var btnObjectDetection: UIButton!
    @IBOutlet weak var viewMainScene: ARSKView!
    @IBOutlet weak var lblStatusText: UILabel!
    
    
    var currentBuffer: CVPixelBuffer?
    
    var inceptionModel: VNCoreMLModel?
    
    var dugModel : VNCoreMLModel?
    
    var lblTap: UILabel!
    
    var isObjectDetectionOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overlayScene = SKScene()
        overlayScene.scaleMode = .aspectFill
        viewMainScene.presentScene(overlayScene)
        
        let config = AROrientationTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.isLightEstimationEnabled = true
        viewMainScene.session.run(config, options: [])
        
        viewMainScene.session.delegate = self
        
        lblTap = UILabel(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        lblTap.textColor = UIColor.white
        lblTap.font = UIFont(name: "Helvetica", size: 24)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        viewMainScene.addGestureRecognizer(tap)
        viewMainScene.addSubview(lblTap)
    
        //inceptionModel = try? VNCoreMLModel(for: DetectDug().model)
        inceptionModel = try? VNCoreMLModel(for: ImageClassifier().model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        viewMainScene.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        runObjectDetection()
    }
    
    
    func runObjectDetection() {
        if (inceptionModel != nil) {
            let inceptionRequest = VNCoreMLRequest(model: inceptionModel!) { [weak self] request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("unexpected result type from VNCoreMLRequest")
                }
                if let result = results.first {
                    if (result.confidence > 0.890) {
                        DispatchQueue.main.async { [weak self] in
                            //self?.lblStatusText.text = results.first?.identifier
                            print("\(result) for detected")
                            if (result.identifier == "Dug") {
                             self?.lblStatusText.text = "I spotted a Dug 🐶!"
                            } else if (result.identifier == "Pop") {
                                self?.lblStatusText.text = "Is that you Poppito? 🐦"
                            }
                            else if (result.identifier == "Carpet") {
                            self?.lblStatusText.text = "That's just carpet"
                            }
                            else if (result.identifier == "macbooks") {
                                self?.lblStatusText.text = "Macbook detected"
                            } else if (result.identifier == "buy buttons") {
                                self?.lblStatusText.text = "What are we buying today?"
                            }
                            else {
                                self?.lblStatusText.text = "No Dug in sight. I miss Dug! 😥"
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            print("\(result) for undetected")
                            self?.lblStatusText.text = "No Dug in sight. I miss Dug! 😥"
                        }
                    }
                }
            }
            
            let inceptionRequestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: CGImagePropertyOrientation.up)
            
            let classificationQueue = DispatchQueue(label: "classificationQueue")
            
            classificationQueue.async { [weak self] in
                do {
                    defer {self?.currentBuffer = nil}
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
    
    @IBAction func didTapToggleButton(_ sender: Any) {
        if (isObjectDetectionOn == true) {
            //btnObjectDetection.setTitle("Text detection", for: .normal)
            //isObjectDetectionOn = false
        } else {
            btnObjectDetection.setTitle("Object detection", for: .normal)
            isObjectDetectionOn = true
        }
    }
}
