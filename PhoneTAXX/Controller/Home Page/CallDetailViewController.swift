//
//  CallDetailViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import FirebaseFirestore
class CallDetailViewController: UIViewController {

    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var businessLbl: UILabel!
    @IBOutlet weak var personalLbl: UILabel!
    @IBOutlet weak var personalImage: UIImageView!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var uncategoryView: UIView!
    @IBOutlet weak var callerDateLbl: UILabel!
    @IBOutlet weak var uncategoryLBL: UILabel!
    @IBOutlet weak var callerNumLbl: UILabel!
    @IBOutlet weak var callDurationLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var callerNameLbl: UILabel!
    @IBOutlet weak var callDetailView: UIView!
    let db = Firestore.firestore()
    var ref2: DocumentReference? = nil
    var callerName = ""
    var callerPhNum = ""
    var callduration = ""
    var callTime = ""
    var categoryType = "0"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        callDetailView.layer.masksToBounds = false
        callDetailView.layer.cornerRadius = 20
        callDetailView.layer.shadowRadius = 4.0
        callDetailView.layer.shadowColor = UIColor.lightGray.cgColor
        callDetailView.layer.shadowOffset = .zero
        callDetailView.layer.shadowOpacity = 0.4
        self.saveBtn.layer.cornerRadius = saveBtn.bounds.height/2
        self.saveBtn.clipsToBounds = true
        self.uncategoryView.layer.cornerRadius = uncategoryView.bounds.height/2
        self.businessView.layer.cornerRadius = businessView.bounds.height/2
        self.personalView.layer.cornerRadius = personalView.bounds.height/2
        self.callerNameLbl.text = callerName
        self.callerNumLbl.text = callerPhNum
        self.callDurationLbl.text = callduration
        self.callerDateLbl.text = callTime
        if categoryType == "0"{
            print("UNCATEGORIZED")
            uncategoryView.backgroundColor = UIColor(hexString: "#1844A3")
            personalView.backgroundColor = UIColor(hexString: "#DEE6FB")
            businessView.backgroundColor = UIColor(hexString: "#DEE6FB")
            uncategoryLBL.textColor = UIColor.white
            personalLbl.textColor = UIColor(hexString: "#1844A3")
            personalImage.image = UIImage(named: "ic_record_voice_over_24px")
            businessLbl.textColor = UIColor(hexString: "#1844A3")
            businessImage.image = UIImage(named: "businessicon")
        }else if categoryType == "1"{
            print("PERSONAL")
            uncategoryView.backgroundColor = UIColor(hexString: "#DEE6FB")
            personalView.backgroundColor = UIColor(hexString: "#1844A3")
            businessView.backgroundColor = UIColor(hexString: "#DEE6FB")
            uncategoryLBL.textColor = UIColor(hexString: "#1844A3")
            personalLbl.textColor = UIColor.white
            personalImage.image = UIImage(named: "personimagewhite")
            businessLbl.textColor = UIColor(hexString: "#1844A3")
            businessImage.image = UIImage(named: "businessicon")
        }else {
            print("BUSINESS")
            uncategoryView.backgroundColor = UIColor(hexString: "#DEE6FB")
            personalView.backgroundColor = UIColor(hexString: "#DEE6FB")
            businessView.backgroundColor = UIColor(hexString: "#1844A3")
            uncategoryLBL.textColor = UIColor(hexString: "#1844A3")
            personalLbl.textColor = UIColor(hexString: "#1844A3")
            personalImage.image = UIImage(named: "ic_record_voice_over_24px")
            businessLbl.textColor = UIColor.white
            businessImage.image = UIImage(named: "businessimagewhite")
        }
        
        
    }
    
    @IBAction func businessBtnTapped(_ sender: UIButton) {
        categoryType = "2"
        uncategoryView.backgroundColor = UIColor(hexString: "#DEE6FB")
        personalView.backgroundColor = UIColor(hexString: "#DEE6FB")
        businessView.backgroundColor = UIColor(hexString: "#1844A3")
        uncategoryLBL.textColor = UIColor(hexString: "#1844A3")
        personalLbl.textColor = UIColor(hexString: "#1844A3")
        personalImage.image = UIImage(named: "ic_record_voice_over_24px")
        businessLbl.textColor = UIColor.white
        businessImage.image = UIImage(named: "businessimagewhite")
    }
    @IBAction func personalBtnTapped(_ sender: UIButton) {
        categoryType = "1"
        uncategoryView.backgroundColor = UIColor(hexString: "#DEE6FB")
        personalView.backgroundColor = UIColor(hexString: "#1844A3")
        businessView.backgroundColor = UIColor(hexString: "#DEE6FB")
        uncategoryLBL.textColor = UIColor(hexString: "#1844A3")
        personalLbl.textColor = UIColor.white
        personalImage.image = UIImage(named: "personimagewhite")
        businessLbl.textColor = UIColor(hexString: "#1844A3")
        businessImage.image = UIImage(named: "businessicon")
    }
    @IBAction func uncategoryBtnTapped(_ sender: UIButton) {
        categoryType = "0"
        uncategoryView.backgroundColor = UIColor(hexString: "#1844A3")
        personalView.backgroundColor = UIColor(hexString: "#DEE6FB")
        businessView.backgroundColor = UIColor(hexString: "#DEE6FB")
        uncategoryLBL.textColor = UIColor.white
        personalLbl.textColor = UIColor(hexString: "#1844A3")
        personalImage.image = UIImage(named: "ic_record_voice_over_24px")
        businessLbl.textColor = UIColor(hexString: "#1844A3")
        businessImage.image = UIImage(named: "businessicon")
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSaveBtn(_ sender: UIButton) {
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid")!
                print("CurrentUserUid in load msg R", CurrentUserUid)
        let timeStamp = Int(NSDate().timeIntervalSince1970)
//  update CallCategory in CallCategory table
        
     db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").whereField("phoneNumber", isEqualTo: callerPhNum).getDocuments { (result, error) in
        if error == nil{
            for document in result!.documents{
                print("item found in CALL_CATEGORY")
                document.reference.setData(["callCategory": self.categoryType] , merge: true)
            }
        }
    }
// update call category in  Call Logs  Table
        
    db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").whereField("phoneNumber", isEqualTo: callerPhNum).getDocuments { (result, error) in
           if error == nil{
               for document in result!.documents{
                print("item found in CALL_LOGS",document.reference.documentID)
                   document.reference.setData(["callCategory": self.categoryType] , merge: true)
               }
           }
       }

