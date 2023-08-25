//
//  ChangeProfilePictureViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 2/27/23.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ChangeProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var savedLabel: UILabel!
    
    // link to firebase and storage
    private let storage = Storage.storage().reference()
    private let database = Database.database().reference()
    
    let picker = UIImagePickerController()
    
    // check where it has been coming from; either
    //sign up or account settings
    var delegate: UIViewController!
    var comingFrom: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedLabel.isHidden = true
        savedLabel.text = ""
        // if not signed in we send user to profile page
        isSignedIn()

        // make profile picture rounded
        profilePicture.roundedImage()
              
        // if we came form account settings than we load the current profile picture
        if comingFrom == "Settings"{
            self.navigationItem.hidesBackButton = false
            loadProfilePicture()
        }
        else{
            self.navigationItem.hidesBackButton = true
        }

        picker.delegate = self

    }
    
    //get image url for profile from firebase func
    func loadProfilePicture(){
        self.showSpinnerProfile(onView: self.view)
        
        let userID = Auth.auth().currentUser?.uid
        let database = Database.database().reference()
        
        let databaseRef = database.child("users").child(userID!).child("profilePictureID")
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot, ref) in
            let data = snapshot.value as? String
            
            let url = URL(string: data!)
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.profilePicture.image = UIImage(data: imageData)
                    needsFirebaseUpdate = true
                    self.removeSpinnerProfile()
                    
                }
            }.resume()
            

        }
    }
    
    func isSignedIn(){
        
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "UsernameToProfile", sender: nil)
        }
        
    }
    
    @IBAction func savePictureButtonPressed(_ sender: Any) {
        saveProfilePicture()
        
    }
    
    func saveProfilePicture(){
        
        self.showSpinnerProfile(onView: self.view)
        savedLabel.text = ""
        savedLabel.isHidden = true
        
        let chosenImage = profilePicture.image
        let userID = Auth.auth().currentUser?.uid
        
        
        let storageRef = storage.child(userID!)
        let databaseRef = database.child("users").child(userID!).child("profilePictureID")
        
        // upload out image to storage
        let uploadTask = storageRef.putData(chosenImage!.pngData()!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
            // Uh-oh, an error occurred!
                return
            }
          // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
          // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url?.absoluteString else {
              // Uh-oh, an error occurred!
                    self.savedLabel.text = "Sorry, we encountered a problem while uploading your profile picture. Please try again or upload a new picture to use."
                    self.savedLabel.isHidden = false
                    self.removeSpinnerProfile()
                    return
                }
                // puts the url into database connected to the users account
                databaseRef.setValue(downloadURL)
                self.removeSpinnerProfile()
                self.savedLabel.text = "Your profile picture has been saved successfully."
                self.savedLabel.isHidden = false
            }
            
        }
        
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        //needsFirebaseUpdate = true
        self.performSegue(withIdentifier: "changeProfileToProfile", sender: nil)
    }
    
    
    @IBAction func imagePicked(_ sender: Any) {
        
        savedLabel.text = ""
        savedLabel.isHidden = true
        
        let howToChangeAlert = UIAlertController(
            title: "Change Profile Picture",
            message: "From where?",
            preferredStyle: .alert)
        howToChangeAlert.addAction(UIAlertAction(
                                title: "From Library",
                                style: .default,
                                handler: { action in
                                    self.fromExistingPressed()}))
        howToChangeAlert.addAction(UIAlertAction(
                                title: "Take Picture",
                                style: .default,
                                handler: { action in
                                    self.takePicturePressed()}))
        howToChangeAlert.addAction(UIAlertAction(
                                title: "Default Picture",
                                style: .default,
                                handler: { action in
                                    let chosenImage = UIImage(named: "DefaultProfilePicture")
                                    self.profilePicture.image = chosenImage
                                }))
        howToChangeAlert.addAction(UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: nil))
        present(howToChangeAlert, animated: true, completion: nil)
        
    }
    
    func takePicturePressed() {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in
                    guard accessGranted == true else { return }
                }
            case .authorized:
                break
            default:
                print("Access denied")
                return
            }
            
            picker.allowsEditing = true
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            
            present(picker, animated: true, completion: nil)
        
        } else {
            
            let alertVC = UIAlertController(
                title: "No camera",
                message: "Buy a better phone",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
            
        }
    }
    
    func fromExistingPressed() {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // "info" contains a dictionary of information about the selected media, including:
        // - metadata
        // - a user-edited image (if we set the allowsEditing property to true)
        
        let chosenImage = info[.editedImage] as! UIImage
        profilePicture.contentMode = .scaleAspectFit
        profilePicture.image = chosenImage
        
                
        dismiss(animated: true, completion: nil)
        
    }
    
    // if canclled is pressed while taking a picture or slecting then we go back
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // code to enable tapping on the background to remove software keyboard
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
}
