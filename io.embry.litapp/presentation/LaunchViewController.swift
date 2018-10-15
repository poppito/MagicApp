//
//  LaunchViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 19/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit
import ARKit

class LaunchViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    //MARK - properties
    @IBOutlet weak var imagePickedImage: UIImageView!
    
    @IBOutlet weak var btnAnalyse: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var btnMagic: UIButton!
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMagic.alpha = 0.5
        btnAnalyse.alpha = 0.5
        btnMagic.isEnabled = false
        btnAnalyse.isEnabled = false
    }
    
    //MARK - actions
    
    @IBAction func didTapPickFromPhotosButton(_ sender: Any) {
        if (images.count < 10) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true)
        } else {
            lblStatus.text = "no need, you've already selected 10 images!"
        }
    }
    
    
    @IBAction func didTapTakeAPhotoButton(_ sender: Any) {
        if (images.count < 10) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            self.present(imagePicker, animated: true)
        } else {
            lblStatus.text = "no need, you've already selected 10 images!"
        }
    }
    

    
    //MARK - imagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imagePickedImage.image = pickedImage
        images.append(pickedImage)

        
        if (images.count > 0 && images.count < 5) {
            let count = images.count
            lblStatus.text = "\(count) images selected. Nice, please select at least \(5-count) more."
            btnMagic.alpha = 1.0
            btnMagic.isEnabled = true
            btnAnalyse.isEnabled = true
            btnAnalyse.alpha = 1.0
        } else if (images.count >= 5){
            lblStatus.text = "Good work. You can select up to 10 images or proceed to Magic!"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toScnView" ) {
            let refImages = addDynamicARImages(images: images)
            let destination = segue.destination as? MainViewController
            destination?.arReferenceImages = refImages
        }
    }
    
    private func addDynamicARImages(images: [UIImage]) -> [ARReferenceImage] {
        var arReferenceImages = [ARReferenceImage]()
        for image in images {
            guard let cgImage = image.cgImage else { return arReferenceImages }
            let arReferenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.2)
            arReferenceImages.append(arReferenceImage)
        }
        
        return arReferenceImages
    }
}
