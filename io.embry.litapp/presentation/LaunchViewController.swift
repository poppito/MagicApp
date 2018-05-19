//
//  LaunchViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 19/5/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    //MARK - properties
    @IBOutlet weak var imagePickedImage: UIImageView!
    
    @IBOutlet weak var btnMagic: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMagic.alpha = 0.5
        btnMagic.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK - actions
    
    @IBAction func didTapPickFromPhotosButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    
    @IBAction func didTapTakeAPhotoButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true)
    }
    
    
    @IBAction func didTapMagicButton(_ sender: Any) {
    }
    
    
//MARK - imagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imagePickedImage.image = pickedImage
        
        btnMagic.alpha = 1.0
        btnMagic.isEnabled = true
        
        dismiss(animated: true, completion: nil)
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
