//
//  ViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 15/4/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Dispatch
import CoreML
import Vision

class MainViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var viewMainScene: ARSCNView!
    var arReferenceImages = [ARReferenceImage]()

    @IBOutlet weak var lblStatusText: UILabel!
        
    var detectionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ARWorldTrackingConfiguration()
    
        //guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
           // fatalError("Missing expected asset catalog resources.")
        if (arReferenceImages.count > 0) {
            let referenceImages = Set(arReferenceImages.map {$0} )
            config.detectionImages = referenceImages
            viewMainScene.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        }
        
        viewMainScene.delegate = self    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.main.async {
            
            self.detectionCount = self.detectionCount + 1
            self.lblStatusText.text = "Anchor detected \(self.detectionCount) times"
            
            let x = CGFloat(referenceImage.physicalSize.width/2)
            let y = CGFloat(referenceImage.physicalSize.height/2)
            
            let box = self.addMainBox()
            box.position = SCNVector3(x,y,-0.2)
            if (self.detectionCount == 0) {
            } else {
                //node.replaceChildNode(box, with: box)
            }
            node.addChildNode(box)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewMainScene.session.pause()
    }
    
    private func addMainBox() -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1)
        let mainNode = SCNNode(geometry: box)
        return mainNode
    }
}

//unused


/*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
 guard let imageAnchor = anchor as? ARImageAnchor else { return }
 let referenceImage = imageAnchor.referenceImage
 DispatchQueue.main.async {
 
 self.detectionCount = self.detectionCount + 1
 self.lblStatusText.text = "Anchor detected \(self.detectionCount) times"
 let x = CGFloat(referenceImage.physicalSize.width/2)
 let y = CGFloat(referenceImage.physicalSize.height/2)
 let box = self.addMainBox()
 box.position = SCNVector3(x,y,-0.1)
 node.replaceChildNode(box, with: box)
 }
 }*/


/*
 private func addLaptop() -> SCNNode? {
 guard let url = Bundle.main.url(forResource: "Laptop", withExtension: "obj") else { return nil }
 let asset = MDLAsset(url: url)
 let object = asset.object(at: 0)
 let node = SCNNode(mdlObject: object)
 return node
 }
 
 
 private func addLaptop() -> SCNNode? {
 let laptopScene = SCNScene(named: "Laptop.scn")
 guard let laptopNode = laptopScene?.rootNode.childNode(withName: "laptopNode", recursively: false) else { return nil }
 laptopNode.geometry?.firstMaterial?.diffuse.contents = "bg.png"
 return laptopNode
 }
 
 private func addText() -> SCNNode? {
 let textScn = SCNScene(named: "SimpleSCN.scn")
 guard let textNode = textScn?.rootNode.childNode(withName: "harshisawesome" , recursively: false) else { return nil }
 textNode.geometry?.firstMaterial?.diffuse.contents = "bg.png"
 textNode.eulerAngles.z = 45
 return textNode
 }


func addGestureRecognizerToSceneView() {
    //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addObjectToSceneView(sender:)))
    //viewMainScene.addGestureRecognizer(tapGestureRecognizer)
}

@objc func addObjectToSceneView(sender recognizer: UIGestureRecognizer) {
    let tapLocation = recognizer.location(in: viewMainScene)
    let hitTestResults = viewMainScene.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    guard let hitTestResult = hitTestResults.first else { return }
    let translation = hitTestResult.worldTransform.columns.3
    print("detected")
    let x = translation.x
    let y = translation.y
    let z = translation.z
} */
