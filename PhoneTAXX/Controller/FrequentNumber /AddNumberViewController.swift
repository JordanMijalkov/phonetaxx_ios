//
//  AddNumberViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Contacts
import ContactsUI

class AddNumberViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var frequentNumberView: UIView!
    @IBOutlet weak var locationOuterView: UIView!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var businessNameText: UITextField!
    @IBOutlet weak var einText: UITextField!
    @IBOutlet weak var naicsCodeText: UITextField!
    @IBOutlet weak var textViewLocation: GrowingTextView!
    @IBOutlet weak var PersonImageAndTextView: UIView!
    @IBOutlet weak var personImageAndTextView1: UIView!
    @IBOutlet weak var personImagePersonal: UIImageView!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var personButton: UIButton!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var businessImageAndTextView: UIView!
    @IBOutlet weak var businessImageAndTextView1: UIView!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var naicsCodeview: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    var conatctName = ""
    var conatctPhNo = ""
    var isComeFromContact = false
    let db = Firestore.firestore()
    var contacts : [FetchedContact]? = []
    var ref2: DocumentReference? = nil
    var category = "1"
    var btnTag    : Int = 0
    var isAllValidationChecked = false
    var contactImg : UIImage?
    var ifComeFromContact = false
    override func viewDidLoad() {
            super.viewDidLoad()
        print("viewDidLoad")
        
        

            phoneNumberText.delegate = self
            buttonAndTextFieldCurveAndShadow()
            textViewLocation.delegate = self
            let userIcon = UIImage(named: "ContactPhone")
            setPaddingPhoneNumberWithImage(image: userIcon!, textField: phoneNumberText)
            
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        

        self.ifComeFromContact = FrequentNumberSave.instance.ifComeFromContact
        self.conatctName = FrequentNumberSave.instance.conatctName
        self.conatctPhNo = FrequentNumberSave.instance.conatctPhNo
        self.contactImg = FrequentNumberSave.instance.contactImg
        print("isComeFromContact \(self.ifComeFromContact)")
        print("isComeFromContact \(self.conatctName)")
        print("isComeFromContact \(self.conatctPhNo)")
        print("isComeFromContact \(self.contactImg)")
        if FrequentNumberSave.instance.ifComeFromContact {
                phoneNumberText.text = conatctPhNo
                nameText.text = conatctName

            }
        
        
        
        
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
            if textViewLocation.text.isEmpty
            {
                textViewLocation.text = "Location (City, State)"
                textViewLocation.textColor = UIColor(hexString: "#6F7FB0")
            }
            textView.resignFirstResponder()
    }
        
   func setPaddingPhoneNumberWithImage(image: UIImage, textField: UITextField){
            let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 100  , height: 100))
            btnView.setImage(image, for: .normal)
            btnView.imageEdgeInsets = UIEdgeInsets(top:-35, left: 0, bottom: -35, right: 50)
            btnView.imageView?.contentMode = .scaleAspectFit
            if textField == phoneNumberText{
                btnView.addTarget(self, action: #selector(self.showButtonTapped), for: .touchUpInside)
            }
            textField.rightViewMode = .always
            textField.rightView = btnView
            
        }
            
        @objc func showButtonTapped(_ sender: UIButton) {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        @IBAction func canelButton(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
        }
        
    @IBAction func searchBtn(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.census.gov/naics/?"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    @IBAction func saveNumberButton(_ sender: Any) {
        
            self.textFieldFill()
            if isAllValidationChecked{
                CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid")!
                        print("CurrentUserUid in load msg R", CurrentUserUid)
                let timeStamp = Int(NSDate().timeIntervalSince1970)
        
                db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phonenumber", isEqualTo: phoneNumberText.text).getDocuments { (result, error) in
                    if error == nil{
                        if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                            print("snapshotDocuments", snapshotDocuments)
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                print("data is ", data)
                                if let phnum  = data["phonenumber"] as? String {
                                    print("ph num already exist ")
                                    self.openAlert(title: "Alert", message: "Category saved " , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                                        print("Okay Clicked")
                                    }])
                                }
                            }
                        } else{
                            print("no not exist ")
    // add contact to frequent data
                            self.ref2 = self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").addDocument(data:
                                        ["phonenumber": self.phoneNumberText.text,
                                         "name" : self.nameText.text,
                                         "businessname" : self.businessNameText.text,
                                         "ein": self.einText.text,
                                         "naicscode": self.naicsCodeText.text,
                                         "location":self.textViewLocation.text,
                                         "userUuid": CurrentUserUid,
                                         "category": self.category,
                                         "createdAt":"\(timeStamp)",
                                         "profileUrl" : "",
                                         "uuId": self.ref2?.documentID]){ (error) in
                                    if error != nil {
                                        print("Error while entering CONTACTS is ",error?.localizedDescription)
                                         self.textFieldFill()
                                    }else {
                                        
                                        self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS")
                                        .whereField("createdAt", isEqualTo: "\(timeStamp)")
                                        .getDocuments { (result, error) in
                                          if error == nil{
                                               for document in result!.documents{
                                                if self.ifComeFromContact{
                                                    let data = document.data()
                                                    if let phonenumber  = data["phonenumber"] as? String {
                                                        print("Contact Image : \(self.contactImg)")
                                                        self.createImgUrl(self.contactImg ?? UIImage(), phnum: phonenumber)
                                                    }
                                                }
                                                   document.reference.setData(["uuId": self.ref2!.documentID] , merge: true)
                                                }
                                                 self.view.makeToast("Saved to Frequent Number",  duration: 2.0, position: .center)
                                            }
                                       }

                                }
                            }
                        }
                    }else{print("errror while checking ph no is ", error?.localizedDescription)}
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
                   // Code you want to be delayed
                            FrequentNumberSave.instance.conatctName = ""
                            FrequentNumberSave.instance.conatctPhNo = ""
                            FrequentNumberSave.instance.ifComeFromContact = false
                            FrequentNumberSave.instance.contactImg = UIImage()
                    self.navigationController?.popViewController(animated: true)
                }
                
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
    func textFieldFill() {
            
            if (phoneNumberText.text == "") {
                
                openAlert(title: "Alert", message: "Please enter Phone Number", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
            }
            else if (nameText.text == "") {
                    openAlert(title: "Alert", message: "Please enter Name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
            }else if (businessNameText.text != "" && naicsCodeText.text == ""){
                openAlert(title: "Alert", message: "Please enter NAICS Code", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
            }
            else if (textViewLocation.text == "" ) {
                openAlert(title: "Alert", message: "Please enter Location", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
            }else {
                isAllValidationChecked = true
            }
        
        }
    
    @IBAction func personalButtonTapped(_ sender: Any) {
        category = "1"
            PersonImageAndTextView.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            personImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            personLabel.textColor = UIColor.white
            personImagePersonal.image = UIImage(named: "personimagewhite")
            businessImageAndTextView.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            businessImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            businessLabel.textColor = UIColor.black
            businessImage.image = UIImage(named: "businessicon")
        }
        
    @IBAction func BusinessButtonTapped(_ sender: Any) {
            category  = "2"
            PersonImageAndTextView.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            personImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            personLabel.textColor = UIColor.black
            personImagePersonal.image = UIImage(named: "ic_record_voice_over_24px")
            businessImageAndTextView.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            businessImageAndTextView1.layer.backgroundColor = UIColor(hexString:    "#1844A3").cgColor
            businessLabel.textColor = UIColor.white
            businessImage.image = UIImage(named: "businessimagewhite")
        }
    func createImgUrl(_ image: UIImage, phnum : String) {
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
                            self.uploadImgUrl(photoFilePath: photoURL, phnum: phnum)
                        }
                    })
                }
            }
        }
    func uploadImgUrl(photoFilePath: String, phnum:String){
        db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phonenumber", isEqualTo: phnum).getDocuments { (result, error) in
            if error == nil{
                 for document in result!.documents{
                     document.reference.setData(["profileUrl": photoFilePath] , merge: true)
                 }
            }
        
       }
    }
        
    }

