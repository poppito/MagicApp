//
//  ARRunViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 27/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import ARKit

class ARRunViewController: UIViewController, ARSKViewDelegate {
    
    
    @IBOutlet weak var lblStatusView: UILabel!
    
    
    @IBOutlet weak var viewMainScene: ARSKView!
    
    private var planeDetectionHorizontal = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewMainScene.delegate = self
        let skScene = SKScene()
        skScene.scaleMode = .aspectFill
        viewMainScene.presentScene(skScene)
        
        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = true
        config.planeDetection = .horizontal
        viewMainScene.session.run(config, options: .removeExistingAnchors)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func onBtnTapped(_ sender: Any) {
    
        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = true
        
        planeDetectionHorizontal = !planeDetectionHorizontal
        if (planeDetectionHorizontal) {
            config.planeDetection = .horizontal
            lblStatusView.text = "Detecting horizontal surfaces"
        } else {
            config.planeDetection = .vertical
            lblStatusView.text = "Detecting vertical surfaces"
        }
        viewMainScene.session.run(config, options: .removeExistingAnchors)
    }
    
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let path = Bundle.main.path(forResource: "MyScene", ofType: "sks")
        let fileURL = URL(fileURLWithPath: path!)
        
        let planeNode = SKReferenceNode(url: fileURL)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        
        planeNode.position = CGPoint(x: x, y: y)
        
        node.addChild(planeNode)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
