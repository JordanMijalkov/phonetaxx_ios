//
//  AccountSettingViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class AccountSettingViewController: UIViewController {

    
    @IBOutlet weak var freeCallCountLbl: UILabel!
    @IBOutlet weak var monthlyBillLbl: UILabel!
    @IBOutlet weak var accountSettingView: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var accountDetailView: UIView!
    @IBOutlet weak var subscriptionDetailView: UIView!
    @IBOutlet weak var personaLizationView: UIView!
    let db = Firestore.firestore()
    var callLogDelete = false
    var contactDelete = false
    var callCategoryDelete = false
    var UserEmail = ""
    var Password = ""
    var freeCallCount = 15
    override func viewDidLoad() {
        super.viewDidLoad()

        accountSettingView.layer.cornerRadius = 30
        accountSettingView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        accountSettingView.layer.masksToBounds = false
        accountSettingView.layer.backgroundColor = UIColor.white.cgColor
        accountSettingView.layer.shadowColor = UIColor.lightGray.cgColor
        accountSettingView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        accountSettingView.layer.shadowOpacity = 0.5

    
        accountDetailView.layer.masksToBounds = false
        accountDetailView.layer.cornerRadius = 20
        accountDetailView.layer.shadowRadius = 4.0
        accountDetailView.layer.shadowColor = UIColor.lightGray.cgColor
        accountDetailView.layer.shadowOffset = .zero
        accountDetailView.layer.shadowOpacity = 0.4
        
        subscriptionDetailView.layer.masksToBounds = false
        subscriptionDetailView.layer.cornerRadius = 20
        subscriptionDetailView.layer.shadowRadius = 20
        subscriptionDetailView.layer.shadowColor = UIColor.lightGray.cgColor
        subscriptionDetailView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        subscriptionDetailView.layer.shadowOpacity = 0.4
        
        personaLizationView.layer.masksToBounds = false
        personaLizationView.layer.cornerRadius = 20
        personaLizationView.layer.shadowRadius = 20
        personaLizationView.layer.shadowColor = UIColor.lightGray.cgColor
        personaLizationView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        personaLizationView.layer.shadowOpacity = 0.4
        fetchUserDetail()
        fetchCallCount()
    }
    func fetchCallCount(){
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
            self.freeCallCount = 15
            if let e = error {
                print("error is \(e)")
            }else {
                if let snapshotDocuments = DocumentSnapshot?.documents{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        self.freeCallCount = self.freeCallCount - 1
                        
                    }
                    DispatchQueue.main.async {
                        print("call Count ...\(self.freeCallCount)")
                        self.freeCallCountLbl.text = "\(self.freeCallCount) Calls remaining"
                    }
                }
            }
        }
    }
    func fetchUserDetail(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        print("user detail is ", data)
                        if let email = data["email"] as? String,
                           let mothlyBillAmount  = data["mothlyBillAmount"] as? String{
                            print("email is ", email)
                            self.emailLbl.text = email
                            self.UserEmail = email
                            self.monthlyBillLbl.text = "$\(mothlyBillAmount)"
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }

    @IBAction func notificationButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func frequentNumberButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FrequentNumberViewController") as! FrequentNumberViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
  
    @IBAction func monthlyPhoneBillButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MonthlyPhoneBillViewController") as! MonthlyPhoneBillViewController
        secondViewController.modalPresentationStyle = .overFullScreen
        self.present(secondViewController, animated: true, completion: nil)
    }
    @IBAction func privacyBtnTapped(_ sender: UIButton) {
        //https://www.phonetaxx.com/privacy
        //https://firebasestorage.googleapis.com/v0/b/phonetaxx-8e8d7.appspot.com/o/terms_of_service_updated.html?alt=media
        if let url = NSURL(string: "https://www.phonetaxx.com/privacy"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    @IBAction func threeMenuButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subscriptionBtnTapped(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @IBAction func logOutBtn(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        var refreshAlert = UIAlertController(title: "Alert", message: "Are you sure you want to LogOut ?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
          print("Handle Ok logic here")
            do {
              try firebaseAuth.signOut()
                print("User LogOut ")
                userDefaults.removeObject(forKey: "isLoggedIn")
                userDefaults.removeObject(forKey: "current_userUid")
                userDefaults.removeObject(forKey: "monthlyBill")
               // navigationController?.popToRootViewController(animated: true)
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                 let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                 let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "SignINViewController") as! SignINViewController
                 navigationController.viewControllers = [rootViewController]
                 appDelegate.window!.rootViewController = navigationController
                 appDelegate.window!.makeKeyAndVisible()
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
            
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle Cancel Logic here")
          }))

        present(refreshAlert, animated: true, completion: nil)
       
    }
    
    func deleteCallCategoryField(){
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid in load msg for delete user ", CurrentUserUid)
        
// remove all Call Log
        db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").addSnapshotListener{ (DocumentSnapshot, error) in
                if let e = error {
                    print("error is \(e)")
                }else {
                    if let snapshotDocuments = DocumentSnapshot?.documents{
                        for doc in snapshotDocuments {
                            print("\(doc.documentID) => \(doc.data())")
                            self.db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").document(doc.documentID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    self.callCategoryDelete = true
                                    print("Document of CONTACTS successfully removed!")
                                }
                            }
                        }
                        
                    }
                }
        }
        
        
    }
    func deleteCallLog(){
        
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid in load msg for delete user ", CurrentUserUid)
        
// remove all Call Log
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
                if let e = error {
                    print("error is \(e)")
                }else {
                    if let snapshotDocuments = DocumentSnapshot?.documents{
                        for doc in snapshotDocuments {
                            print("\(doc.documentID) => \(doc.data())")
                            self.db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").document(doc.documentID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    self.callLogDelete = true
                                    print("Document of CONTACTS successfully removed!")
                                }
                            }
                        }
                        
                    }
                }
        }
        
    }
    func deleteContactsFromDatabase() {
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
               print("CurrentUserUid in load msg for delete user ", CurrentUserUid)
               
       // remove all Contacts
               db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").addSnapshotListener{ (DocumentSnapshot, error) in
                       if let e = error {
                           print("error is \(e)")
                       }else {
                           if let snapshotDocuments = DocumentSnapshot?.documents{
                               for doc in snapshotDocuments {
                                   print("\(doc.documentID) => \(doc.data())")
                                   self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").document(doc.documentID).delete() { err in
                                       if let err = err {
                                           print("Error removing document: \(err)")
                                       } else {
                                        self.contactDelete = true
                                           print("Document of CONTACTS successfully removed!")
                                       }
                                   }
                               }
                               
                           }
                       }
               }
    }
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        
       
        var refreshAlert = UIAlertController(title: "Alert", message: "Are you sure you want to Delete your Account ?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
          print("Handle Ok logic here")
            self.deleteContactsFromDatabase()
            self.deleteCallLog()
            self.deleteCallCategoryField()
            
//delete the database entris
                        
//                self.db.collection("USERS").document(CurrentUserUid).delete() { err in  // delete usernode
//                            if let err = err {
//                                    print("Error removing document: \(err)")
//                            } else {
//                                    print("Document successfully removed!")
//
//                            }
//                        }
            
// re auth the user
            
            
//            print("email is \(self.UserEmail) and password \(self.Password)")
//            let user = Auth.auth().currentUser
//                    var credential: AuthCredential = EmailAuthProvider.credential(withEmail:           self.UserEmail, password: self.Password)
//            user?.reauthenticate(with: credential) {  result ,error  in
//              if  error != nil {
//                // An error happened.
//                print("An error happened.",error?.localizedDescription)
//
//              } else {
//                print("User re-authenticated.")
//                // User re-authenticated.
//              }
//            }
            
// delete the user from  firebase
            let user = Auth.auth().currentUser
                user?.delete { error in
                  if let error = error {
                    // An error happened.
                    print("wrror ",error.localizedDescription)
                    self.view.makeToast("Please Logout your account and SignIn Again for this operation.", duration: 2.0, position: .center)
                  } else {
                    // Account deleted.
                    print("Account deleted", user?.uid)
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                     let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                     let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                     let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "SignINViewController") as! SignINViewController
                     navigationController.viewControllers = [rootViewController]
                     appDelegate.window!.rootViewController = navigationController
                     appDelegate.window!.makeKeyAndVisible()
                  }
                }
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle Cancel Logic here")
          }))

        present(refreshAlert, animated: true, completion: nil)
        
    }
    
}
