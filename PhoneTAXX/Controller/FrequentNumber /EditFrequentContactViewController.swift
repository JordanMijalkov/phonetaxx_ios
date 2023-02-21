//
//  EditFrequentContactViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 23/06/21.
//

import UIKit
import  FirebaseFirestore
class EditFrequentContactViewController: UIViewController, UITextViewDelegate {
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
    @IBOutlet weak var naicsView: UIView!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    let db = Firestore.firestore()
    var category = "1"
    var conatctName = ""
    var conatctPhNum = ""
    var conatctBusiness = ""
    var conatctEIN = ""
    var conatctNAICS = ""
    var conatctLocation = ""
    var conatctCategory = ""
    var conatctUUId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberText.delegate = self
        textViewLocation.delegate = self
        buttonAndTextFieldCurveAndShadow()
        getConatctDetail()
    }
    @IBAction func canelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func searchBtn(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.census.gov/naics/?"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    func getConatctDetail(){
        nameText.text = conatctName
        phoneNumberText.text = conatctPhNum
        textViewLocation.text = conatctLocation
        businessNameText.text = conatctBusiness
        einText.text = conatctEIN
        naicsCodeText.text = conatctNAICS
        if conatctCategory == "1" {
            PersonImageAndTextView.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            personImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            personLabel.textColor = UIColor.white
            personImagePersonal.image = UIImage(named: "personimagewhite")
            businessImageAndTextView.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            businessImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            businessLabel.textColor = UIColor.black
            businessImage.image = UIImage(named: "businessicon")
            
        }else if conatctCategory == "2"{
            PersonImageAndTextView.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            personImageAndTextView1.layer.backgroundColor = UIColor(hexString: "#DEE6FB").cgColor
            personLabel.textColor = UIColor.black
            personImagePersonal.image = UIImage(named: "ic_record_voice_over_24px")
            businessImageAndTextView.layer.backgroundColor = UIColor(hexString: "#1844A3").cgColor
            businessImageAndTextView1.layer.backgroundColor = UIColor(hexString:    "#1844A3").cgColor
            businessLabel.textColor = UIColor.white
            businessImage.image = UIImage(named: "businessimagewhite")
            
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if textFieldFill(){
                    print("uid ==",conatctUUId)
                    self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("uuId", isEqualTo: conatctUUId).getDocuments { (result, error) in
                        if error == nil{
                             for document in result!.documents{
                                document.reference.setData(["businessname": self.businessNameText.text] , merge: true)
                                document.reference.setData(["category": self.category] , merge: true)
                                document.reference.setData(["ein": self.einText.text] , merge: true)
                                document.reference.setData(["location": self.textViewLocation.text!] , merge: true)
                                document.reference.setData(["naicscode": self.naicsCodeText.text] , merge: true)
                                document.reference.setData(["name": self.nameText.text!] , merge: true)
                                document.reference.setData(["phonenumber": self.phoneNumberText.text!] , merge: true)
                            
                             }
                            self.view.makeToast("Profile Updated Successfully",duration:3.0, position:.center)
                        }
                        
                            
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
                         // Code you want to be delayed
                         self.navigationController?.popViewController(animated: true)
            }
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
    func textFieldFill()-> Bool {
            
            if (phoneNumberText.text == "") {
                
                openAlert(title: "Alert", message: "Please enter Phone Number", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            }
            else if (businessNameText.text != "" && naicsCodeText.text == ""){
                openAlert(title: "Alert", message: "Please enter NAICS Code", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            }
            else if (nameText.text == "") {
                    openAlert(title: "Alert", message: "Please enter Name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("Okay Clicked")
                    }])
                return false
            }
            else if (textViewLocation.text == "" ) {
                openAlert(title: "Alert", message: "Please enter Location", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                return false
            }
        return true
        }
}
//MARK: - UIWork
extension EditFrequentContactViewController : UITextFieldDelegate{
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
        naicsView.layer.cornerRadius = naicsView.bounds.height / 2
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

