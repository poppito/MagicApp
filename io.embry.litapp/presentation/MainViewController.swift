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
import SceneKit.ModelIO
import Dispatch

class MainViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var viewMainScene: ARSCNView!
    var arReferenceImages = [ARReferenceImage]()

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
        
        viewMainScene.delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.main.async {
    
        let x = CGFloat(referenceImage.physicalSize.width/2)
        let y = CGFloat(referenceImage.physicalSize.height/2)
        let box = self.addMainBox()
        box.position = SCNVector3(x,y,-0.5)
        node.addChildNode(box)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.main.async {
            let x = CGFloat(referenceImage.physicalSize.width/2)
            let y = CGFloat(referenceImage.physicalSize.height/2)
            
            let box = self.addMainBox()
            box.position = SCNVector3(x,y,-0.5)
            node.addChildNode(box)
        }
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
        
        let node2 = getTextNode()
        node2.position = SCNVector3(x, y+1.0, z-1.5)
        viewMainScene.scene.rootNode.addChildNode(node2)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewMainScene.session.pause()
    }
    
    private func getTextNode() -> SCNNode {
        let text = SCNText(string: "OMG HARSH IS AWESOME", extrusionDepth: 1.5)
        let textNode = SCNNode(geometry: text)
        textNode.name = "text"
        return textNode
    }
    
    /*private func addLaptop() -> SCNNode? {
        guard let url = Bundle.main.url(forResource: "Laptop", withExtension: "obj") else { return nil }
        let asset = MDLAsset(url: url)
        let object = asset.object(at: 0)
        let node = SCNNode(mdlObject: object)
        return node
    }*/
    
    /*
    private func addLaptop() -> SCNNode? {
        let laptopScene = SCNScene(named: "Laptop.scn")
        guard let laptopNode = laptopScene?.rootNode.childNode(withName: "laptopNode", recursively: false) else { return nil }
        laptopNode.geometry?.firstMaterial?.diffuse.contents = "bg.png"
        return laptopNode
    } */
    
    private func addText() -> SCNNode? {
        let textScn = SCNScene(named: "SimpleSCN.scn")
        guard let textNode = textScn?.rootNode.childNode(withName: "harshisawesome" , recursively: false) else { return nil }
        textNode.geometry?.firstMaterial?.diffuse.contents = "bg.png"
        textNode.eulerAngles.z = 45
        return textNode
    }
    
    private func addMainBox() -> SCNNode {
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.3)
        let mainNode = SCNNode(geometry: box)
        return mainNode
    }
}

