//
//  CreateAccountViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 06/04/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController, MICountryPickerDelegate, UITextViewDelegate {
    
//    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
//        print("SELECTED COUNTRY IS \("asdasdasd")")
//    }
    

    
    @IBOutlet weak var labelCreateNewAccountDownLine: UILabel!
    @IBOutlet weak var textFullName: UITextField!
    @IBOutlet weak var textBussinessName: UITextField!
    @IBOutlet weak var phoneTextInCountryCodeAndNumberView: UIView!
    @IBOutlet weak var textFlagAndPhoneCode: UITextField!
    @IBOutlet weak var naicsView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var textPhoneNumber: UITextField!
    @IBOutlet weak var textEmailAddress: UITextField!
    @IBOutlet weak var textEin: UITextField!
    @IBOutlet weak var searchCodeBtn: UIButton!
    @IBOutlet weak var textNaicsCode: UITextField!
    @IBOutlet weak var textViewLocation: GrowingTextView!
    @IBOutlet weak var textSupervisorEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var checkBoxBtnOutlet: UIButton!
    @IBOutlet weak var tempImageView: UIImageView!
    var phAlreadyExist = false
    @IBOutlet weak var termsAndConditionAttributeLabel: UILabel!
    var DialCode = ""
    @IBOutlet weak var buttonCreateAccount: UIButton!
    var checkFortermAndPolicies = false
    var btnTag    : Int = 0
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadowToField()
       // textViewLocation.delegate = self
        textViewLocation.placeholderColor = UIColor(hexString: "#6F7FB0")
        textViewLocation.minHeight = 105
        textViewLocation.maxHeight = 105
        textViewLocation.delegate = self
        self.navigationController?.navigationBar.isHidden=true
        self.textPhoneNumber.delegate = self
        textPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textFullName.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textBussinessName.attributedPlaceholder = NSAttributedString(string: "Business Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textPhoneNumber.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textEmailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textEin.attributedPlaceholder = NSAttributedString(string: "EIN", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textNaicsCode.attributedPlaceholder = NSAttributedString(string: "2017 NAICS Code", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textSupervisorEmail.attributedPlaceholder = NSAttributedString(string: "Supervisor Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        textFlagAndPhoneCode.attributedPlaceholder = NSAttributedString(string: "(US)+1", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        setFlagAndPhoneNumberCodeLeftViewIcon(icon: UIImage(named: "down button arrow")!)
        //setNaicsCodeLeftViewIcon(icon: UIImage(named: "arrow down")!)
        
        textFlagAndPhoneCode.setLeftPaddingPoints(60)
        let userIcon = UIImage(named: "person identity")
        setPaddingFullNameWithImage(image: userIcon!, textField: textFullName)
        
        let userIcon1 = UIImage(named: "business")
        setPaddingBusinessNameWithImage(image: userIcon1!, textField: textBussinessName)
        
        let userIcon2 = UIImage(named: "mail")
        setPaddingEmailAddressWithImage(image: userIcon2!, textField: textEmailAddress)
        
        let userIcon3 = UIImage(named: "pageView")
        setPaddingEinWithImage(image: userIcon3!, textField: textEin)
        
        let userIcon4 = UIImage(named: "pichart")
        setPaddingNaicsCodeWithImage(image: userIcon4!, textField: textNaicsCode)
        
        let userIcon6 = UIImage(named: "mail")
        setPaddingSupervisorEmailWithImage(image: userIcon6!, textField: textSupervisorEmail)
        
        let userIcon7 = UIImage(named: "password")
        setPaddingPasswordWithImage(image: userIcon7!, textField: textPassword)
         
        
       
        
    }
    @IBAction func searchCodeBtn(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.census.gov/naics/?"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    func textView(_ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String) -> Bool{
    guard let oldText = textView.text, let r = Range(range, in: oldText) else {
        return true
    }

    let newText = oldText.replacingCharacters(in: r, with: text)
    let isNumeric = newText.isEmpty || (newText) != nil
    let numberOfDots = newText.components(separatedBy: ",").count - 1

    let numberOfDecimalDigits: Int
    if let dotIndex = newText.index(of: ",") {
        numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
    } else {
        numberOfDecimalDigits = 0
    }

    return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 3
}
    @IBAction func btnTermAndConditions(_ sender: UIButton) {
        //https://firebasestorage.googleapis.com/v0/b/phonetaxx-8e8d7.appspot.com/o/terms_of_service_updated.html?alt=media
        if let url = NSURL(string: "https://www.phonetaxx.com/terms"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    @IBAction func buttonSignIn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkBoxTapped(_ sender: Any) {
        if checkBoxBtnOutlet.isSelected {
            checkBoxBtnOutlet.setBackgroundImage(#imageLiteral(resourceName: "tickbutton"), for: .selected)
            checkFortermAndPolicies = false
               } else {
                checkBoxBtnOutlet.setBackgroundImage(#imageLiteral(resourceName: "untickbutton"), for: .normal)
                checkFortermAndPolicies = true
               }
        checkBoxBtnOutlet.isSelected = !checkBoxBtnOutlet.isSelected
    }
   
    @IBAction func buttonCreateAccount(_ sender: Any) {
    
                let fullname = textFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let businessname = textBussinessName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let eincode = textEin.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let naicscode = textNaicsCode.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let phonenumber = textFlagAndPhoneCode.text! +  (textPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
                 print("phone number with code is ",phonenumber)
                let email = textEmailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let supervisoremail = textSupervisorEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = textPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let location = textViewLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                 if  self.chkFeildValidation() {
                    if checkFortermAndPolicies {
                     //Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                    
                        print("Checking if ph no already exist .....")
                        db.collection("USERS").whereField("phonenumber", isEqualTo: phonenumber).getDocuments { (result, error) in
                            if error == nil{
                                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                                    print("snapshotDocuments", snapshotDocuments)
                                    for doc in snapshotDocuments {
                                        let data = doc.data()
                                        print("data is ", data)
                                        if let phnum  = data["phonenumber"] as? String {
                                            self.phAlreadyExist = true
                                            print("ph num already exist ")
                                            self.openAlert(title: "Alert", message: "Phone Number already Registered " , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                                                print("Okay Clicked")
                                            }])
                                        }
                                    }
                                } else {
                                    // if snapshot empty
                                    print("no not exist ")
                                    self.phAlreadyExist = false
                                    let phnumm =
                                    PhoneAuthProvider.provider().verifyPhoneNumber(phonenumber, uiDelegate: nil) { [self] (verficationId, error) in
                                        if error != nil {
                                             let eror = error?.localizedDescription
                                            print("error for verification :\(error?.localizedDescription)")
                                            self.openAlert(title: "Alert", message: "Enter Correct Phone Number " , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                                                print("Okay Clicked")
                                            }])
                                            return
                                        } else {
                                            print("verficationId is ....", verficationId)
                                            let defaults = UserDefaults.standard
                                            defaults.set(verficationId,forKey: "authVID")
                                         
                                            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VerificationCodeViewController") as! VerificationCodeViewController
                                            secondViewController.phNumber = self.textPhoneNumber.text!
                                            secondViewController.Vbusinessname = businessname ?? ""
                                            secondViewController.Veincode = eincode ?? ""
                                            secondViewController.Vemail = email ?? ""
                                            secondViewController.Vfullname = fullname ?? ""
                                            secondViewController.Vnaicscode = naicscode ?? ""
                                            secondViewController.Vsupervisoremail = supervisoremail ?? ""
                                            secondViewController.Vpassword = password ?? ""
                                            secondViewController.countryCode = self.DialCode ?? ""
                                            secondViewController.newPhoneNumber = self.textFlagAndPhoneCode.text! +  (self.textPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
                                            secondViewController.location = location ?? ""
                                            self.navigationController?.pushViewController(secondViewController, animated: true)
                                        }
                                    }// end verification
                                    
                                }
                            } else {
                                print("errror while checking ph no is ", error?.localizedDescription)
                            }
                        }
                        
                  
                } else {
                    openAlert(title: "Alert", message: "Please confirm term and policies ", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
                    
                }
                  }
              
           
    }
        //checkBoxBtnOutlet.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
    func chkFeildValidation() -> Bool{
            let pTxtCounter = textPassword.text?.count ?? 0
            let pNTxtCounter = textPhoneNumber.text?.count ?? 0
            if (textFullName.text == "") {
            openAlert(title: "Alert", message: "Please enter full name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
            print("Okay Clicked")
            }])
                return false
            }
            if textSupervisorEmail.text != "" {
           
               if !(textSupervisorEmail.text?.validateEmailId(textSupervisorEmail.text!))!{
                openAlert(title: "Alert", message: "Please enter  valid Supervisor Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                   }])
                   return false
              }
            
          }
          if (textViewLocation.text == "") {
            
              openAlert(title: "Alert", message: "Please enter your location ", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                print("Okay Clicked")
              }])
            return false
          }
            if (textPhoneNumber.text == "") {
                
                openAlert(title: "Alert", message: "Please enter Phone Number", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            } else if  pNTxtCounter < 10 || pNTxtCounter > 13 {
               
                openAlert(title: "Alert", message: "Enter a valid phone number with maximum 11 digit characters", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            }
            if textEmailAddress.text == "" {
                
                openAlert(title: "Alert", message: "Please enter Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            } else if textEmailAddress.text != "" {
               
                if !(textEmailAddress.text?.validateEmailId(textEmailAddress.text!))!{
                    openAlert(title: "Alert", message: "Please enter  valid Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
                    return false
                }
                
            }
            if (textBussinessName.text != "" && textNaicsCode.text == ""){
                openAlert(title: "Alert", message: "Please enter NAICS Code", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            }
            if (textPassword.text == "") {
                openAlert(title: "Alert", message: "Please enter Password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
                
            }else if textPassword.text != ""{
                if pTxtCounter < 6 {
                    openAlert(title: "Alert", message: "Please enter password of minimum 6 character for security purposes.", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
                    return false
                }
            }
        return true
    }
    
    @IBAction func openCountryCodeAction(_ sender: Any) {
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
                DialCode = "\(dialCode)"
                textFlagAndPhoneCode.text = "\(dialCode)"//"Selected Country: \(name) , \(code)"
                tempImageView.image = UIImage( named: bundle + code.lowercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)
            
        }
    
}
//MARK: -  textField delegate for PhoneNumber length

extension CreateAccountViewController :  UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textPhoneNumber{
            // get the current text, or use an empty string if that failed
            let currentText = textField.text ?? ""
            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }
            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            // make sure the result is under 16 characters
            return updatedText.count <= 13//11
        }
        else{ return true }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textViewLocation.text == "Location")
        {
            textViewLocation.text = nil
            textViewLocation.textColor = UIColor(hexString: "#6F7FB0")
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewLocation.text.isEmpty
        {
            textViewLocation.text = "Location"
            textViewLocation.textColor = UIColor(hexString: "#6F7FB0")
        }
        textView.resignFirstResponder()
    }

}
//MARK: -  UIDesign Change


extension CreateAccountViewController {
    func addShadowToField(){
        searchCodeBtn.layer.cornerRadius = 10
        searchCodeBtn.clipsToBounds = true
        naicsView.layer.cornerRadius = naicsView.bounds.height / 2
        labelCreateNewAccountDownLine.layer.masksToBounds = true
        labelCreateNewAccountDownLine.layer.cornerRadius = 4
        
        textFullName.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textFullName.layer.masksToBounds = true
        textFullName.layer.cornerRadius = textFullName.frame.size.height / 2
        textFullName.layer.shadowRadius = textFullName.frame.size.height / 2
        textFullName.layer.shadowColor = UIColor.lightGray.cgColor
        textFullName.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textFullName.layer.shadowOpacity = 0.4

        textBussinessName.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textBussinessName.layer.masksToBounds = true
        textBussinessName.layer.cornerRadius = textBussinessName.frame.size.height / 2
        textBussinessName.layer.shadowRadius = textBussinessName.frame.size.height / 2
        textBussinessName.layer.shadowColor = UIColor.lightGray.cgColor
        textBussinessName.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textBussinessName.layer.shadowOpacity = 0.4
        locationView.layer.cornerRadius = 25
    
        textPhoneNumber.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        phoneTextInCountryCodeAndNumberView.layer.masksToBounds = true
        phoneTextInCountryCodeAndNumberView.layer.cornerRadius = phoneTextInCountryCodeAndNumberView.bounds.height / 2
        phoneTextInCountryCodeAndNumberView.layer.shadowRadius = 4.0
        phoneTextInCountryCodeAndNumberView.layer.shadowColor = UIColor.lightGray.cgColor
        phoneTextInCountryCodeAndNumberView.layer.shadowOffset = .zero
        phoneTextInCountryCodeAndNumberView.layer.shadowOpacity = 0.4
      
        
        textEmailAddress.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textEmailAddress.layer.masksToBounds = true
        textEmailAddress.layer.cornerRadius = textEmailAddress.frame.size.height / 2
        textEmailAddress.layer.shadowRadius = textEmailAddress.frame.size.height / 2
        textEmailAddress.layer.shadowColor = UIColor.lightGray.cgColor
        textEmailAddress.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textEmailAddress.layer.shadowOpacity = 1.0
        
        
        textEin.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textEin.layer.masksToBounds = true
        textEin.layer.cornerRadius = textEin.frame.size.height / 2
        textEin.layer.shadowRadius = textEin.frame.size.height / 2
        textEin.layer.shadowColor = UIColor.lightGray.cgColor
        textEin.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textEin.layer.shadowOpacity = 1.0
        
      
        textNaicsCode.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textNaicsCode.layer.masksToBounds = true
        textNaicsCode.layer.cornerRadius = textNaicsCode.frame.size.height / 2
        textNaicsCode.layer.shadowRadius = textNaicsCode.frame.size.height / 2
        textNaicsCode.layer.shadowColor = UIColor.lightGray.cgColor
        textNaicsCode.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textNaicsCode.layer.shadowOpacity = 0.4
      
        
       
  //      textViewLocation.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textViewLocation.layer.masksToBounds = true
        textViewLocation.layer.cornerRadius = 20
        textViewLocation.layer.shadowRadius = 4.0
        textViewLocation.layer.shadowColor = UIColor.lightGray.cgColor
        textViewLocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textViewLocation.layer.shadowOpacity = 0.4
//        let searchImage    = NSTextAttachment()
//        searchImage.image  = UIImage(named: "search")
//        searchImage.bounds = CGRect.init(x: 0, y: 0, width: 14, height: 20)
//        let search  = NSAttributedString(attachment: searchImage)
//        let text = NSMutableAttributedString(string: "Location")
//
//        text.append(search)
//        textViewLocation.attributedText = text
//        textViewLocation.attributedText = search
        
        textSupervisorEmail.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textSupervisorEmail.layer.masksToBounds = true
        textSupervisorEmail.layer.cornerRadius = textSupervisorEmail.frame.size.height / 2
        textSupervisorEmail.layer.shadowRadius = textSupervisorEmail.frame.size.height / 2
        textSupervisorEmail.layer.shadowColor = UIColor.lightGray.cgColor
        textSupervisorEmail.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textSupervisorEmail.layer.shadowOpacity = 0.4
       
        
       
        textPassword.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textPassword.layer.masksToBounds = true
        textPassword.layer.cornerRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowColor = UIColor.lightGray.cgColor
        textPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textPassword.layer.shadowOpacity = 0.4
       
        
        buttonCreateAccount.layer.cornerRadius = buttonCreateAccount.bounds.height / 2
        buttonCreateAccount.layer.shadowRadius = 20
        buttonCreateAccount.layer.shadowRadius = buttonCreateAccount.bounds.height / 2
        buttonCreateAccount.layer.shadowColor = UIColor.lightGray.cgColor
        
        
        
//        let attributedString = NSMutableAttributedString.init(string: "I have read and agree with the Terms & Conditions")
//        let range = NSString(string: "I have read and agree with the Terms & Conditions").range(of: "Terms Conditions", options: String.CompareOptions.caseInsensitive)
//        attributedString.addAttributes( [ NSAttributedString.Key.foregroundColor: UIColor.init(red: 24/255, green: 68/255, blue: 163/255, alpha: 1) ], range: range)
        let Atext = NSMutableAttributedString()
           Atext.append(NSAttributedString(string: "I have read and agree with the ", attributes: [NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235))]));
        Atext.append(NSAttributedString(string:  "Terms", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 24/255, green: 68/255, blue: 163/255, alpha: 1)]));
        Atext.append(NSAttributedString(string: " & ", attributes: [NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235))]));
        Atext.append(NSAttributedString(string: "Conditions ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 24/255, green: 68/255, blue: 163/255, alpha: 1)]))
//           currentDaySTatusLabel.attributedText = text
        termsAndConditionAttributeLabel.attributedText = Atext
        
        
    }
    
    func setPaddingFullNameWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 15, y: 15, width: 17.89, height: 17.89)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
   
    func setPaddingBusinessNameWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 15, y: 15, width: 20, height: 18)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }

    func setFlagAndPhoneNumberCodeLeftViewIcon(icon: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 6.32, height: 3.08))
        btnView.setImage(icon, for: .normal)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right:  10)
        self.textFlagAndPhoneCode.rightViewMode = .always
        self.textFlagAndPhoneCode.rightView = btnView
    }
    
    func setPaddingEmailAddressWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 18, y: 18, width: 20, height: 16)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
    
    func setPaddingEinWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 18, y: 18, width: 20, height: 16)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
    
    func setPaddingNaicsCodeWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 17, y: 15, width: 20, height: 20)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }

    func setNaicsCodeLeftViewIcon(icon: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        btnView.setImage(icon, for: .normal)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right:  20)
        self.textNaicsCode.rightViewMode = .always
        self.textNaicsCode.rightView = btnView
    }
  
    func setPaddingSupervisorEmailWithImage(image: UIImage, textField: UITextField){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 18, y: 18, width: 20, height: 16)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 23, y: 0, width: 10, height: 50))

        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
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
   
}

//    func validateFields()->String? {
//        if textFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textBussinessName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//             textPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textEmailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textEin.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textNaicsCode.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//        textViewLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//         textSupervisorEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  ||
//            textPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            return "Please fill in all Fields."
//
//        }
//        let cleanedPassword = textPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
//        if String.validatePassword(cleanedPassword!)() == false {
//            return "please make sure your password in at least 8 Characters, contains a special character and a number."
//        }
//
//        return nil
//
//    }


//func IfPhExist( phnumber : String){
//
//        db.collection("users").whereField("phonenumber", isEqualTo: phnumber).getDocuments { (result, error) in
//            if error == nil{
//                if let snapshotDocuments = result?.documents{
//                    for doc in snapshotDocuments {
//                        let data = doc.data()
//                        if let phnum  = data["phonenumber"] as? String {
//                            self.phAlreadyExist = true
//                            print("ph no already exist ")
//                        }
//
//                    }
//                }
//            } else {
//                print("no not exist ")
//                self.phAlreadyExist = false
//            }
//        }
//
//    }
