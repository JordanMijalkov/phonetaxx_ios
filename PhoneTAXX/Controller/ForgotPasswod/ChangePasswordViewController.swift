//
//  ChangePasswordViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 07/04/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var changePasswordDownLineLabel: UILabel!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textConfirmPassword: UITextField!
    var a = false
    var b = false
    var uidforUser = ""
    let db = Firestore.firestore()
    @IBOutlet weak var buttonSubmit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        addShadowTofeild()
        textPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textConfirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password..", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        let iconImage1 = UIImage(named: "password")
        setPaddingPasswordWithImage(image: iconImage1!, textField: textPassword)
   
        let iconImage2 = UIImage(named: "password")
        setPaddingConfirmPasswordWithImage(image: iconImage2!, textField: textConfirmPassword)
    }
    
   

    @IBAction func buttonSubmit(_ sender: Any) {
        let password = textPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmpassword = textConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        chkFieldValidation()
        if a && b {
            Auth.auth().currentUser?.updatePassword(to: textPassword.text!) { [self] (error) in
                if let error = error {
                 //   self.showError("Error Creating User")
                    print("Failed to sign in with error",error)
                    return
                } else {
                    let email = Auth.auth().currentUser?.email
                    //self.db.collection("users").document().setData( ["password": textPassword.text!], merge: true)
                    print("uid is ....",uidforUser)
                    db.collection("USERS").whereField("uid", isEqualTo: uidforUser).getDocuments { (result, error) in
                        if error == nil{
                            for document in result!.documents{
                                document.reference.setData(["password": textPassword.text!] , merge: true)
                            }
                        }
                    }
                    
                    
                           print("password changed for email ", email)
                            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignINViewController") as! SignINViewController
                            self.navigationController?.pushViewController(secondViewController, animated: true)
                    
                    

                    }

                }
            
        }
        
       
            
        }
        
    }
//MARK: - UiDesign work

extension ChangePasswordViewController{
    func chkFieldValidation(){
        if textPassword.text! != textConfirmPassword.text! {
            a = false
            openAlert(title: "Alert", message: "Password is not match ", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in
                print("okay Clicked")
            }])
        }
        else {
            // password mathch
            a = true
        }
            if(textPassword.text! == "" || textConfirmPassword.text! == "") {
                b = false
                openAlert(title: "Alert", message: "Fill the password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in
                    print("okay Clicked")
                }])
            } else {
                //both field are not empty
                b = true
                
            }

        
    }
    func addShadowTofeild(){
        changePasswordDownLineLabel.layer.masksToBounds = true
        changePasswordDownLineLabel.layer.cornerRadius = 4
        
        textPassword.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textPassword.layer.masksToBounds = true
        textPassword.layer.cornerRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowColor = UIColor.lightGray.cgColor
        textPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textPassword.layer.shadowOpacity = 1.0
      

        textConfirmPassword.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textConfirmPassword.layer.masksToBounds = true
        textConfirmPassword.layer.cornerRadius = textConfirmPassword.frame.size.height / 2
        textConfirmPassword.layer.shadowRadius = textConfirmPassword.frame.size.height / 2
        textConfirmPassword.layer.shadowColor = UIColor.lightGray.cgColor
        textConfirmPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textConfirmPassword.layer.shadowOpacity = 1.0
        

        buttonSubmit.layer.cornerRadius = buttonSubmit.bounds.height / 2
        buttonSubmit.layer.shadowRadius = 20
        buttonSubmit.layer.shadowRadius = buttonSubmit.bounds.height / 2
        buttonSubmit.layer.shadowColor = UIColor.lightGray.cgColor
        
    }
    func setPaddingPasswordWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 20, y: 15, width: 16, height: 21)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
    
    func setPaddingConfirmPasswordWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 20, y: 15, width: 16, height: 21)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
}
