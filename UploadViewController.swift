//  UploadViewController.swift
//  Upload to AWSS3 Bucket
//  Created by TIEGO Ouedraogo on 6/22/22.

import UIKit
import AWSS3
import AVFoundation

internal final class UploadViewController: UIViewController, UINavigationControllerDelegate {
    
    var delegate : AppDelegate! //implicitly unwrapped optional variable set to nil when class is initialized
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func myMethod() {
        delegate = (UIApplication.shared.delegate as! AppDelegate)
    }
//
//var progressView: UIProgressView!
//var statusLabel: UILabel!
var selectedImageView: UIImageView
//
//var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
//var progressBlock: AWSS3TransferUtilityProgressBlock?
//
    @objc let imagePicker = UIImagePickerController()
//
//    @objc lazy var transferUtility = {
//        AWSS3TransferUtility.default()
//    }()
//    let bucketName = "uploaders3aws"
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
//    func selectAndUpload(_ sender: UIButton) {
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
//
//        present(imagePicker, animated: true, completion: nil)
//    }
    

//    func uploadImage(with data: Data) {
//        let expression = AWSS3TransferUtilityUploadExpression()
//        expression.progressBlock = progressBlock
//
//        DispatchQueue.main.async(execute: {
//            self.statusLabel.text = ""
//            self.progressView.progress = 0
//        })
//
//        transferUtility.uploadData(
//            data,
//            key: S3UploadKeyName,
//            contentType: "image/png",
//            expression: expression,
//            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
//                if let error = task.error {
//                    print("Error: \(error.localizedDescription)")
//
//                    DispatchQueue.main.async {
//                        self.statusLabel.text = "Failed"
//                    }
//                }
//
//                if let _ = task.result {
//
//                    DispatchQueue.main.async {
//                        self.statusLabel.text = "Uploading..."
//                        print("Upload Starting!")
//                    }
//
//                    // Do something with uploadTask.
//                }
//
//                return nil;
//        }
//    }
}

extension UploadViewController: UIImagePickerControllerDelegate {
public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
    selectedImageView.image = pickedImage
        

        }


        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
