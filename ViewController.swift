//
//  ViewController.swift
//  Upload to AWSS3 Bucket
//
//  Created by TIEGO Ouedraogo on 6/22/22.
//

import UIKit
import AWSS3
import Photos

@available(iOS 13, *)
class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()
    
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!

    @objc var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    @objc var progressBlock: AWSS3TransferUtilityProgressBlock?

    @objc let imagePicker = UIImagePickerController()


    let bucketName = "uploaders3aws"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.progressView.progress = 0.0;
        self.statusLabel.text = "Ready"
        self.imagePicker.delegate = self

        self.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                if (self.progressView.progress < Float(progress.fractionCompleted)) {
                    self.progressView.progress = Float(progress.fractionCompleted)
                }
            })
        }

        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("Failed with error: \(error)")
                    self.statusLabel.text = "Failed"
                }
                else if(self.progressView.progress != 1.0) {
                    self.statusLabel.text = "Failed"
                    NSLog("Error: Failed - Likely due to invalid region / filename")
                }
                else{
                    self.statusLabel.text = "Success"
                }
            })
    
        }
    }
    @IBAction func suspendButton(_ sender: Any) {
        suspendAll()
    }

    @IBAction func resume(_ sender: Any) {
            resumeAll()

    }

    
    @IBAction func selectImage(_ sender: Any) {

    selectImageFromGallery()


    }
    
    func selectImageFromGallery() {

    let imagePicker = UIImagePickerController()

    imagePicker.delegate = self

    imagePicker.allowsEditing = false

    imagePicker.sourceType = .photoLibrary

    present(imagePicker, animated: true, completion: nil)

    }
    @IBAction func Upload(_ sender: UIButton) {
        DispatchQueue.global().async { [self] in
        fetchItems { print("done") }
        }
    }

    @objc func suspendAll() {
        DispatchQueue.global().async { [self] in

            print("suspendAll: start")
            let uploadTasks = transferUtility.getMultiPartUploadTasks().result
            for uploadTask in uploadTasks! {
                let task = uploadTask as! AWSS3TransferUtilityMultiPartUploadTask

                task.suspend()
                print("suspendAll: task.transferID:\(task.transferID) \(task.status)")
            }
        }

    }
    @objc func resumeAll() {
        DispatchQueue.global().async { [self] in
        let uploadTasks = transferUtility.getMultiPartUploadTasks().result
        for uploadTask in uploadTasks! {
            let task = uploadTask as! AWSS3TransferUtilityMultiPartUploadTask

            task.resume()
            print("resumeAll: task.transferID:\(task.transferID) \(task.status)")
        }
        }
    }

    @objc func fetchItems(complete: @escaping () -> Void) {
        //Setup Log level
        AWSDDLog.sharedInstance.logLevel = .debug
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        var hasNextPage = false
        var beginIndex = 0
        let page = 100
        let assetFetchOptions = PHFetchOptions()
        let collectionType: PHAssetCollectionType = .smartAlbum
        let collectionSubtype: PHAssetCollectionSubtype = .smartAlbumUserLibrary
        let collectionFetchOptions = PHFetchOptions()
        collectionFetchOptions.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]

        let assetCollectionFetchResult = PHAssetCollection.fetchAssetCollections(with: collectionType, subtype: collectionSubtype, options: collectionFetchOptions) as PHFetchResult<PHAssetCollection>

        assetCollectionFetchResult.enumerateObjects {
            [weak self] assetCollection, collectionIdx, stopCollections in

            guard let self = self else { return }


            // Enumerate assets within the collection
            let assetsFetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: assetCollection, options: assetFetchOptions)
            hasNextPage = beginIndex < assetsFetchResult.count
            repeat {
                if hasNextPage {
                    var endIndex = beginIndex + (page - 1)
                    if endIndex >= assetsFetchResult.count {
                        endIndex = assetsFetchResult.count - 1
                    }
                    let arr = Array(beginIndex...endIndex)

                    let indexSet = IndexSet(arr)

                    assetsFetchResult.enumerateObjects(at: indexSet, options: NSEnumerationOptions.concurrent, using: {
                        (asset, count, stop) in
                        self.uploadImage(with: asset)


                    })
                    if endIndex == indexSet.last! {
                        beginIndex = endIndex + 1
                        hasNextPage = beginIndex < assetsFetchResult.count
                    }

                }
            } while(hasNextPage)
            complete()
        }

    }
    
    @objc func uploadImage(with asset: PHAsset) {
        var originalName: String = ""
        if let resource = PHAssetResource.assetResources(for: asset).first {
            originalName = resource.originalFilename //Original name
        }

        var progressView: Float = 0.0
        let completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock?

        let progressBlock: AWSS3TransferUtilityMultiPartProgressBlock?

        progressBlock = { (task, progress) in
            DispatchQueue.global().async {
                if (progressView < Float(progress.fractionCompleted)) {
                    progressView = Float(progress.fractionCompleted)
                    print("\(originalName): \(progressView)")
                }
            }
        }

        completionHandler = { (task, error) -> Void in
            DispatchQueue.global().async {
                if let error = error {
                    print("\(originalName) Failed with error: \(error)")
                }
                else if(progressView != 1.0) {
                    print("\(originalName) Error: Failed - Likely due to invalid region / filename")
                }
                else {
                    print("\(originalName) Success")
                }
            }
        }

        let expression = AWSS3TransferUtilityMultiPartUploadExpression()

        expression.progressBlock = progressBlock!
        transferUtility.uploadUsingMultiPart(data: asset.syncReadData()!,
            bucket: bucketName,
            key: "TEST/1 test/" + originalName,
            contentType: "image/png",
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                DispatchQueue.global().async {
                if let error = task.error {
                    print("\(originalName) Error: \(error.localizedDescription)")
                }

                if let _ = task.result {
                    print("\(originalName) Upload Starting!")

                    // Do something with uploadTask.
                }
            }
            return nil;
        }
    }
}



@available(iOS 13, *)
extension PHAsset {
    func syncReadData() -> Data? {

        var rData: Data?
        let semaphore = DispatchSemaphore(value: 0)
        let manager = PHImageManager.default()
        switch self.mediaType {
        case .image:
            let options = PHImageRequestOptions()
            options.version = .original
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            manager.requestImageDataAndOrientation(for: self, options: options) {
                assetData, uti, orientation, info in

                rData = assetData
                semaphore.signal()
            }

        case .video:
            let options = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            manager.requestAVAsset(forVideo: self, options: options) {
                assetData, _, _ in
                let asset = assetData as? AVURLAsset
                let data = try! Data(contentsOf: asset!.url)
                rData = data
                semaphore.signal()
            }
        case .unknown:
            semaphore.signal()

        default:
            semaphore.signal()

        }
        semaphore.wait()
        return rData
    }

}
    
