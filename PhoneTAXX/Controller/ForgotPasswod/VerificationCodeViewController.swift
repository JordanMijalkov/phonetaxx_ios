//
//  VerificationCodeViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 07/04/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Alamofire

public var userCallUID = ""
public var CurrentUserUid = ""
public var myPhoneNum = ""
public var myName = ""
class VerificationCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var verificationCodeDownLineLabel: UILabel!
    
    @IBOutlet weak var verifyAccLbl: UILabel!
    @IBOutlet weak var textCodeBlock1: UITextField!
    @IBOutlet weak var textCodeBlock2: UITextField!
    @IBOutlet weak var textCodeBlock3: UITextField!
    @IBOutlet weak var textCodeBlock4: UITextField!
    @IBOutlet weak var textCodeBlock5: UITextField!
    @IBOutlet weak var textCodeBlock6: UITextField!
    var apiLoginResponseModel : ApiLoginResponseModel?
    @IBOutlet weak var resendCodeLabel: UILabel!
    @IBOutlet weak var buttonVerifyCode: UIButton!
    var phNumber = ""
    var totalHour = Int()
    var totalMinut = Int()
    var totalSecond = 60
    var newPhoneNumber = ""
    var timer:Timer?
    
    let db = Firestore.firestore()
    var Vfullname = ""
    var Vbusinessname = ""
    var Veincode = ""
    var Vnaicscode = ""
    var Vemail = ""
    var Vsupervisoremail = ""
    var isFrom = false
    var countryCode = ""
    var location = ""
    @IBOutlet weak var timerLbl: UILabel!
    var Vpassword = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        let code = "\(textCodeBlock1.text!)\(textCodeBlock2.text!)\(textCodeBlock3.text!)\(textCodeBlock4.text!)\(textCodeBlock5.text!)\(textCodeBlock6.text!)"
       
        self.verifyAccLbl.text = "Verify your account by entring the 6 digits code we sent to: \(phNumber)"
       
        NotificationCenter.default.addObserver( self,selector:#selector(self.keyboardDidShow), name: UITextField.textDidChangeNotification, object: code)
        textCodeBlock1.autocorrectionType = .no
        textCodeBlock2.autocorrectionType = .no
        textCodeBlock3.autocorrectionType = .no
        textCodeBlock4.autocorrectionType = .no
        textCodeBlock5.autocorrectionType = .no
        textCodeBlock6.autocorrectionType = .no
        shadowToAllField()
    
        textCodeBlock1.delegate = self
        textCodeBlock2.delegate = self
        textCodeBlock3.delegate = self
        textCodeBlock4.delegate = self
        textCodeBlock5.delegate = self
        textCodeBlock6.delegate = self
        textCodeBlock1.becomeFirstResponder()
        
        
        textCodeBlock1.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        textCodeBlock2.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        textCodeBlock3.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        textCodeBlock4.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        textCodeBlock5.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        textCodeBlock6.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        
        
    }
   
    
    @IBAction func resendbtntapped(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        resendOtp()
    }
    
    @objc func keyboardDidShow(notifcation: NSNotification) {
  //      if code.text?.count == 4 {
   //  buttonContinue.isEnabled = true
  //   buttonLogin(buttonContinue)
     }
    //else {
    // buttonContinue.isEnabled = false
    // }
    // }
    
    @objc func countdown() {
        if totalSecond > 0 {
            totalSecond = totalSecond - 1
            print("time is ", totalSecond)
            resendBtn.isUserInteractionEnabled = false
            resendCodeLabel.text = "Resend code in 00:\(totalSecond)"
        } else {
            print("Otp Expired")
            resendCodeLabel.text = "Resend OTP"
            timer?.invalidate()
            resendBtn.isUserInteractionEnabled = true
            totalSecond = 60
        }
        
    }
    func resendOtp(){
        let pHONENUM = countryCode + phNumber
        PhoneAuthProvider.provider().verifyPhoneNumber(pHONENUM, uiDelegate: nil) { (verficationId, error) in
        if error != nil {
        print("error for verification :\(error?.localizedDescription)")
       
        return
        } else {
                print("verficationId is ....", verficationId)
                let defaults = UserDefaults.standard
                defaults.set(verficationId,forKey: "authVID")
                }
       
            }
    }
    
    
    @IBAction func buttonVerifyCode(_ sender: Any) {
        let code = "\(textCodeBlock1.text!)\(textCodeBlock2.text!)\(textCodeBlock3.text!)\(textCodeBlock4.text!)\(textCodeBlock5.text!)\(textCodeBlock6.text!)"
        print("CODE ISSS \(code)")
        let defaults = UserDefaults.standard
        let credential:PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: code)
        
                Auth.auth().signIn(with: credential) { (result, error) in
                  if let error = error {
                    let eror = error.localizedDescription
                     print(error.localizedDescription)
                    
                       self.openAlert(title: "Alert", message: "Invalid OTP" , alertStyle: .alert, actionTitles: ["Resend Code"], actionStyles: [.default], actions: [{ _ in
                        print("Resend Code")
                        
                       // function for resend verification code
                         
                         self.resendOtp()
                    }])
                  }
                  else
                  {
                    let credentiall = EmailAuthProvider.credential(withEmail: self.Vemail, password: self.Vpassword)
                    print("CURRENT USER IS \(Auth.auth().currentUser)")
                    Auth.auth().currentUser?.link(with: credentiall) { (authResult, error) in
                      // ...
                    }
                    if self.isFrom{
                        // move to reset password screen here
                        
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                        secondViewController.uidforUser = (result?.user.uid)!
                        self.navigationController?.pushViewController(secondViewController, animated: true)
                        
                    }else
                      {
                        UserDefaults.standard.setValue((result?.user.uid)!, forKey: "current_userUid")
                        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
                        myPhoneNum = self.phNumber
                        myName = self.Vfullname
                        print("Data bAse Entry Successful at user id ", CurrentUserUid )
                        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                        let timeStamp = Int(NSDate().timeIntervalSince1970)
                    
                        self.db.collection("USERS").document((result?.user.uid)!).setData(
                                            ["fullname": self.Vfullname,
                                            "phonenumber": self.phNumber,
                                            "email": self.Vemail,
                                            "businessname": self.Vbusinessname,
                                            "eincode": self.Veincode,
                                            "naicscode": self.Vnaicscode,
                                            "supervisoremail": self.Vsupervisoremail ,
                                            "password" : self.Vpassword,
                                            "profileUrl": "",
                                            "loginType": "Normal",
                                            "countryCode":"\(self.countryCode)",
                                            "createdAt": "\(timeStamp)",
                                            "deleted" : "0",
                                            "lastSyncTime": "",
                                            "mothlyBillAmount": "",
                                            "callDetection": "",
                                            "emailNotification": "",
                                            "location": self.location,
                                            "pushNotification": "",
                                            "socialId": "",
                                            "businessScreenTime": "",
                                            "Subscription": "Free",
                                            "PlanExpiryDate":"",
                                            "PlanStartDate": "",
                                            "stripeCustomerId": "",
                                            "uid": result!.user.uid]) { (error) in
                            if error != nil {
                                print("error for creating database  :\(error!.localizedDescription)")
                            }
                            else {
                                
                                UserDefaults.standard.setValue((result?.user.uid)!, forKey: "current_userUid")
                               // CurrentUserUid = (result?.user.uid)!
                                
                                print("Data bAse Entry Successful at user id ", CurrentUserUid )
                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                print("Data bAse Entry Successful at user id ", (result?.user.uid)! )
                                self.hitApiInSignIn(uidd: result!.user.uid, userName: self.Vfullname, countryCode: self.countryCode, mobile_no: self.newPhoneNumber, email: self.Vemail, password: self.Vpassword)
                            }
                       }
                        
//                        hitApiInSignIn()
                        
//                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                        secondViewController.uidforUser = (result?.user.uid)!
//                        self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                }
            }
    }
 
    
}


