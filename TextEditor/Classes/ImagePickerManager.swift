import UIKit
import AVFoundation
import Photos

protocol WXImagePickerDelegate: class {

    func didFinishPicking(image: UIImage?, info: [String: Any])

}

class ImagePickerManager: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var imagePicker: UIImagePickerController? = nil
    weak var wxDelegate: WXImagePickerDelegate? = nil
    var textColor: UIColor = .white
    var barColor: UIColor = .blue

    private var applicationName: String? {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
    }

    func takeFoto() {
        checkCameraPermissions()
    }

    func selectFoto() {
        checkPhotoLibraryPermission()
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .notDetermined:
            configurePicker(for: .photoLibrary)
            break
        case .denied, .restricted:
            alertToEncourageCameraAccessInitially(type: .photoLibrary)
            break
        }
    }

    private func checkCameraPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized, .notDetermined:
            configurePicker(for: .camera)
            break
        case .denied, .restricted:
            alertToEncourageCameraAccessInitially(type: .camera)
            break
        }
    }

    private func alertToEncourageCameraAccessInitially(type: UIImagePickerControllerSourceType) {
        let alert = UIAlertController(title: applicationName, message: type == .camera ? NSLocalizedString("Приложению нужен доступ к вашей камере.", comment: "") : NSLocalizedString("Приложению нужен доступ к вашей галерее.", comment: ""), preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Настройки", comment: ""), style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func configurePicker(for type: UIImagePickerControllerSourceType) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = type
        imagePicker?.navigationBar.isTranslucent = false
        imagePicker?.navigationBar.backgroundColor = barColor
        imagePicker?.navigationBar.barTintColor = barColor
        imagePicker?.navigationBar.tintColor = textColor
        imagePicker?.navigationBar.titleTextAttributes = [.foregroundColor: textColor]
        present(imagePicker!, animated: true, completion: nil)
    }

    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        wxDelegate?.didFinishPicking(image: pickedImage, info: info)
        dismiss(animated: true, completion: nil)
    }

}
