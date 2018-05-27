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

class ARViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var viewMainScene: ARSKView!
    
    @IBOutlet weak var lblStatusText: UILabel!
        
    var currentBuffer: CVPixelBuffer?
    
    var inceptionModel: VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overlayScene = SKScene()
        overlayScene.scaleMode = .aspectFill
        viewMainScene.presentScene(overlayScene)
        
        let config = ARWorldTrackingConfiguration()
        viewMainScene.session.run(config, options: [])
        
        viewMainScene.session.delegate = self
    
        inceptionModel = try? VNCoreMLModel(for: Inceptionv3().model)
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
        runImageClassification()
    }
    
    
    func runImageClassification() {
        if (inceptionModel != nil) {
            let inceptionRequest = VNCoreMLRequest(model: inceptionModel!) { [weak self] request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("unexpected result type from VNCoreMLRequest")
                }
                if let result = results.first {
                    if (result.confidence > 0.3) {
                        DispatchQueue.main.async { [weak self] in
                            self?.lblStatusText.text = results.first?.identifier
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
    
    @IBAction func didTapScn(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: viewMainScene)
            let hitTest = viewMainScene.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane])
            let result = hitTest.first
    }
}
