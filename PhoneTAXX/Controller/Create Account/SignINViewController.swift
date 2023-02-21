import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
struct UserData {
    let fullname : String?
    let phonenumber : String?
    let email : String?
    let businessname : String?
    let eincode : String?
    let naicscode : String?
    let supervisoremail : String?
    let password : String?
    let uid : String?
}
var user = UserDefaults.standard
class SignINViewController: UIViewController, GIDSignInDelegate  {

    @IBOutlet weak var appleSignInView: UIView!
    @IBOutlet weak var googleSiginView: UIView!
    @IBOutlet weak var signInPhoneTaxxDownLineLabel: UILabel!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var buttonSignIn: UIButton!
    let db = Firestore.firestore()
    var name = ""
    var email = ""
    var uid = ""
    var phNumber = ""
    var isCreated = false
    var emailUsingPh = ""
    var SignInUsingEmail = false
    var userArr : [UserData] = []
    var remember = false
    override func viewDidLoad() {
        super.viewDidLoad()
       
        addShadowToMethod()
        rememberSwitch.isOn = false
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.navigationController?.navigationBar.isHidden=true
        let userIcon1 = UIImage(named: "mail")
        setPaddingEmailWithImage(image: userIcon1!, textField: textEmail)
        textPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#6F7FB0")])
        let userIcon2 = UIImage(named: "password")
        setPaddingPasswordWithImage(image: userIcon2!, textField: textPassword)
        if let eMAIL = UserDefaults.standard.string(forKey: "email"),
           let pASSWORD = UserDefaults.standard.string(forKey: "password"){
            textEmail.text = eMAIL
            textPassword.text = pASSWORD
        }
        googleLoginIn()
        
    }
   
   
    @IBAction func rememberMeSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            print("switch on ")
            remember = true
        }else {
            remember = false
            print("switch off ")
        }
    }
    
  
    @IBAction func buttonSignIn(_ sender: Any) {
       
        
        let email = textEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = textPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
       // if let email = textEmail.text,let password = textPassword.text {
        self.CheckValidField()
        
            if SignInUsingEmail{
                
                print("Sigin using Email id ")
                Auth.auth().signIn(withEmail: email!, password: password!) { [self] (result, error) in
                    if let e = error  {
                        print("error While Sign in using email  ",e.localizedDescription)
                        openAlert(title: "Alert", message: "Invalid Credentials "  , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                            print("enter the Correct Email ")
                        }])
                       
                    } else {
                      // code moving on next type screen
                        self.email = result?.user.email ?? ""
                        self.phNumber = result?.user.phoneNumber ?? ""
                        self.name = result?.user.displayName ?? ""
                        self.uid = result?.user.uid ?? ""
                        print("Email is ", email)
                        print("phnum is ", phNumber)
                        print("name is ", name)
                        if remember{
                            UserDefaults.standard.setValue(textEmail.text, forKey: "email")
                            UserDefaults.standard.setValue(textPassword.text, forKey: "password")
                        }
                        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                        UserDefaults.standard.setValue(self.uid, forKey: "current_userUid")
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                  }
                
            } else {
                loadData()
               /*
                print("Sigin using Phnumber  ")
                print("email is ", emailUsingPh)
                Auth.auth().signIn(withEmail: emailUsingPh, password: password!) { [self] (result, error) in
                    if let e = error  {
                        print("error While Sign in using ph no  ",e.localizedDescription)
                        openAlert(title: "Alert", message: "Invalid Credentials "  , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                            print("enter the Correct Email ")
                        }])
                       
                    } else {
                      // code moving on next type screen
                        self.email = result?.user.email ?? ""
                        self.phNumber = result?.user.phoneNumber ?? ""
                        self.name = result?.user.displayName ?? ""
                        self.uid = result?.user.uid ?? ""
                        print("Email is ", email)
                        print("phnum is ", phNumber)
                        print("name is ", name)
                        print("uid on sign in is ", uid)
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                  }*/
                
            }
       
       // }
    }
    
    
    
    @IBAction func buttonForgotPassword(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func buttonRegister(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
     }
    
    @IBAction func btnGoogleTapped(_ sender: UIButton) {
        
          GIDSignIn.sharedInstance()?.signIn()
      }
  
    @IBAction func appleSignInTapped(_ sender: UIButton) {
        performAppleSignIn()
    }
    
    func performAppleSignIn(){
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest{
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName , .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
//MARK: - Google Sign in functions
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("Function Call")
        if let error = error {
          print("Failed to sign in with error",error)
          return
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                              accessToken: authentication.accessToken)
           print("\(credential)")
            Auth.auth().signIn(with: credential) { [self] (result, error) in
                if let error = error {
                    print("Failed to sign in with error",error.localizedDescription)
                    return
                } else {
                    print("if login through google")
                    self.email = result?.user.email ?? ""
                    self.phNumber = result?.user.phoneNumber ?? ""
                    self.name = result?.user.displayName ?? ""
                    
                    self.uid = result?.user.uid ?? ""
                   
                    print("Email is ", email)
                    print("Email is ", phNumber)
                    print("Email is ", name)
                 //   CurrentUserUid = uid
                    print("uid on sign in using google is ", uid)
                    UserDefaults.standard.setValue(uid, forKey: "current_userUid")
                    UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                    if isCreated {
                        let timeStamp = Int(NSDate().timeIntervalSince1970)
                        db.collection("USERS").document(uid).setData(["fullname": name,
                                        "phonenumber": phNumber,
                                        "email": email,
                                        "businessname": "",
                                        "eincode": "",
                                        "naicscode": "",
                                        "supervisoremail": "" ,
                                        "profileUrl": "",
                                        "loginType": "Google",
                                        "countryCode":"",
                                        "createdAt": timeStamp,
                                        "deleted" : "",
                                        "location": "",
                                        "lastSyncTime": "",
                                        "mothlyBillAmount": "",
                                        "callDetection": "",
                                        "emailNotification": "",
                                        "pushNotification": "",
                                        "socialId": "",
                                        "businessScreenTime": "",
                                        "Subscription": "Free",
                                        "PlanExpiryDate":"",
                                        "PlanStartDate": "",
                                        "stripeCustomerId": "",
                                        "uid": uid]) { (error) in
                                                        if error != nil {
                                                            print("error for creating database  :\(error!.localizedDescription)")
                                                        }
                                                        else {
                        
                                                            print("Data base Created ")
                                                        }
                                    }
                                     isCreated = false
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                   // self.textEmail.text = email
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            }
        }
      }
    
    func googleLoginIn() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        if GIDSignIn.sharedInstance().hasPreviousSignIn() {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            print("Already Login")
          //  CurrentUserUid = UserDefaults.standard.value(forKey: "current_userUid") as! String
            UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
            print("uid on sign in using google is ", uid)
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        } else {
            print("Already Login not ")
            isCreated = true
//            // send data to data base here
//
//            db.collection("users").addDocument(data:
//                                                ["fullname": name,
//                                                "phonenumber": phNumber,
//                                                "email": email,
//                                                "businessname": "",
//                                                "eincode": "",
//                                                "naicscode": "",
//                                                "supervisoremail": "" ,
//                                                "uid": uid]) { (error) in
//                                if error != nil {
//                                    print("error for creating database  :\(error!.localizedDescription)")
//                                }
//                                else {
//
//                                    print("Data base Created ")
//                                }
//            }
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MonthlyPhoneBillViewController") as! MonthlyPhoneBillViewController
//            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
    func loadData(){
        db.collection("USERS").whereField("phonenumber", isEqualTo: textEmail.text!).getDocuments { (result, error) in
            self.userArr.removeAll()
            if error == nil{
                if let snapshotDocuments = result?.documents , snapshotDocuments != []{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        print("snapshotDocuments", data)
                        let email = data["email"] as? String
                        let fullname = data["fullname"] as? String
                        let phonenumber = data["phonenumber"] as? String
                        let businessname = data["businessname"] as? String
                        let eincode = data["eincode"] as? String
                        let naicscode = data["naicscode"] as? String
                        let supervisoremail = data["supervisoremail"] as? String
                        let password = data["password"] as? String
                        let uid = data["uid"] as? String
                        
                        let usrData = UserData(fullname: fullname, phonenumber: phonenumber, email: email, businessname: businessname, eincode: eincode, naicscode: naicscode, supervisoremail: supervisoremail, password: password, uid: uid)
                        self.userArr.append(usrData)
                        self.emailUsingPh = email ?? ""
                        
                            print("Sigin using Phnumber  ")
                        print("email is ", self.emailUsingPh)
                        Auth.auth().signIn(withEmail: self.emailUsingPh, password: password!) { [self] (result, error) in
                                if let e = error  {
                                    print("error While Sign in using ph no  ",e.localizedDescription)
                                    openAlert(title: "Alert", message: "Invalid Credentials "  , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                                        print("enter the Correct Email ")
                                    }])
                                   
                                } else {
                                  // code moving on next type screen
                                    self.email = result?.user.email ?? ""
                                    self.phNumber = result?.user.phoneNumber ?? ""
                                    self.name = result?.user.displayName ?? ""
                                    self.uid = result?.user.uid ?? ""
                                    print("Email is ", email)
                                    print("phnum is ", phNumber)
                                    print("name is ", name)
                                    
                                    UserDefaults.standard.setValue(self.uid, forKey: "current_userUid")
                                    print("uid on sign using ph no is ", self.uid)
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                                }
                              }
                            
                        
                        
                        
                        
                        
                        print("email for sign in is ", self.emailUsingPh)
                    }
                    
                } else {
                    self.openAlert(title: "Alert", message: "Invalid Credentials "  , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                        print("enter the Correct Email ")
                    }])
                }
            } else {
                print("error while fetching data is ", error?.localizedDescription)
            }
            
        }
        
    }
}
//MARK: - UI Design Methods

