//
//  ThreeMenuViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import FirebaseFirestore
class ThreeMenuViewController: UIViewController {

   
    @IBOutlet weak var FreeCallCountLbl: UILabel!
    @IBOutlet weak var unlimitedCallsView: UIView!
    @IBOutlet weak var UserEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var isComeFromCallHostory = false
    var freeCallCount = 15
    let db = Firestore.firestore()
    //MARK: Private Properties
    fileprivate let animator = Animator()
    
    //MARK: Internal Properties
    var transitionType : TransitionType = .pushFromLeft//.pushFromBottom
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userImage.clipsToBounds = true
        unlimitedCallsView.layer.masksToBounds = false
        unlimitedCallsView.layer.cornerRadius = 25
        unlimitedCallsView.layer.shadowRadius = 25
        unlimitedCallsView.layer.shadowColor = UIColor.lightGray.cgColor
        unlimitedCallsView.layer.shadowOffset = .zero
        unlimitedCallsView.layer.shadowOpacity = 0.4
        fetchUserDetail()
        fetchCallCount()
    }
    override func viewWillAppear(_ animated: Bool) {
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
                        self.FreeCallCountLbl.text = "\(self.freeCallCount) calls left"
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
                        if let email  = data["email"] as? String ,
                           let profileUrl  = data["profileUrl"] as? String ,
                           let name  = data["fullname"] as? String {
                            self.UserEmail.text = email
                            self.userName.text = name
                            print("image Url is ", profileUrl)
                            self.userImage.sd_setImage(with: URL(string: profileUrl), placeholderImage: UIImage(named: "splash.png"))
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    @IBAction func homeButton(_ sender: Any) {
        if isComeFromCallHostory{
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
            
        } else{
            self.navigationController?.popViewController(animated: true)
        }
        

    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
       
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @IBAction func backBtnTapeed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func subscriptionBtnPressed(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
       
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @IBAction func uncategorizedButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CallHistoryVC") as! CallHistoryVC
       
        self.navigationController?.pushViewController(secondViewController, animated: true)
       // self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func phoneUsageButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CallHistoryVC") as! CallHistoryVC
        secondViewController.ifComeforPUsge = true
        self.navigationController?.pushViewController(secondViewController, animated: true)
       // self.navigationController?.popViewController(animated: true)CallHistoryVC
    }
    
    @IBAction func monthSummariesButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MonthlySummariesViewController") as! MonthlySummariesViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func accountSettingsButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AccountSettingViewController") as! AccountSettingViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)    }
    
    @IBAction func helpSupportButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    
}
