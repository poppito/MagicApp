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
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            ARSessionDelegate {
    
    
    @IBOutlet weak var viewMainScene: ARSCNView!
    
    var visa1: UIImage!
    var visa2: UIImage!
    var visa3: UIImage!
    
    
    @IBOutlet weak var preview1: UIImageView!
    @IBOutlet weak var preview2: UIImageView!
    @IBOutlet weak var preview3: UIImageView!
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var btnPhoto: UIButton!
    
    var scnNode: SCNNode?
    var tapRecogniser: UITapGestureRecognizer!
    var currentFloat = Float(0)
    
    var handsModel: VNCoreMLModel!
    var currentBuffer: CVPixelBuffer!

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ARWorldTrackingConfiguration()
        config.isAutoFocusEnabled = true
        viewMainScene.autoenablesDefaultLighting = true
        viewMainScene.session.run(config, options: [])
        viewMainScene.preferredFramesPerSecond = 10
        viewMainScene.session.delegate = self
        handsModel = try? VNCoreMLModel(for: hands().model)
        let plane = SCNBox(width: 0.1, height: 0.05, length: 0.001, chamferRadius: 0.01)
        scnNode = SCNNode(geometry: plane)
        scnNode?.position = SCNVector3(0, 0, -0.2)
        visa1 = UIImage(named: "visa-1")
        visa2 = UIImage(named: "visa-2")
        visa3 = UIImage(named: "visa-3")
        scnNode?.geometry?.materials.first?.diffuse.contents = visa1
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
        let preview1Tap = UITapGestureRecognizer(target: self, action: #selector(didTapFirstPreview))
        let preview2Tap = UITapGestureRecognizer(target: self, action: #selector(didTapSecondPreview))
        let preview3Tap = UITapGestureRecognizer(target: self, action: #selector(didTapThirdPreview))
        
        preview1.addGestureRecognizer(preview1Tap)
        preview1.isUserInteractionEnabled = true
        preview2.addGestureRecognizer(preview2Tap)
        preview2.isUserInteractionEnabled = true
        preview3.addGestureRecognizer(preview3Tap)
        preview3.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        viewMainScene.session.pause()
    }
    
    @objc func didTapFirstPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials.first?.diffuse.contents = visa1
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    @objc func didTapSecondPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials.first?.diffuse.contents = visa2
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    @objc func didTapThirdPreview(_ sender: UITapGestureRecognizer) {
        scnNode?.removeFromParentNode()
        scnNode?.geometry?.materials.first?.diffuse.contents = visa3
        viewMainScene.scene.rootNode.addChildNode(scnNode!)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        currentFloat = currentFloat + Float(1)
        if (currentFloat == Float(360)) {
            currentFloat = 0
        }
        print("current float is \(currentFloat)")
        DispatchQueue.main.async { [weak self] in
            self?.rotateY(angle: self?.currentFloat ?? Float(0))
            //self?.runImageDetection()
        }
    }

    private func runImageDetection() {
        guard let model = handsModel else { return }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard error == nil, let results = request.results as? [VNClassificationObservation] else { return
            }
            guard let result = results.first else { return }
            DispatchQueue.main.async { [weak self] in
                if (result.confidence > 0.9) {
                    if (result.identifier  == "normal") {
                        //self?.rotateY(angle: self?.currentFloat ?? Float(0))
                        print("normal")
                    } else if (result.identifier == "up") {
                        //self?.rotateX(angle: self?.currentFloat ?? Float(0))
                        print("left")
                    } else if (result.identifier == "fist") {
                        //self?.rotateZ(angle: self?.currentFloat ?? Float(0))
                        print("up")
                    }
                }
                else {
                    //print("nothing")
                    //self?.scnNode?.removeFromParentNode()
                    //self?.scnNode?.position = SCNVector3(0, 0, 0)
                }
            }
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: self.currentBuffer, orientation: .up, options: [:])
        let queue = DispatchQueue(label: "classificationQueue")
        queue.async { [weak self] in
            defer { self?.currentBuffer = nil }
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
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
    
    
    @IBAction func didTapPhotoButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.dismiss(animated: true, completion: nil)
        imgPreview.image = pickedImage
        imgPreview.contentMode = .scaleAspectFill
        //runImageDetection(pickedImage: pickedImage.cgImage!)
    }
}
