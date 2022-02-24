import Foundation
import UIKit


class ImagePickerManager: NSObject {

    var picker = UIImagePickerController()
    var alert = UIAlertController(title: "Choose an Image.", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage?, URL?) -> ())?
    
    override init(){
        super.init()
        picker.allowsEditing = true
        let imageAction = UIAlertAction(title: "Photo", style: .default) { UIAlertAction in
            self.viewController?.present(self.createAlertImage(), animated: true)
        }
        
        let videoAction = UIAlertAction(title: "Video", style: .default){
            UIAlertAction in
            self.viewController?.present(self.createAlertVideo(), animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        // Add the actions
        picker.delegate = self
        alert.addAction(imageAction)
        alert.addAction(videoAction)
        alert.addAction(cancelAction)
    }
    
    // video action provider
    func createAlertVideo() -> UIAlertController {
        alert.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Choose a Video", message: "Where would you like to get it from?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Video", style: .default) { [weak self] _ in
            self?.openCameraVideo()
        }
        
        let videoLibraryAction = UIAlertAction(title: "Video Lybrary", style: .default) { [weak self] _ in
            self?.openGalleryVideo()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(videoLibraryAction)
        alert.addAction(cancelAction)
        return alert
    }
    
    // image action provider
    func createAlertImage() -> UIAlertController {
        alert.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Choose an Image", message: "Where would you like to get it from?", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default){
            [weak self] _ in
            self?.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default){
            [weak self] _ in
            self?.openGallery()
        }

        let cencelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cencelAction)
        return alert
    }

    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage?, URL?) -> ())) {
        pickImageCallback = callback
        self.viewController = viewController
        
        alert.popoverPresentationController?.sourceView = self.viewController?.view

        viewController.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - video related methods
    func openCameraVideo() {
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            
            self.viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning",
                                                   message: "Your camera does not support this futures or you are on simulator version.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGalleryVideo () {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        viewController?.present(picker, animated: true)
    }
    
    
    //MARK: - photo related methods
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning",
                                                   message: "Your camera does not support this futures or you are on simulator version.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController?.present(picker, animated: true, completion: nil)
    }

}

extension ImagePickerManager : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.editedImage] as? UIImage {
            pickImageCallback?(image, nil)
        }
        else if let mediaUrl = info[.mediaURL]  as? URL {
            pickImageCallback?(nil, mediaUrl)
        }
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
}
