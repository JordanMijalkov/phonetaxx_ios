//
//  EditProfileViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/06/21.
//

import UIKit
import SDWebImage
import FirebaseAuth
import  FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
class EditProfileViewController: UIViewController, MICountryPickerDelegate, UITextViewDelegate {

    @IBOutlet weak var phTextView: UIView!
    @IBOutlet weak var countryCodeTF: UITextField!
    @IBOutlet weak var countryCodeImg: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var locationTV: GrowingTextView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var supervisorTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var naicsTF: UITextField!
    @IBOutlet weak var einTF: UITextField!
    @IBOutlet weak var businessTF: UITextField!
    @IBOutlet weak var editprofileView: UIView!
    @IBOutlet weak var naicsView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        getProfileDetail()
        locationTV.delegate = self
        self.phoneNumberTF.delegate = self
    }
    @IBAction func searchBtn(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.census.gov/naics/?"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    @IBAction func backBtnTapeed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func countryCodeBtnAction(_ sender: UIButton) {
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
                //DialCode = "\(dialCode)"
                countryCodeTF.text = "\(dialCode)"//"Selected Country: \(name) , \(code)"
                countryCodeImg.image = UIImage( named: bundle + code.lowercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)
            
        }
    @IBAction func saveBtnAction(_ sender: UIButton) {
       let validate = chkFeildValidation()
       print("chkFeildValidation",validate)
        if validate {
            db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
                if error == nil{
                     for document in result!.documents{
                        document.reference.setData(["businessname": self.businessTF.text!] , merge: true)
                        document.reference.setData(["fullname": self.nameTF.text!] , merge: true)
                        document.reference.setData(["phonenumber": self.phoneNumberTF.text!] , merge: true)
                        document.reference.setData(["supervisoremail": self.supervisorTF.text!] , merge: true)
                        document.reference.setData(["naicscode": self.naicsTF.text!] , merge: true)
                        document.reference.setData(["eincode": self.einTF.text!] , merge: true)
                        document.reference.setData(["location": self.locationTV.text!] , merge: true)
                        document.reference.setData(["countryCode": self.countryCodeTF.text!] , merge: true)
                     }
                    self.view.makeToast("Profile Updated Successfully",duration:3.0, position:.center)
                }
            
           }
        }
        else {
            
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
    @IBAction func editImagAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            CameraHandler.shared.showActionSheet(vc: self)
            CameraHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                self.userImg.image = image
                self.createImgUrl(image)
            }
        }
    }
    func getProfileDetail(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                 for document in result!.documents{
                    let data = document.data()
                    if let email  = data["email"] as? String ,
                       let profileUrl  = data["profileUrl"] as? String ,
                       let phonenumber = data["phonenumber"] as? String,
                       let businessname = data["businessname"] as? String,
                       let eincode = data["eincode"] as? String,
                       let naicscode = data["naicscode"] as? String,
                       let supervisoremail = data["supervisoremail"] as? String,
                       let location = data["location"] as? String,
                       let countryCode = data["countryCode"] as? String,
                       let fullname  = data["fullname"] as? String {
                            self.emailTF.text = email
                            self.phoneNumberTF.text = phonenumber
                            self.nameTF.text = fullname
                            self.businessTF.text = businessname
                            self.supervisorTF.text = supervisoremail
                            self.einTF.text = eincode
                            self.locationTV.text = location
                            self.naicsTF.text = naicscode
                            self.countryCodeTF.text = countryCode
                           self.userImg.sd_setImage(with: URL(string: profileUrl), placeholderImage: UIImage(named: "splash.png"))
                            
                    }
                 }
            }
        
       }
    }
    func createImgUrl(_ image: UIImage) {
            var data = Data()
            data = image.jpegData(compressionQuality: 0.6)!
// set upload path
            let filePath = "user-images/\(Auth.auth().currentUser!.uid)/0.jpg"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"

            let photoRef = Storage.storage().reference().child(filePath)

            photoRef.putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
    //                self.activityIndicatorView.stopAnimating()
                 //   self.deleteUser(error.localizedDescription)
                    return
                } else {
                    photoRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error.localizedDescription)
    //self.activityIndicatorView.stopAnimating()
    // self.deleteUser(error.localizedDescription)
                            return
                        } else {
                            let photoURL = url!.absoluteString
                            print("image url is ",photoURL)
                            self.uploadImgUrl(photoFilePath: photoURL)
                        }
                    })
                }
            }
        }
    func uploadImgUrl(photoFilePath: String){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                 for document in result!.documents{
                     document.reference.setData(["profileUrl": photoFilePath] , merge: true)
                 }
            }
        
       }
    }
    func chkFeildValidation()->Bool {
            
            let pNTxtCounter = phoneNumberTF.text?.count ?? 0
            if nameTF.text == "" {
            openAlert(title: "Alert", message: "Please enter full name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
            print("Okay Clicked")
            }])
                return false
            }
           if countryCodeTF.text == "" {
                openAlert(title: "Alert", message: "Please enter Country Code", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                     print("Okay Clicked")
                }])
                return false
            }
            if supervisorTF.text != "" {
           
               if !(supervisorTF.text?.validateEmailId(supervisorTF.text!))!{
                openAlert(title: "Alert", message: "Please enter  valid Supervisor Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                   }])
                return false
              }
              
          }
        if (businessTF.text != "" && naicsTF.text == ""){
                openAlert(title: "Alert", message: "Please enter NAICS Code", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
            return false
            }
          if (locationTV.text == "") {
            
              openAlert(title: "Alert", message: "Please enter your location ", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                print("Okay Clicked")
              }])
            return false
          }
            if (phoneNumberTF.text == "") {
                
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
            if emailTF.text == "" {
                
                openAlert(title: "Alert", message: "Please enter Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            } else if emailTF.text != "" {
               
                if !(emailTF.text?.validateEmailId(emailTF.text!))!{
                    openAlert(title: "Alert", message: "Please enter  valid Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
                    return false
                }
               
            }
        return true
    }
   
}
//MARK: - UI Design Code


extension EditProfileViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.phoneNumberTF{
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
    func uiDesign() {
        
        searchBtn.layer.cornerRadius = 10
        searchBtn.clipsToBounds = true
        naicsView.layer.cornerRadius = naicsView.bounds.height / 2
        saveBtn.layer.cornerRadius = saveBtn.bounds.height / 2
        saveBtn.clipsToBounds = true
        userImg.layer.cornerRadius = userImg.bounds.height / 2
        userImg.clipsToBounds = true
        countryCodeTF.setLeftPaddingPoints(60)
        phTextView.layer.masksToBounds = true
        phTextView.layer.cornerRadius = phTextView.bounds.height / 2
        phTextView.layer.shadowRadius = 4.0
        phTextView.layer.shadowColor = UIColor.lightGray.cgColor
        phTextView.layer.shadowOffset = .zero
        phTextView.layer.shadowOpacity = 0.4
        editprofileView.layer.cornerRadius = 25
        editprofileView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        editprofileView.layer.masksToBounds = false
        editprofileView.layer.backgroundColor = UIColor.white.cgColor
        editprofileView.layer.shadowColor = UIColor.lightGray.cgColor
        editprofileView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        editprofileView.layer.shadowOpacity = 0.5
        
        locationTV.placeholderColor = UIColor(hexString: "#6F7FB0")
        locationTV.minHeight = 105
        locationTV.maxHeight = 105
        locationView.layer.cornerRadius = 25
        nameTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        nameTF.layer.masksToBounds = true
        nameTF.layer.cornerRadius = nameTF.frame.size.height / 2
        nameTF.layer.shadowRadius = nameTF.frame.size.height / 2
        nameTF.layer.shadowColor = UIColor.lightGray.cgColor
        nameTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        nameTF.layer.shadowOpacity = 1.0
        
        nameTF.setLeftPaddingPoints(60)
        let userIcon = UIImage(named: "person identity")
        setPaddingWithImage(image: userIcon!, textField: nameTF)
        
        phoneNumberTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        phoneNumberTF.layer.masksToBounds = true
       // phoneNumberTF.layer.cornerRadius = phoneNumberTF.frame.size.height / 2
        phoneNumberTF.layer.shadowRadius = phoneNumberTF.frame.size.height / 2
        phoneNumberTF.layer.shadowColor = UIColor.lightGray.cgColor
        phoneNumberTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        phoneNumberTF.layer.shadowOpacity = 1.0
        
        phoneNumberTF.setLeftPaddingPoints(60)
        let userIconPhone = UIImage(named: "person identity")
        setPaddingWithImage(image: userIconPhone!, textField: phoneNumberTF)
        
        supervisorTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        supervisorTF.layer.masksToBounds = true
        supervisorTF.layer.cornerRadius = supervisorTF.frame.size.height / 2
        supervisorTF.layer.shadowRadius = supervisorTF.frame.size.height / 2
        supervisorTF.layer.shadowColor = UIColor.lightGray.cgColor
        supervisorTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        supervisorTF.layer.shadowOpacity = 1.0
        
        supervisorTF.setLeftPaddingPoints(60)
        let userIconSE = UIImage(named: "mail")
        setPaddingWithImage(image: userIconSE!, textField: supervisorTF)
        
        emailTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        emailTF.layer.masksToBounds = true
        emailTF.layer.cornerRadius = emailTF.frame.size.height / 2
        emailTF.layer.shadowRadius = emailTF.frame.size.height / 2
        emailTF.layer.shadowColor = UIColor.lightGray.cgColor
        emailTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        emailTF.layer.shadowOpacity = 1.0
        
        emailTF.setLeftPaddingPoints(60)
        let userIconEM = UIImage(named: "mail")
        setPaddingWithImage(image: userIconEM!, textField: emailTF)
        
        naicsTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        naicsTF.layer.masksToBounds = true
        naicsTF.layer.cornerRadius = naicsTF.frame.size.height / 2
        naicsTF.layer.shadowRadius = naicsTF.frame.size.height / 2
        naicsTF.layer.shadowColor = UIColor.lightGray.cgColor
        naicsTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        naicsTF.layer.shadowOpacity = 1.0
        
        naicsTF.setLeftPaddingPoints(60)
        let userIconNAI = UIImage(named: "pichart")
        setPaddingWithImage(image: userIconNAI!, textField: naicsTF)
        
        businessTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        businessTF.layer.masksToBounds = true
        businessTF.layer.cornerRadius = businessTF.frame.size.height / 2
        businessTF.layer.shadowRadius = businessTF.frame.size.height / 2
        businessTF.layer.shadowColor = UIColor.lightGray.cgColor
        businessTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        businessTF.layer.shadowOpacity = 1.0
        
        businessTF.setLeftPaddingPoints(60)
        let userIconB = UIImage(named: "business")
        setPaddingWithImage(image: userIconB!, textField: businessTF)
        
        einTF.placeholderColor(color: UIColor(hexString: "#6F7FB0"))
        einTF.layer.masksToBounds = true
        einTF.layer.cornerRadius = businessTF.frame.size.height / 2
        einTF.layer.shadowRadius = businessTF.frame.size.height / 2
        einTF.layer.shadowColor = UIColor.lightGray.cgColor
        einTF.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        einTF.layer.shadowOpacity = 1.0
        
        einTF.setLeftPaddingPoints(60)
        let userIconE = UIImage(named: "pageView")
        setPaddingWithImage(image: userIconE!, textField: einTF)
        setFlagAndPhoneNumberCodeLeftViewIcon(icon: UIImage(named: "down button arrow")!)
    }
    func setPaddingWithImage(image: UIImage, textField: UITextField){
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
    func setFlagAndPhoneNumberCodeLeftViewIcon(icon: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 6.32, height: 3.08))
        btnView.setImage(icon, for: .normal)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right:  10)
        self.countryCodeTF.rightViewMode = .always
        self.countryCodeTF.rightView = btnView
    }
}