extension SignINViewController{
   
    func CheckValidField() {
        let pTxtCounter = textPassword.text?.count ?? 0
        if textEmail.text == "" {
            openAlert(title: "Alert", message: "Please enter Email id / Phone Number", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                print("enter the Correct Email ")
            }])
        }
        else if textEmail.text != "" {
            if !(textEmail.text?.validateEmailId(textEmail.text!))!{
                print("sigin using ph num")
                SignInUsingEmail = false
//                openAlert(title: "Alert", message: "Please enter valid Email id", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
//                    print("Okay Clicked")
//                }])
            } else {
                //
                print("sigin using email")
                SignInUsingEmail = true
            }
        }

        if textPassword.text == "" {
            openAlert(title: "Alert", message: "Fill the Password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                print("enter the Correct Email ")
            }])
        } else if textPassword.text != ""{
            if pTxtCounter < 6 {
                openAlert(title: "Alert", message: "Please enter password of minimum 6 character for security purposes.", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
                
            }
        }
    }
    
    
    func addShadowToMethod(){
        
        signInPhoneTaxxDownLineLabel.layer.masksToBounds = true
        signInPhoneTaxxDownLineLabel.layer.cornerRadius = 4
        googleSiginView.addCommonShadowToAll()
        appleSignInView.addCommonShadowToAll()
        textEmail.placeholderColor(color: UIColor.black)
        textEmail.layer.masksToBounds = true
        textEmail.layer.cornerRadius = textEmail.frame.size.height / 2
        textEmail.layer.shadowRadius = textEmail.frame.size.height / 2
        textEmail.layer.shadowColor = UIColor.lightGray.cgColor
        textEmail.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textEmail.layer.shadowOpacity = 1.0
        textEmail.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: textEmail.frame.height))
        textEmail.leftViewMode = .always
        
        textPassword.placeholderColor(color: UIColor.init(red: 111/255, green: 127/255, blue: 176/255, alpha: 2))
        textPassword.layer.masksToBounds = true
        textPassword.layer.cornerRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowRadius = textPassword.frame.size.height / 2
        textPassword.layer.shadowColor = UIColor.lightGray.cgColor
        textPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textPassword.layer.shadowOpacity = 1.0
        textPassword.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: textPassword.frame.height))
        textPassword.leftViewMode = .always
        
     
        
        buttonSignIn.layer.cornerRadius = buttonSignIn.bounds.height / 2
        buttonSignIn.layer.shadowRadius = buttonSignIn.bounds.height / 2
        buttonSignIn.layer.shadowRadius = buttonSignIn.bounds.height / 2
        buttonSignIn.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    
    
    func setPaddingEmailWithImage(image: UIImage, textField: UITextField){
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
 //MARK: - Apple Sigin Delegate
extension SignINViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let nonce = currentNonce else{
                fatalError("Invalid State : A Login callback was received, but no login request ")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data:\(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                if let user = result?.user{
                    print("You are Sign in as \(user.uid), email : \(user.email)")
                    UserDefaults.standard.setValue(user.uid, forKey: "current_userUid")
                    UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                    let timeStamp = Int(NSDate().timeIntervalSince1970)
                    self.db.collection("USERS").document(user.uid).setData(["fullname": "",
                                    "phonenumber": "",
                                    "email": user.email,
                                    "businessname": "",
                                    "eincode": "",
                                    "naicscode": "",
                                    "supervisoremail": "" ,
                                    "profileUrl": "",
                                    "loginType": "Apple",
                                    "countryCode":"",
                                    "createdAt": timeStamp,
                                    "deleted" : "",
                                    "location": "",
                                    "lastSyncTime": "",
                                    "mothlyBillAmount": "",
                                    "callDetection": "",
                                    "emailNotification": "",
                                    "pushNotification": "",
                                    "socialId": "",
                                    "businessScreenTime": "",
                                    "Subscription": "Free",
                                    "PlanExpiryDate":"",
                                    "PlanStartDate": "",
                                    "stripeCustomerId": "",
                                    "uid": user.uid]) { (error) in
                                                    if error != nil {
                                                        print("error for creating database  :\(error!.localizedDescription)")
                                                    }
                                                    else {
                    
                                                        print("Data base Created ")
                                                    }
                                }
                                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                                self.navigationController?.pushViewController(secondViewController, animated: true)
                
                }
            }
        }
    }
}