extension VerificationCodeViewController {
    
    func hitApiInSignIn(uidd:String,userName:String,countryCode:String,mobile_no:String,email:String,password:String){
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let fcmToken = UserDefaults.standard.value(forKey: "newFcmToken") as? String ?? ""
        
        let tokenURL = URL(string: "https://dev.theappkit.co.uk/phonetax/public/api/register")
        let parameters = [
            "customer_id":uidd,
            "username":userName,
            "country_code":countryCode,
            "mobile_no":mobile_no,
            "email":email,
            "password":password,
            "device_type":"I",
            "firebase_token":fcmToken,
            "device_id":deviceID
        ] as [String : Any]
        print("LoginApiResponseModel----------,https://dev.theappkit.co.uk/phonetax/public/api/register", parameters)
        
        AF.request(tokenURL as! URLConvertible, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseData { (respData) in
                switch(respData.result) {
                case .success(_):
                guard let data = respData.data else {return}
                print("Success HITLOGIN API-------\(data)")
                do{
                    let decoder = JSONDecoder()
                    self.apiLoginResponseModel = try decoder.decode(ApiLoginResponseModel.self, from: data)
                    print("apiLoginResponseModel-----Status----", self.apiLoginResponseModel?.status ?? false)
                    guard let status:Bool = self.apiLoginResponseModel?.status else{ return }
                    
                    if status == true{
                        print("----- LOGIN SUCCESSFUL----- ")
                        guard let message = self.apiLoginResponseModel?.message else {
                            
                            self.view.makeToast(self.apiLoginResponseModel?.message,duration: 2.0, position: .center)
                            return }
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        secondViewController.uidforUser = uidd
                        self.navigationController?.pushViewController(secondViewController, animated: true)
               
                    }
                    else {
                        print("------LoginApiResponseModel LoginApiResponseModel-------\(self.apiLoginResponseModel?.message)")
                        
                        self.view.makeToast(self.apiLoginResponseModel?.message,duration: 2.0, position: .center)

                    }
            
                
            } catch let error {
                print(error)
              
            }
            
        case .failure(_):
          
            break
        }
            }
        
        
        
    }
    
}






//MARK: - UIShadow Work
extension VerificationCodeViewController{
       
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1 ) && (string.count > 0) {
            if textField == textCodeBlock1 {
                textCodeBlock2.becomeFirstResponder()
            }
            
            if textField == textCodeBlock2 {
                textCodeBlock3.becomeFirstResponder()
            }
            
            if textField == textCodeBlock3 {
                textCodeBlock4.becomeFirstResponder()
            }
            
            if textField == textCodeBlock4 {
                textCodeBlock5.becomeFirstResponder()
            }
            if textField == textCodeBlock5 {
                textCodeBlock6.becomeFirstResponder()
            }
            if textField == textCodeBlock6 {
                textCodeBlock6.becomeFirstResponder()
            }
            
            textField.text = string
            return false
        }
        
