//
//  ViewController.swift
//  imagePicker
//
//  Created by Dmitry Torshin on 04.04.17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "selectImage")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit//.scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let email = UITextField()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.placeholder = "Email"
        email.layer.borderWidth = 1.0
        email.layer.cornerRadius = 5
        email.layer.borderColor = UIColor.gray.cgColor
        return email
    }()
    
    let passwTextField: UITextField = {
        let passw = UITextField()
        passw.translatesAutoresizingMaskIntoConstraints = false
        passw.placeholder = "Password"
        passw.isSecureTextEntry = true
        passw.layer.borderWidth = 1.0
        passw.layer.cornerRadius = 5
        passw.layer.borderColor = UIColor.gray.cgColor
        return passw
    }()
    
    let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(signInButtonAction), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New in AppName? Sign Up now!", for: .normal)
        button.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
        return button
    }()
    
    let saveImageButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save in Storage!", for: .normal)
        button.addTarget(self, action: #selector(saveImageButtonAction), for: .touchUpInside)
        return button
    }()
    
    func saveImageButtonAction(sender: UIButton!) {
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let userProfileImagesRef = storageRef.child("images/UserProfileImages/test.jpg")
        
        var data = NSData()
        data = UIImageJPEGRepresentation(profileImageView.image!, 0.8)! as NSData
        
        var metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = userProfileImagesRef.put(data as Data, metadata: metadata) { (metadata, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            let downloadURL = metadata?.downloadURL()?.absoluteString
            print(" It's OK! ", downloadURL)
        }
        
    }
    
    func signInButtonAction(sender: UIButton!) {
        emailTextField.resignFirstResponder()
        guard let login = emailTextField.text else {return}
        passwTextField.resignFirstResponder()
        guard let passw = passwTextField.text else {return}
        
        //Если пароль больше 6 символов
        if passw.characters.count >= 6 {
            FIRAuth.auth()?.signIn(withEmail: login, password: passw, completion: { (user, error) in
                if let err = error {
                    let alert = UIAlertController(title: "Sign in error!", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                print("Sign in OK!")
                let alert = UIAlertController(title: "Success!", message: "User \(user?.email) Signed in", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //let homePageView = homeViewController(nibName: nil, bundle: nil)
                //self.navigationController?.pushViewController(homePageView, animated: true)
            })
        } else {
            let alert = UIAlertController(title: "Your password must be at least 6 characters!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func signUpButtonAction(sender: UIButton!) {
        emailTextField.resignFirstResponder()
        guard let login = emailTextField.text else {return}
        passwTextField.resignFirstResponder()
        guard let passw = passwTextField.text else {return}
        
        let validEmail = isValidEmail(testStr: login)
        
        if validEmail {
            if passw.characters.count >= 6 {
                FIRAuth.auth()?.createUser(withEmail: login, password: passw, completion: { (user, error) in
                    if let err = error {
                        let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print(err.localizedDescription)
                        
                        return
                    }
                    print("Seccessfully created new user with email & passw", user?.uid ?? "")
                    // we need to open home page or sign in page after creating new user in Farebase ???
                   // self.navigationController?.pushViewController(self.homePageView, animated: true)
                })
            }
            else {
                let alert = UIAlertController(title: "Your password must be at least 6 characters!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        else {
            let alert = UIAlertController(title: "Your e-mail is not valid!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    
    func handleSelectProfileImageView()  {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //print("cancel picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(profileImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(saveImageButton)
        
        profileImageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 50.0).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        profileImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 168.0).isActive = true
        //--------------
        emailTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10.0).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //--------------
        passwTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10.0).isActive = true
        passwTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //--------------
        signInButton.topAnchor.constraint(equalTo: passwTextField.bottomAnchor, constant: 10.0).isActive = true
        signInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        signInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //--------------
        signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10.0).isActive = true
        signUpButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        signUpButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //--------------
        saveImageButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 50.0).isActive = true
        saveImageButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        saveImageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (!(emailTextField.text?.isEmpty)! && !(passwTextField.text?.isEmpty)!) {
            self.signInButton.isEnabled = true // enable button
        } else {
            self.signInButton.isEnabled = false // disable button
        }
        return true;
    }

}

