//
//  ViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 06/04/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ForgotPasswordViewController: UIViewController, MICountryPickerDelegate {
    
    
    @IBOutlet weak var phoneNumberAndFlagCodeView: UIView!
    @IBOutlet weak var txtPhoneNum: UITextField!
   
    @IBOutlet weak var buttonSendCode: UIButton!
    @IBOutlet weak var forwordPasswordDownLineLabel: UILabel!
    @IBOutlet weak var accountAndSignInAttributedLabel: UILabel!
    @IBOutlet weak var textFlagAndPhoneCode: UITextField!
    @IBOutlet weak var tempImageView: UIImageView!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
       
        txtPhoneNum.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textFlagAndPhoneCode.setLeftPaddingPoints(65)
        designForview()
        
    }
   

    @IBAction func buttonSendCode(_ sender: Any) {
        var  phnum = txtPhoneNum.text!
        
        let alert = UIAlertController(title: "Phone Number", message: "IS this Phone Number ?\n\(phnum)", preferredStyle: .alert)
       
        print("ph number is ", phnum)
        let action = UIAlertAction(title: "Ok", style: .default) { [self] (UIAlertAction) in
           //Auth.auth().settings?.isAppVerificationDisabledForTesting = true
            
            print("Checking if ph no already exist .....")
            db.collection("USERS").whereField("phonenumber", isEqualTo: phnum).getDocuments { (result, error) in
                if error == nil{
                    print("snapshotDocuments result?.documents", result?.documents)
                    if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                        
                        print("snapshotDocuments", snapshotDocuments)
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            print("data is ", data)
                            if let phnum  = data["phonenumber"] as? String,
                               let countryCode  = data["countryCode"] as? String{
                                //self.phAlreadyExist = true
                                print("ph num already exist ")
                                
                                let pHONENUMBER = countryCode + phnum
                                PhoneAuthProvider.provider().verifyPhoneNumber(pHONENUMBER, uiDelegate: nil) { (verficationId, error) in
                                    if error != nil {
                                        print("error:\(error?.localizedDescription)")
                                        
                                    } else {
                                        let defaults = UserDefaults.standard
                                        defaults.set(verficationId,forKey: "authVID")
                           
                                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VerificationCodeViewController") as! VerificationCodeViewController
                                            secondViewController.phNumber = phnum
                                            secondViewController.isFrom = true
                                        self.navigationController?.pushViewController(secondViewController, animated: true)

                                    }
                                }
                                
                                
                                
                            }
                        }
                        
                    } else {
                        // if snapshot empty
                        print("no not exist ")
                        //self.phAlreadyExist = false
                        
                        self.openAlert(title: "Alert", message: "Phone Number doesn't Exist " , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                            print("Okay Clicked")
                        }])
                        
                    }
                    
                } else {
                    print("errror while checking ph no is ", error?.localizedDescription)
                }
            } // end of db collection closure
    
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
//        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VerificationCodeViewController") as! VerificationCodeViewController
//        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    @IBAction func countryCodeBtn(_ sender: UIButton) {
        self.navigationItem.setHidesBackButton(false, animated: true)

        let picker = MICountryPicker { (name, code ) -> () in
            
            print("picked code : ",code)
            print("PICKED COUNTRY IS \(name)")
            let bundle = "assets.bundle/"
            print("IMAGE IS \(UIImage( named: bundle + code.lowercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil))")
        }
        // Optional: To pick from custom countries list
    //    picker.customCountriesCode = ["EG", "US", "AF", "AQ", "AX"]
        // delegate
        picker.delegate = self
        // Display calling codes
        picker.showCallingCodes = true
 
        // or closure
        picker.didSelectCountryClosure = { name, code in
            picker.navigationController?.isNavigationBarHidden=true
            picker.navigationController?.popViewController(animated: true)
            print(code)
        }
        navigationController?.pushViewController(picker, animated: true)
    }
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String ) {
                 picker.navigationController?.isNavigationBarHidden=true//?.popViewController(animated: true)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationItem.setHidesBackButton(true, animated: true)
                print("CODE IS \(code)")
                
                print("Dial Code ",dialCode)
        let bundle = "assets.bundle/"
        print("IMAGE IS \(UIImage( named: bundle + code.lowercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil))")
                textFlagAndPhoneCode.text = "\(dialCode)"//"Selected Country: \(name) , \(code)"
        tempImageView.image = UIImage( named: bundle + code.lowercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)
            
        }
    
    @IBAction func buttonRegister(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
}

//MARK: - Uidesign work

extension ForgotPasswordViewController{
    func designForview(){
        
        forwordPasswordDownLineLabel.layer.masksToBounds = true
        forwordPasswordDownLineLabel.layer.cornerRadius = 4
        
        phoneNumberAndFlagCodeView.layer.masksToBounds = true
        phoneNumberAndFlagCodeView.layer.cornerRadius = phoneNumberAndFlagCodeView.bounds.height / 2
        phoneNumberAndFlagCodeView.layer.shadowRadius = 4.0
        phoneNumberAndFlagCodeView.layer.shadowColor = UIColor.lightGray.cgColor
        phoneNumberAndFlagCodeView.layer.shadowOffset = .zero
        phoneNumberAndFlagCodeView.layer.shadowOpacity = 0.4
        
        
        buttonSendCode.layer.cornerRadius = buttonSendCode.bounds.height / 2
        buttonSendCode.layer.shadowRadius = buttonSendCode.bounds.height / 2
        buttonSendCode.layer.shadowColor = UIColor.lightGray.cgColor
        
    }
}