        else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            if textField == textCodeBlock2 {
                textCodeBlock1.becomeFirstResponder()
            }
            if textField == textCodeBlock3 {
                textCodeBlock2.becomeFirstResponder()
            }
            if textField == textCodeBlock4 {
                textCodeBlock3.becomeFirstResponder()
            }
            if textField == textCodeBlock5 {
                textCodeBlock4.becomeFirstResponder()
            }
            if textField == textCodeBlock6 {
                textCodeBlock5.becomeFirstResponder()
            }
            
            if textField == textCodeBlock1 {
                textCodeBlock1.resignFirstResponder()
            }
            
            textField.text = ""
            return false
        } else if (textField.text?.count)! >= 1 {
            textField.text = string
            return false
        }
        
        return true
    }
    
    
    func shadowToAllField(){
        verificationCodeDownLineLabel.layer.masksToBounds = true
        verificationCodeDownLineLabel.layer.cornerRadius = 4
        
        textCodeBlock1.layer.masksToBounds = true
        textCodeBlock1.layer.cornerRadius = 20
        textCodeBlock1.layer.shadowRadius = 4.0
        textCodeBlock1.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock1.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock1.layer.shadowOpacity = 1.0
        
        textCodeBlock2.layer.masksToBounds = true
        textCodeBlock2.layer.cornerRadius = 20
        textCodeBlock2.layer.shadowRadius = 4.0
        textCodeBlock2.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock2.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock2.layer.shadowOpacity = 1.0
        
        textCodeBlock3.layer.masksToBounds = true
        textCodeBlock3.layer.cornerRadius = 20
        textCodeBlock3.layer.shadowRadius = 4.0
        textCodeBlock3.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock3.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock3.layer.shadowOpacity = 1.0
        
        textCodeBlock4.layer.masksToBounds = true
        textCodeBlock4.layer.cornerRadius = 20
        textCodeBlock4.layer.shadowRadius = 4.0
        textCodeBlock4.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock4.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock4.layer.shadowOpacity = 1.0
    
        textCodeBlock5.layer.masksToBounds = true
        textCodeBlock5.layer.cornerRadius = 20
        textCodeBlock5.layer.shadowRadius = 4.0
        textCodeBlock5.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock5.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock5.layer.shadowOpacity = 1.0
        
        textCodeBlock6.layer.masksToBounds = true
        textCodeBlock6.layer.cornerRadius = 20
        textCodeBlock6.layer.shadowRadius = 4.0
        textCodeBlock6.layer.shadowColor = UIColor.lightGray.cgColor
        textCodeBlock6.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textCodeBlock6.layer.shadowOpacity = 1.0
        
        buttonVerifyCode.layer.cornerRadius = buttonVerifyCode.bounds.height / 2
        buttonVerifyCode.layer.shadowRadius = 20
        buttonVerifyCode.layer.shadowRadius = buttonVerifyCode.bounds.height / 2
        buttonVerifyCode.layer.shadowColor = UIColor.lightGray.cgColor
       
    }
}


struct ApiLoginResponseModel : Codable {
    let status : Bool?
    let message : String?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case message = "message"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }

}