//MARK: - UIDESIGN WORK
extension UINavigationController {

   func backToViewController(vc: Any) {
      // iterate to find the type of vc
      for element in viewControllers as Array {
        if "\(type(of: element)).Type" == "\(type(of: (vc as AnyObject)))" {
            self.popToViewController(element, animated: true)
            break
         }
      }
   }

}
extension AddNumberViewController : UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == self.phoneNumberText{
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
        
        func buttonAndTextFieldCurveAndShadow() {
            searchBtn.layer.cornerRadius = 10
            searchBtn.clipsToBounds = true
            naicsCodeview.layer.cornerRadius = naicsCodeview.bounds.height / 2
            frequentNumberView.layer.cornerRadius = 25
            frequentNumberView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            frequentNumberView.layer.masksToBounds = false
            frequentNumberView.layer.backgroundColor = UIColor.white.cgColor
            frequentNumberView.layer.shadowColor = UIColor.lightGray.cgColor
            frequentNumberView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            frequentNumberView.layer.shadowOpacity = 0.5
            
            phoneNumberText.layer.masksToBounds = true
            phoneNumberText.layer.cornerRadius =  phoneNumberText.frame.size.height / 2
            phoneNumberText.layer.shadowRadius =  phoneNumberText.frame.size.height / 2
            phoneNumberText.layer.shadowColor = UIColor.lightGray.cgColor
            phoneNumberText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            phoneNumberText.layer.shadowOpacity = 0.4
            phoneNumberText.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: phoneNumberText.frame.height))
            phoneNumberText.leftViewMode = .always
            
            textViewLocation.placeholder = "Location (City, State)"
            textViewLocation.minHeight = 105
            textViewLocation.maxHeight = 105
            nameText.layer.masksToBounds = true
            nameText.layer.cornerRadius =   nameText.frame.size.height / 2
            nameText.layer.shadowRadius =   nameText.frame.size.height / 2
            nameText.layer.shadowColor = UIColor.lightGray.cgColor
            nameText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            nameText.layer.shadowOpacity = 0.4
            nameText.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height:  nameText.frame.height))
            nameText.leftViewMode = .always
            
            
            businessNameText.layer.masksToBounds = true
            businessNameText.layer.cornerRadius =  businessNameText.frame.size.height / 2
            businessNameText.layer.shadowRadius = businessNameText.frame.size.height / 2
            businessNameText.layer.shadowColor = UIColor.lightGray.cgColor
            businessNameText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            businessNameText.layer.shadowOpacity = 0.4
            businessNameText.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: businessNameText.frame.height))
            businessNameText.leftViewMode = .always
            
            
            
            
            einText.layer.masksToBounds = true
            einText.layer.cornerRadius =  einText.frame.size.height / 2
            einText.layer.shadowRadius =  einText.frame.size.height / 2
            einText.layer.shadowColor = UIColor.lightGray.cgColor
            einText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            einText.layer.shadowOpacity = 0.4
            einText.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: einText.frame.height))
            einText.leftViewMode = .always
            
            
            naicsCodeText.layer.masksToBounds = true
            naicsCodeText.layer.cornerRadius = naicsCodeText.bounds.height / 2
            naicsCodeText.layer.shadowRadius = naicsCodeText.bounds.height / 2
            naicsCodeText.layer.shadowColor = UIColor.lightGray.cgColor
            naicsCodeText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            naicsCodeText.layer.shadowOpacity = 0.4
            naicsCodeText.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: naicsCodeText.frame.height))
            naicsCodeText.leftViewMode = .always
            
            locationOuterView.layer.cornerRadius = 20
            textViewLocation.layer.masksToBounds = true
            textViewLocation.layer.cornerRadius = 20
            textViewLocation.layer.shadowRadius = 4.0
            textViewLocation.layer.shadowColor = UIColor.lightGray.cgColor
            textViewLocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            textViewLocation.layer.shadowOpacity = 0.4
    //        textViewLocation.placeholderColor = UIColor(hexString: "#6F7FB0")
    //        textViewLocation.minHeight = 105
    //        textViewLocation.maxHeight = 105
            
            businessImageAndTextView.layer.cornerRadius = businessImageAndTextView.frame.height/2
            businessImageAndTextView.layer.shadowColor = UIColor.lightGray.cgColor
            
            PersonImageAndTextView.layer.cornerRadius = PersonImageAndTextView.frame.height/2
            PersonImageAndTextView.layer.shadowColor = UIColor.lightGray.cgColor
            
            saveButtonOutlet.layer.cornerRadius = saveButtonOutlet.frame.height/2
            saveButtonOutlet.layer.shadowColor = UIColor.lightGray.cgColor
            
    //        let searchImage    = NSTextAttachment()
    //        searchImage.image  = UIImage(named: "search")
    //        searchImage.bounds = CGRect.init(x: 0, y: 0, width: 14, height: 20)
    //        let search  = NSAttributedString(attachment: searchImage)
    //        let text = NSMutableAttributedString(string: "")
    //
    //        text.append(search)
    //        textViewLocation.attributedText = text
    //        textViewLocation.attributedText = search
            
        }
        
    }