db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phonenumber", isEqualTo: callerPhNum).getDocuments { (result, error) in
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
//                            self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phoneNumber", isEqualTo: self.callerPhNum).getDocuments { (result, error) in
//                                   if error == nil{
//                                       for document in result!.documents{
//                                        print("item found",document.reference.documentID)
//                                           document.reference.setData(["callCategory": self.categoryType] , merge: true)
//                                       }
//                                   }
//                               }
                        }
                    }
                } else{
                    print("no not exist ")
// add contact to frequent data
                    self.ref2 = self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").addDocument(data:
                                 ["phonenumber": self.callerPhNum,
                                  "name" : self.callerPhNum,
                                  "businessname" : "",
                                  "ein": "",
                                  "naicscode": "",
                                  "location":"",
                                  "userUuid": CurrentUserUid,
                                  "category": self.categoryType,
                                  "createdAt":"\(timeStamp)",
                                  "uuId": self.ref2?.documentID]){ (error) in
                            if error != nil {
                                print("Error while entering CONTACTS is ",error?.localizedDescription)
                                 
                            }else {                                                        self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS")
                                .whereField("createdAt", isEqualTo: "\(timeStamp)")
                                .getDocuments { (result, error) in
                                  if error == nil{
                                       for document in result!.documents{
                                           document.reference.setData(["uuId": self.ref2!.documentID] , merge: true)
                                       }
                                         self.view.makeToast("Contact Saved", duration: 2.0, position: .center)
                                    }
                               }

                        }
                    }
                }
            }else{print("errror while checking ph no is ", error?.localizedDescription)}
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
// Add document to the Contact table
// ref2 = db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").addDocument(data:
//                                ["phonenumber": callerPhNum,
//                                 "name" : callerPhNum,
//                                 "businessname" : "",
//                                 "ein": "",
//                                 "naicscode": "",
//                                 "location":"",
//                                 "userUuid": CurrentUserUid,
//                                 "category": categoryType,
//                                 "createdAt":"\(timeStamp)",
//                                 "uuId": self.ref2?.documentID]){ (error) in
//                                    if error != nil {
//                                        print("Error while entering CallLog is ",error?.localizedDescription)
//                                    }else {
//
//                                        self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("createdAt", isEqualTo: "\(timeStamp)").getDocuments { (result, error) in
//                                            if error == nil{
//                                                for document in result!.documents{
//                                                    document.reference.setData(["uuId": self.ref2!.documentID] , merge: true)
//                                                }
//                                            }
//                                        }
//
//                                    }
//                    }
        
