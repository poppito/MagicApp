//
//  ARRunViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 27/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import ARKit
import Vision

class ARRunViewController:  UIViewController,
                            ARSessionDelegate {
    
    @IBOutlet weak var viewMainScene: ARSCNView!
    @IBOutlet weak var preview1: UIImageView!
    @IBOutlet weak var preview2: UIImageView!
    @IBOutlet weak var preview3: UIImageView!
    
    private var scnNode: SCNNode?
    private var currentFloat = Float(0)
    private var card = SCNBox()
    private var visa1 = SCNMaterial()
    private var visa2 = SCNMaterial()
    private var visa3 = SCNMaterial()
    private var back = SCNMaterial()
    private var action: SCNAction!
    private var repeatAction: SCNAction!
    private var black = SCNMaterial()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //arconfig
        let config = ARWorldTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = true
        
        //scn
        viewMainScene.autoenablesDefaultLighting = true
        viewMainScene.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        viewMainScene.session.delegate = self
        
        //nodes
        card = SCNBox(width: 0.1, height: 0.05, length: 0.001, chamferRadius: 0.01)
        let visa1Img = UIImage(named: "visa-1")
        let visa2Img = UIImage(named: "visa-2")
        let visa3Img = UIImage(named: "visa-3")
        let backImg = UIImage(named: "card-back")
        visa1.diffuse.contents = visa1Img
        visa2.diffuse.contents = visa2Img
        visa3.diffuse.contents = visa3Img
        back.diffuse.contents = backImg
        black.diffuse.contents = UIColor.black
        let preview1Tap = UITapGestureRecognizer(target: self, action: #selector(didTapFirstPreview))
        let preview2Tap = UITapGestureRecognizer(target: self, action: #selector(didTapSecondPreview))
        let preview3Tap = UITapGestureRecognizer(target: self, action: #selector(didTapThirdPreview))
        //let planeTapRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapPlane))
        action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 3.0)
        repeatAction = SCNAction.repeat(action, count: 1)
        scnNode?.runAction(repeatAction)
        preview1.addGestureRecognizer(preview1Tap)
        preview1.isUserInteractionEnabled = true
        preview2.addGestureRecognizer(preview2Tap)
        preview2.isUserInteractionEnabled = true
        preview3.addGestureRecognizer(preview3Tap)
        preview3.isUserInteractionEnabled = true
        
        //viewMainScene.addGestureRecognizer(planeTapRecogniser)
        scnNode = SCNNode(geometry: card)
        scnNode?.geometry?.materials = [visa1, black, back, black, black, black]
        scnNode?.runAction(repeatAction)
        scnNode?.position = SCNVector3(0, 0, -0.1)
        viewMainScene.allowsCameraControl = true
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        viewMainScene.session.pause()
    }
    
    @objc func didTapFirstPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials = [visa1, black, back, black, black, black]
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    @objc func didTapSecondPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials = [visa2, black, back, black, black, black]
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    @objc func didTapThirdPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials = [visa3, black, back, black, black, black]
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    private func rotateY(angle: Float) {
        //scnNode?.removeFromParentNode()
        scnNode?.eulerAngles = SCNVector3(0, angle, 0)
        //if (scnNode != nil) {
        //    viewMainScene.scene.rootNode.addChildNode(scnNode!)
        //}
    }
    
    private func rotateX(angle: Float) {
        scnNode?.removeFromParentNode()
        scnNode?.eulerAngles = SCNVector3(angle, 0, 0)
        if (scnNode != nil) {
            viewMainScene.scene.rootNode.addChildNode(scnNode!)
        }
    }
    
    private func rotateZ(angle: Float) {
        scnNode?.removeFromParentNode()
        scnNode?.eulerAngles = SCNVector3(0, 0, angle)
        if (scnNode != nil) {
            viewMainScene.scene.rootNode.addChildNode(scnNode!)
        }
    }
    
    @objc func didTapPlane(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: viewMainScene)
        let hitTestResults = viewMainScene.hitTest(location, types: [.estimatedHorizontalPlane])
        
        guard let result = hitTestResults.first else {
            return
        }
       
        scnNode?.removeFromParentNode()
        scnNode = SCNNode(geometry: card)
        scnNode?.geometry?.materials = [visa1, black, back, black, black, black]
        scnNode?.runAction(repeatAction)
        scnNode?.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
