//
//  AnalyserViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 20/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import Vision
import CoreML

class AnalyserViewController: UIViewController {
    
    var selectedImage = UIImage()
    
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var lblAnalyserTextMobileNet: UILabel!
    
    @IBOutlet weak var lblAnalyserTextGoogleNetPlaces: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedImageView.image = selectedImage
        
        guard let mobileNetModel = try? VNCoreMLModel(for: MobileNet().model),
            let googleNetPlacesModel = try? VNCoreMLModel(for: GoogLeNetPlaces().model)
            else {
                fatalError("Something went wrong with an ML model")
        }
        
        let mobileNetRequest = VNCoreMLRequest(model: mobileNetModel) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("unexpected result type from VNCoreMLRequest")
            }
            DispatchQueue.main.async(execute: {
                self?.lblAnalyserTextMobileNet.text = "\(results[0].identifier) with confidence \(results[0].confidence * 100) for mobileNet"
            })
        }
        
        guard let img = selectedImage.cgImage else { return }
        
        let mobileNetHandler = VNImageRequestHandler(cgImage: img)
        
        let googleNetRequest = VNCoreMLRequest(model: googleNetPlacesModel) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("unexpected result type")
            }
            DispatchQueue.main.async {
                self?.lblAnalyserTextGoogleNetPlaces.text = "\(results[0].identifier) with confidence \(results[0].confidence * 100) for GoogleNetPlaces"
            }
        }
        
        let googleNetPlacesHandler = VNImageRequestHandler(cgImage: img)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try mobileNetHandler.perform([mobileNetRequest])
                try googleNetPlacesHandler.perform([googleNetRequest])
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
