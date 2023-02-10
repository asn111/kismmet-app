//
//  ImagePicker.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday19/06/2021.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class ImagePicker {
    
    var vc : UIViewController!

    var isForBussiness = false
    
    init(viewController: UIViewController) {
        vc = viewController
    }
    
    func handleTap() {
        
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        if isForBussiness {
            alert.addAction(UIAlertAction(title: "Files", style: .default, handler: { _ in
                self.openDocument()
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        if AppFunctions.isIpad() {
            //In iPad Change Rect to position Popover
            alert.popoverPresentationController?.sourceView = vc.view
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            alert.popoverPresentationController?.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY * 2, width: vc.view.bounds.width, height: 0)
            
            
            vc.present(alert, animated: true, completion: nil)
        }
        else {
            vc.present(alert, animated: true, completion: nil)
        }
        
    }
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            vc.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera permissions.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            vc.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func openDocument() {
        let supportedTypes = ["public.image","public.png","public.jpeg"]

        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = vc as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        vc.present(documentPicker, animated: true, completion: nil)
    }
}
