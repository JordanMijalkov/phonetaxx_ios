//
//  HomeViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 09/04/21.
//

import UIKit
import FirebaseFirestore
public var monthlyBill:Float = 0.0
class CallhistoryTVCell : UITableViewCell{
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var callTimeLbl: UILabel!
    @IBOutlet weak var callDurationLbl: UILabel!
   
    @IBOutlet weak var callerNumberLbl: UILabel!
    @IBOutlet weak var callername: UILabel!
    @IBOutlet weak var callImage: UIImageView!
    
    
    func getTimeOfCall(timeStamp: String ) -> String {
        let unixTimestamp = "\(timeStamp)"
        print("unixTimestamp",unixTimestamp)//"\(1622138536)"
        let ddate = Date(timeIntervalSince1970: TimeInterval(unixTimestamp)!)
        print("date from timestamp is ",ddate )
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: ddate)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EE HH:mm a"
        let date: NSDate? = dateFormatterGet.date(from: dateString) as NSDate?
         let currentdate = dateFormatterPrint.string(from: date! as Date)
            print(currentdate)
        return currentdate
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = (seconds % 3600) % 60
      return   String(format: "%02d:%02d:%02d", h, m, s) //(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    override  func awakeFromNib() {
        categoryLbl.isHidden = true
        categoryImg.isHidden = true
    }
}

class HomeViewController: UIViewController {
  
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var uncategorizedDescriptionLBL: UILabel!
    @IBOutlet weak var personalusageLbl: UILabel!
    @IBOutlet weak var businessExpenssLbl: UILabel!
    @IBOutlet weak var businessUsageDescriptionLbl: UILabel!
    @IBOutlet weak var minuteCountLbl: UILabel!
    @IBOutlet weak var callCountLbl: UILabel!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var businessCallImage: UIImageView!
    @IBOutlet weak var allCallLBL: UILabel!
    @IBOutlet weak var personalCALLVIEW: UIView!
    @IBOutlet weak var businessUsageImage: UIImageView!
    @IBOutlet weak var businessUsgaeLbl: UILabel!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var BUSINESSCALLVIEW: UIView!
    @IBOutlet weak var personalUSAGEIMAGE: UIImageView!
    @IBOutlet weak var personalCallImage: UIImageView!
    @IBOutlet weak var personalUsageLBL: UILabel!
    @IBOutlet weak var uncategoryCallImage: UIImageView!
    @IBOutlet weak var uncategoryCallCountLbl: UILabel!
    @IBOutlet weak var screenTimeLBL: UILabel!
    @IBOutlet weak var todayHomeView: UIView!
    @IBOutlet weak var allPersonalAndBusinessView: UIView!
    @IBOutlet weak var allCallDetailView: UIView!
    @IBOutlet weak var personalCallDetailView: UIView!
    @IBOutlet weak var businessCallDetailView: UIView!
    @IBOutlet weak var callHistoryTablveView: UITableView!
    @IBOutlet weak var businessUsageView: UIView!
    @IBOutlet weak var personalUsageView: UIView!
    @IBOutlet weak var uncategorizedCallView: UIView!
    @IBOutlet weak var screenTimeView: UIView!
    @IBOutlet weak var callTableView: UIView!
    
    @IBOutlet weak var viewFortable: UIView!
    
    @IBOutlet weak var recentCallsLabel: UILabel!
    
    
    var uidforUser = ""
    let db = Firestore.firestore()
    var call_LogArr : [Call_LogData] = []
    var Call_LogDataModel: Call_LogDataModel?
    var callCountTemp = 0
    var minTalktemp = 0
    var personalTalkTime = 0
    var businessTalkTime = 0
    var uncategoryTalkTime = 0
    var pUsage = 0
    var bUsage = 0
    var pCallCount = 0
    var bCallCount = 0
    var uCallCount = 0
    var timeSlotLbl = "Today"
    var daySelection = "0"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        self.navigationController?.navigationBar.isHidden=true
        self.todayLbl.text = timeSlotLbl
        print("timeSlotLbl",timeSlotLbl)
        print("screen time on home tab is ", screenTimeCount)
        screenTimeLBL.text = "\(screenTimeCount) min"
        monthlyBill = UserDefaults.standard.float(forKey: "monthlyBill")
        print("monthlyBill",monthlyBill)
        if monthlyBill == 0 {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MonthlyPhoneBillViewController") as! MonthlyPhoneBillViewController
            secondViewController.modalPresentationStyle = .overFullScreen
            self.present(secondViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        addShadowField()
        monthlyBill = UserDefaults.standard.float(forKey: "monthlyBill")
        loadCallLogDetail()
        fetchMyDetail()
        self.personalCALLVIEW.isHidden = true
        self.BUSINESSCALLVIEW.isHidden = true
        self.todayLbl.text = timeSlotLbl
        screenTimeLBL.text = "\(screenTimeCount) min"
        print("timeSlotLbl",timeSlotLbl)
        NotificationCenter.default.addObserver(self, selector: #selector(self.MoveToReviewController(notification:)), name: Notification.Name("changeSortTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeScreenTimeMethod(notification:)), name: Notification.Name("changeScreenTime"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeMonthlyBill(notification:)), name: Notification.Name("updateMonthlyBill"), object: nil)
       // screenTimeLBL.text = "\(screenTimeCount)"
       
    }
    
    @objc func changeMonthlyBill(notification: Notification) {
        monthlyBill = UserDefaults.standard.float(forKey: "monthlyBill")
        loadCallLogDetail()
    }
    @objc func changeScreenTimeMethod(notification: Notification) {
        print("screen time on home tab is ", screenTimeCount)
        screenTimeLBL.text = "\(screenTimeCount) min"
    }
    @objc func MoveToReviewController(notification: Notification) {
          
        if sortData.instance.sortType == 0 {
            //TODAY
            self.todayLbl.text = "Today"
            daySelection = "0"
            loadCallLogDetail()
        }
        else if sortData.instance.sortType == 1 {
//            WEEKLY
            self.todayLbl.text = "Weekly"
            daySelection = "1"
            loadCallLogDetail()
        }
        else {
//            MONTHLY
            self.todayLbl.text = "Monthly"
            daySelection = "2"
            loadCallLogDetail()
        }
    }
    func checkSubscriptionPlan(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let Subscription  = data["Subscription"] as? String,
                           let planExpiryDate  = data["PlanExpiryDate"] as? String,
                           let planStartDate  = data["PlanStartDate"] as? String{
                            if Subscription == "Free"{
                                if self.callCountTemp < 15 {
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MakeCallVC") as! MakeCallVC
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                                } else {
                                    self.view.makeToast("Please Subscribe First" ,duration:3.0, position:.center)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        // Change `2.0` to the desired number of seconds.
                                       // Code you want to be delayed
                                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                                        self.navigationController?.pushViewController(secondViewController, animated: true)
                                    }
                                    
                                }
                                        
                            } else if Subscription == "Monthly" {
                                if planExpiryDate > self.getCurrentDate(){
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MakeCallVC") as! MakeCallVC
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                                } else{
                                    self.view.makeToast("Please Subscribe First" ,duration:3.0, position:.center)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        // Change `2.0` to the desired number of seconds.
                                       // Code you want to be delayed
                                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                                        self.navigationController?.pushViewController(secondViewController, animated: true)
                                    }
                                }
                               
                            }else if Subscription == "Yearly" {
                                if planExpiryDate > self.getCurrentDate(){
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MakeCallVC") as! MakeCallVC
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                                } else{
                                    self.view.makeToast("Please Subscribe First" ,duration:3.0, position:.center)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        // Change `2.0` to the desired number of seconds.
                                       // Code you want to be delayed
                                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                                        self.navigationController?.pushViewController(secondViewController, animated: true)
                                    }
                                }
                                
                            } else{
                                self.view.makeToast("Please Subscribe First" ,duration:3.0, position:.center)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
                                   // Code you want to be delayed
                                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                                    self.navigationController?.pushViewController(secondViewController, animated: true)
                                }                          }
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    func movetomakeCall(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let phonenumber  = data["phonenumber"] as? String {
                            if phonenumber == ""{
                                self.view.makeToast("Please update your profile to use this operation",duration:3.0, position:.center)
                                
                            } else {
                                // check subscription plan first here
                                 
                                self.checkSubscriptionPlan()
                            }
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    @IBAction func callBtn(_ sender: UIButton) {
        // navigate to call screen
              movetomakeCall()
      
    }
    @IBAction func buttonTimeSelection(_ sender: Any) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TimeSelectionPopUpViewController") as! TimeSelectionPopUpViewController
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: false, completion: nil)
        
    }
    
    @IBAction func addNumberButton(_ sender: Any) {
        print("move to add Contact ")
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let phonenumber  = data["phonenumber"] as? String {
                            if phonenumber == ""{
                                self.view.makeToast("Please update your profile to use this operation",duration:3.0, position:.center)
                            } else {
                                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNumberViewController") as! AddNumberViewController
                                self.navigationController?.pushViewController(secondViewController, animated: true)
                            }
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
       
    
    }
    
    @IBAction func viewAllCallLog(_ sender: UIButton) {
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewAllCallLogVC") as! ViewAllCallLogVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    @IBAction func sendGmailButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SendReportViewController") as! SendReportViewController
        secondViewController.modalPresentationStyle = .overFullScreen
        
        self.present(secondViewController, animated: false, completion: nil)
     //   self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    @IBAction func allCallBtnTapped(_ sender: UIButton) {
        loadCallLogDetail()
        self.allCallDetailView.backgroundColor = UIColor(hexString: "#1844A3")
        self.allCallLBL.textColor = UIColor.white
        self.personalCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.personalCallImage.isHidden = false
        self.personalCallImage.image = UIImage(named: "ic_record_voice_over_24px")
        self.businessCallImage.isHidden = false
        self.businessCallImage.image = UIImage(named: "businessicon")
        self.businessCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.personalCALLVIEW.isHidden = true
        self.BUSINESSCALLVIEW.isHidden = true
        self.personalusageLbl.text = "PERSONAL USAGE"
        self.businessUsageDescriptionLbl.text = "BUSINESS USAGE"
        self.uncategorizedDescriptionLBL.text = "UNCATEGORIZED CALLS"
        self.uncategoryCallImage.image = UIImage(named: "uncategorized call")
        self.businessUsageImage.image = UIImage(named: "bussiness1")
        self.personalUSAGEIMAGE.image = UIImage(named: "person1")
        self.personalUsageLBL.text = "\(self.pUsage) %"
        self.businessUsgaeLbl.text = "\(self.bUsage) %"
        self.uncategoryCallCountLbl.text = "\(self.uCallCount)"
        self.recentCallsLabel.text = "RECENT CALLS"
      
    }
    @IBAction func businessCallBtn(_ sender: UIButton) {
        fetchCallForB()
        self.allCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.allCallLBL.textColor = UIColor(hexString: "#1844A3")
        self.personalCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.personalCallImage.isHidden = false
        self.personalCallImage.image = UIImage(named: "ic_record_voice_over_24px")
        self.businessCallImage.isHidden = true
       // self.businessCallDetailView.backgroundColor = UIColor(hexString: "#1844A3")
        self.personalCALLVIEW.isHidden = true
        self.BUSINESSCALLVIEW.isHidden = false
        self.personalusageLbl.text = "TALK TIME"
        self.businessUsageDescriptionLbl.text = "BUSINESS CALLS"
        self.uncategorizedDescriptionLBL.text = "BUSINESS USAGE"
        self.uncategoryCallImage.image = UIImage(named: "Usagep") 
        self.businessUsageImage.image = UIImage(named: "bUsage")
        self.personalUSAGEIMAGE.image = UIImage(named: "callUsage")
        let talktime = self.businessTalkTime/60
        self.personalUsageLBL.text = "\(talktime) mins"
        self.uncategoryCallCountLbl.text = "\(self.bUsage) %"
        self.businessUsgaeLbl.text = "\(self.bCallCount)"
        self.recentCallsLabel.text = "RECENT BUSINESS CALLS"
    }
    @IBAction func personalCallBtn(_ sender: UIButton) {
        fetchCallForP()
        self.allCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.allCallLBL.textColor = UIColor(hexString: "#1844A3")
        //self.personalCallDetailView.backgroundColor = UIColor(hexString: "#1844A3")
        self.personalCallImage.isHidden = true
        self.businessCallImage.isHidden = false
        self.businessCallImage.image = UIImage(named: "businessicon")
        self.businessCallDetailView.backgroundColor = UIColor(hexString: "#DEE6FB")
        self.personalCALLVIEW.isHidden = false
        self.BUSINESSCALLVIEW.isHidden = true
        self.personalusageLbl.text = "TALK TIME"
        self.businessUsageDescriptionLbl.text = "PERSONAL CALLS"
        self.uncategorizedDescriptionLBL.text = "PERSONAL USAGE"
        self.uncategoryCallImage.image = UIImage(named: "Usagep")
        self.businessUsageImage.image = UIImage(named: "bUsage")
        self.personalUSAGEIMAGE.image = UIImage(named: "callUsage")
        let talktime = self.personalTalkTime/60
        self.personalUsageLBL.text = "\(talktime) mins"
        self.uncategoryCallCountLbl.text = "\(self.pUsage) %"
        self.businessUsgaeLbl.text = "\(self.pCallCount)"
        self.recentCallsLabel.text = "RECENT PERSONAL CALLS"
    }
    @IBAction func threeMenuButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ThreeMenuViewController") as! ThreeMenuViewController
        //secondController.transitionType = .pushFromLeft
        self.navigationController?.pushViewController(secondViewController, animated: true)
        //self.present(secondViewController, animated: true, completion: nil)
        
    }
    //MARK: - Call Methods Work
    
    func fetchMyDetail(){
        db.collection("USERS")
            .whereField("uid", isEqualTo: CurrentUserUid)
            .getDocuments{ (result, error) in
            if error == nil{
                for document in result!.documents{
                    let data = document.data()
                    if let phnum  = data["phonenumber"] as? String ,
                        let name = data["fullname"] as? String{
                        myName = name
                        myPhoneNum = phnum
                    }
                }
            } else {
                print("error")
            }
        }
    }
    
    
    
    func fetchCallForP(){
       
         CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
         print("CurrentUserUid in load msg R", CurrentUserUid)
         db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
             
                 self.call_LogArr = []
                 if let e = error {
                     print("error is \(e)")
                 }else {
                     if let snapshotDocuments = DocumentSnapshot?.documents{
                         for doc in snapshotDocuments {
                             print("\(doc.documentID) => \(doc.data())")
                             let data = doc.data()
                           
                             if let callCategory = data ["callCategory"] as? String,
                             let callDate = data ["callDate"] as? String,
                             let callDateTimeLocal = data ["callDateTimeLocal"] as? String,
                             let callDateTimeUTC = data ["callDateTimeUTC"] as? String,
                             let callDurationInSecond = data ["callDurationInSecond"] as? String,
                             let callMonth = data ["callMonth"] as? String,
                             let callType = data ["callType"] as? String,
                             let callWeek = data ["callWeek"] as? String,
                             let callYear = data ["callYear"] as? String,
                             let createdAt = data ["createdAt"] as? String,
                             let deleted = data ["deleted"] as? String,
                             let name = data ["name"] as? String,
                             let phoneNumber = data ["phoneNumber"] as? String,
                             let userUuid = data ["userUuid"] as? String,
                             let uuId = data ["uuId"] as? String
 //                            let docID = doc.documentID as? String
                             {
                                 let callObj = Call_LogData(callCategory: callCategory, callDate: callDate, callDateTimeLocal: callDateTimeLocal, callDateTimeUTC: callDateTimeUTC, callDurationInSecond: callDurationInSecond, callMonth: callMonth, callType: callType, callWeek: callWeek, callYear: callYear, createdAt: createdAt, deleted: deleted, name: name, phoneNumber: phoneNumber, userUuid: userUuid, uuId: uuId)
                                    if callObj.callCategory == "1"{
                                        self.call_LogArr.append(callObj)
                                        self.call_LogArr.sort(by:{   $0.createdAt! >    $1.createdAt! })
                                    }
                             }
                             DispatchQueue.main.async {
                                 self.callHistoryTablveView.reloadData()
                             }
                         }  // end of for loop
                     }  // end of if let for snapshot
                 }  // end of else block when no error found
         }// end of db Querry
    }
    
    func fetchCallForB(){
       
         CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
         print("CurrentUserUid in load msg R", CurrentUserUid)
         db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
             
                 self.call_LogArr = []
                 if let e = error {
                     print("error is \(e)")
                 }else {
                     if let snapshotDocuments = DocumentSnapshot?.documents{
                         for doc in snapshotDocuments {
                             print("\(doc.documentID) => \(doc.data())")
                             let data = doc.data()
                           
                             if let callCategory = data ["callCategory"] as? String,
                             let callDate = data ["callDate"] as? String,
                             let callDateTimeLocal = data ["callDateTimeLocal"] as? String,
                             let callDateTimeUTC = data ["callDateTimeUTC"] as? String,
                             let callDurationInSecond = data ["callDurationInSecond"] as? String,
                             let callMonth = data ["callMonth"] as? String,
                             let callType = data ["callType"] as? String,
                             let callWeek = data ["callWeek"] as? String,
                             let callYear = data ["callYear"] as? String,
                             let createdAt = data ["createdAt"] as? String,
                             let deleted = data ["deleted"] as? String,
                             let name = data ["name"] as? String,
                             let phoneNumber = data ["phoneNumber"] as? String,
                             let userUuid = data ["userUuid"] as? String,
                             let uuId = data ["uuId"] as? String
 //                            let docID = doc.documentID as? String
                             {
                                 let callObj = Call_LogData(callCategory: callCategory, callDate: callDate, callDateTimeLocal: callDateTimeLocal, callDateTimeUTC: callDateTimeUTC, callDurationInSecond: callDurationInSecond, callMonth: callMonth, callType: callType, callWeek: callWeek, callYear: callYear, createdAt: createdAt, deleted: deleted, name: name, phoneNumber: phoneNumber, userUuid: userUuid, uuId: uuId)
                                    if callObj.callCategory == "2"{
                                        self.call_LogArr.append(callObj)
                                        self.call_LogArr.sort(by:{   $0.createdAt! >    $1.createdAt! })
                                    }
                             }
                            
                             DispatchQueue.main.async {
                                 self.callHistoryTablveView.reloadData()
                                
                             }
                            
                             
                         }  // end of for loop
                         
                     }  // end of if let for snapshot
                 }  // end of else block when no error found
         }// end of db Querry
        
    }
    
    
    
    func loadCallLogDetail(){
       // db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").addDocument
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        monthlyBill = UserDefaults.standard.float(forKey: "monthlyBill") ?? 0.0
        print("CurrentUserUid in load msg R", CurrentUserUid)
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
            var todayCall = 0
            var todayMin = 0
            var Min = 0
                self.call_LogArr = []
                self.callCountTemp = 0
                self.minTalktemp = 0
                self.personalTalkTime = 0
                self.businessTalkTime = 0
                self.uncategoryTalkTime = 0
                self.pUsage = 0
                self.bUsage = 0
                self.pCallCount = 0
                self.bCallCount = 0
                self.uCallCount = 0
              
                if let e = error {
                    print("error is \(e)")
                }else {
                    if let snapshotDocuments = DocumentSnapshot?.documents{
                        for doc in snapshotDocuments {
                            print("\(doc.documentID) => \(doc.data())")
                            let data = doc.data()
                          
                            if let callCategory = data ["callCategory"] as? String,
                            let callDate = data ["callDate"] as? String,
                            let callDateTimeLocal = data ["callDateTimeLocal"] as? String,
                            let callDateTimeUTC = data ["callDateTimeUTC"] as? String,
                            let callDurationInSecond = data ["callDurationInSecond"] as? String,
                            let callMonth = data ["callMonth"] as? String,
                            let callType = data ["callType"] as? String,
                            let callWeek = data ["callWeek"] as? String,
                            let callYear = data ["callYear"] as? String,
                            let createdAt = data ["createdAt"] as? String,
                            let deleted = data ["deleted"] as? String,
                            let name = data ["name"] as? String,
                            let phoneNumber = data ["phoneNumber"] as? String,
                            let userUuid = data ["userUuid"] as? String,
                            let uuId = data ["uuId"] as? String
//                            let docID = doc.documentID as? String
                            {
                                let callObj = Call_LogData(callCategory: callCategory, callDate: callDate, callDateTimeLocal: callDateTimeLocal, callDateTimeUTC: callDateTimeUTC, callDurationInSecond: callDurationInSecond, callMonth: callMonth, callType: callType, callWeek: callWeek, callYear: callYear, createdAt: createdAt, deleted: deleted, name: name, phoneNumber: phoneNumber, userUuid: userUuid, uuId: uuId)
                                
                                   self.call_LogArr.append(callObj)
                                  self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })
                                print("items are, ", self.call_LogArr)
                                  self.callCountTemp = self.callCountTemp + 1
                               
                                let today = self.getCurrentDate()
                                let month = self.getCurrentMonth()
                                let week = self.getCurrentWeek()
                                if self.daySelection == "0"{
                        //today call count and today call min
                                    if callObj.callDate == today {
                                        todayCall = todayCall + 1
                                        let duration = callObj.callDurationInSecond
                                        let d =  Int(duration!) ?? 0
                                        Min = Min + d
                                        todayMin = Int((Float(Min) / 60))
                                        print("total min = ", todayMin)
                                        print("total min todayMin + d = ", Min)
                                        print("duration ", d)
                                    }
                                    
                                } else  if self.daySelection == "1"{
                                    if callObj.callWeek == week {
                                        todayCall = todayCall + 1
                                        let duration = callObj.callDurationInSecond
                                        let d =  Int(duration!) ?? 0
                                        Min = Min + d
                                        todayMin = Int((Float(Min) / 60))
                                        print("total min = ", todayMin)
                                        print("total min todayMin + d = ", Min)
                                        print("duration ", d)
                                    }
                                    
                                } else  if self.daySelection == "2"{
                                    if callObj.callMonth == month {
                                        todayCall = todayCall + 1
                                        let duration = callObj.callDurationInSecond
                                        let d =  Int(duration!) ?? 0
                                        Min = Min + d
                                        todayMin = Int((Float(Min) / 60))
                                        print("total min = ", todayMin)
                                        print("total min todayMin + d = ", Min)
                                        print("duration ", d)
                                    }
                                    
                                }
                                
                                
                                
                                
                                  let duration = callObj.callDurationInSecond
                                  let d =  Int(duration!) ?? 0
                                 self.minTalktemp = self.minTalktemp + d
                                  if callObj.callCategory == "0"{
                                    // call count for uncategorized
                                    self.uCallCount = self.uCallCount + 1
                                    let durationCount = callObj.callDurationInSecond
                                    let d =  Int(duration!) ?? 0
                                    self.uncategoryTalkTime = self.uncategoryTalkTime + d
                                    print("uncategoryTalkTime Talktime ",self.uncategoryTalkTime)
                                } else if callObj.callCategory == "1"{
                                    self.pCallCount = self.pCallCount + 1
                                    let durationCount = callObj.callDurationInSecond
                                    let d =  Int(duration!) ?? 0
                                    self.personalTalkTime = self.personalTalkTime + d
                                    print("personal Talktime ",self.personalTalkTime)
                                    
                                }else if callObj.callCategory == "2"{
                                    self.bCallCount = self.bCallCount + 1
                                    let durationCount = callObj.callDurationInSecond
                                    let d =  Int(duration!)
                                    self.businessTalkTime = self.businessTalkTime + d!
                                    print("businessTalkTime Talktime ",self.businessTalkTime)
                                    
                                }
                            }
                            print("Total CallCount is ",self.callCountTemp)
                            self.callHistoryTablveView.delegate = self
                            self.callHistoryTablveView.dataSource = self
                            DispatchQueue.main.async {
                                self.callHistoryTablveView.reloadData()
                                let min = (Float(self.minTalktemp) / 60)
                                print("total min of all call ",Float(min))
                                self.minuteCountLbl.text = "\(todayMin)"
                                self.callCountLbl.text = "\(todayCall)"
                                let totalpMin = Float((Float(self.personalTalkTime+self.uncategoryTalkTime)/60) )
                                print("totalpMin",totalpMin)
                                guard  let ppUsage:Float? = ((totalpMin/Float(min))*100)  else {return}
                                self.pUsage = Int(String(format: "%.0f", ppUsage!)) ?? 0
                                print("usage si ",self.pUsage)
                                let totalbMin = (Float(self.businessTalkTime)/60)
                                print("totalbMin", totalbMin)
                                guard  let bbUsage:Float? = ((totalbMin/Float(min))*100)  else {return}
                                self.bUsage = Int(String(format: "%.0f", bbUsage!)) ?? 0
                                guard  let bbExpese:Float? = ((totalbMin/Float(min))*Float(monthlyBill))  else {return}
                                
                                let bExpense = Int(String(format: "%.0f", bbExpese!)) ?? 0
                                print("bexpense ksdkl",bExpense)
                                UserDefaults.standard.set(bExpense, forKey: "businessExpense")
                                self.businessExpenssLbl.text = "$\(bExpense)"
                                self.personalUsageLBL.text = "\(self.pUsage) %"
                                self.businessUsgaeLbl.text = "\(self.bUsage) %"
                                self.uncategoryCallCountLbl.text = "\(self.uCallCount)"
                                
                            }
                           
                            
                        }
                        
                    }
                }
        }
    
    }
    func getCurrentDate() -> String{
        let ddate = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: ddate)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, MMMM dd, yyyy"
        let date: NSDate? = dateFormatterGet.date(from: dateString) as NSDate?
         let currentdate = dateFormatterPrint.string(from: date! as Date)
            print(currentdate)
        return currentdate
    }
    func getCurrentMonth() -> String{
        let ddate = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: ddate)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM yyyy"

        let date: NSDate? = dateFormatterGet.date(from: dateString) as NSDate?

         let currentdate = dateFormatterPrint.string(from: date! as Date)
            print(currentdate)
        return currentdate
    }
    func getCurrentWeek() -> String {
        let startWeek = Date().startOfWeek
        let endWeek = Date().endOfWeek
        print(startWeek!)
        print(endWeek!)
        var dateFormat1 = DateFormatter()
        dateFormat1.dateFormat = "MMMM dd"
        let startWeek2 = dateFormat1.string(from: startWeek!)
        var dateFormat12 = DateFormatter()
        dateFormat12.dateFormat = "MMMM dd, yyyy"
        let endWeek2 = dateFormat12.string(from: endWeek!)
        print(startWeek2)
        print(endWeek2)
        let currentWeek = startWeek2 + " - " + endWeek2
        print(currentWeek)
        return currentWeek
    }
}

//MARK: - CallHistoryTableView Work
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if call_LogArr.count == 0 {
            callTableView.isHidden = true
            noRecordLbl.isHidden = false
        } else {
            callTableView.isHidden = false
            noRecordLbl.isHidden = true
        }
        if call_LogArr.count>4{
            return 4
        }  else {
            return call_LogArr.count
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallhistoryTVCell", for: indexPath) as! CallhistoryTVCell
        let indx = call_LogArr[indexPath.row]
        cell.callerNumberLbl.text = indx.phoneNumber
        cell.callername.text = indx.name
        if indx.callType == "INCOMING"{
            cell.callImage.image = UIImage(named: "IncomingCall")
        }else if indx.callType == "OUTGOING"{
            cell.callImage.image = UIImage(named: "call outgoging")
        }
        let timeStamp = indx.createdAt!
        let callTime = cell.getTimeOfCall(timeStamp: timeStamp)
        cell.callTimeLbl.text = callTime
        let totalSec = Int(indx.callDurationInSecond!)!
        let timeofcall = cell.secondsToHoursMinutesSeconds(seconds: totalSec)
        cell.callDurationLbl.text = timeofcall
// show category image and label
        if indx.callCategory == "0"{
            cell.categoryLbl.isHidden = false
            cell.categoryImg.isHidden = true
        } else if indx.callCategory == "2"{
            cell.categoryLbl.isHidden = true
            cell.categoryImg.isHidden = false
            cell.categoryImg.image = UIImage(named: "businessicon")
        } else if indx.callCategory == "1"{
            cell.categoryLbl.isHidden = true
            cell.categoryImg.isHidden = false
            cell.categoryImg.image = UIImage(named: "ic_record_voice_over_24px")
        }else {
            cell.categoryImg.isHidden = true
            cell.categoryLbl.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallhistoryTVCell", for: indexPath) as! CallhistoryTVCell
        let indx = call_LogArr[indexPath.row]
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "CallDetailViewController") as! CallDetailViewController
        nextVC.modalPresentationStyle = .overFullScreen
        let totalSec = Int(indx.callDurationInSecond!)!
        let timeofcall = cell.secondsToHoursMinutesSeconds(seconds: totalSec)
        nextVC.callduration = timeofcall
        let timeStamp = indx.createdAt!
        let callTime = cell.getTimeOfCall(timeStamp: timeStamp)
        nextVC.callTime = callTime
        nextVC.callerName = indx.name ?? ""
        nextVC.callerPhNum = indx.phoneNumber ?? ""
        nextVC.categoryType = indx.callCategory ?? ""
        self.present(nextVC, animated: false, completion: nil)
    }
    
}







//MARK: - UIDesign Work

extension HomeViewController {
    
    func addShadowField(){
        
        todayHomeView.layer.cornerRadius = 25
        todayHomeView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        todayHomeView.layer.masksToBounds = false
        todayHomeView.layer.backgroundColor = UIColor.white.cgColor
        todayHomeView.layer.shadowColor = UIColor.lightGray.cgColor
        todayHomeView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        todayHomeView.layer.shadowOpacity = 0.5
    
        
        allPersonalAndBusinessView.layer.masksToBounds = true
        allPersonalAndBusinessView.layer.cornerRadius = 25
        allPersonalAndBusinessView.layer.shadowRadius = 25
        allPersonalAndBusinessView.layer.shadowColor = UIColor.lightGray.cgColor
        allPersonalAndBusinessView.layer.shadowOffset = .zero
        allPersonalAndBusinessView.layer.shadowOpacity = 0.4
       
        allCallDetailView.layer.cornerRadius = allCallDetailView.frame.height / 2
        allCallDetailView.layer.masksToBounds = true
        allCallDetailView.backgroundColor = UIColor(hexString: "#1844A3")
     
        personalCallDetailView.layer.cornerRadius = personalCallDetailView.frame.height / 2
        personalCallDetailView.layer.masksToBounds = true
        
        businessCallDetailView.layer.cornerRadius = businessCallDetailView.frame.height / 2
        businessCallDetailView.layer.masksToBounds = true
        
//        settings.style.buttonBarBackgroundColor = .white
//        settings.style.buttonBarItemBackgroundColor = .white
//        settings.style.selectedBarBackgroundColor = UIColor.appThemeColor
//        settings.style.buttonBarItemFont = UIFont(name:"Muli-SemiBold_2",size:16) ?? .boldSystemFont(ofSize: 16)
//        settings.style.selectedBarHeight = 2.0
//        settings.style.buttonBarMinimumLineSpacing = 0
//        settings.style.buttonBarItemTitleColor = .black
//        settings.style.buttonBarItemsShouldFillAvailableWidth = true
//        settings.style.buttonBarLeftContentInset = 0
//        settings.style.buttonBarRightContentInset = 0
//
//        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//            guard changeCurrentIndex == true else { return }
//            oldCell?.label.textColor = .black
//            newCell?.label.textColor = UIColor.appThemeColor
        
        
        businessUsageView.layer.masksToBounds = false
        businessUsageView.layer.cornerRadius = 10
        businessUsageView.layer.shadowRadius = 4.0
        businessUsageView.layer.shadowColor = UIColor.lightGray.cgColor
        businessUsageView.layer.shadowOffset = .zero
        businessUsageView.layer.shadowOpacity = 0.4
        
        viewFortable.layer.masksToBounds = false
        viewFortable.layer.cornerRadius = 10
        viewFortable.layer.shadowRadius = 4.0
        viewFortable.layer.shadowColor = UIColor.lightGray.cgColor
        viewFortable.layer.shadowOffset = .zero
        viewFortable.layer.shadowOpacity = 0.4
        
        personalUsageView.layer.masksToBounds = false
        personalUsageView.layer.cornerRadius = 10
        personalUsageView.layer.shadowRadius = 4.0
        personalUsageView.layer.shadowColor = UIColor.lightGray.cgColor
        personalUsageView.layer.shadowOffset = .zero
        personalUsageView.layer.shadowOpacity = 0.4
        
        uncategorizedCallView.layer.masksToBounds = false
        uncategorizedCallView.layer.cornerRadius = 10
        uncategorizedCallView.layer.shadowRadius = 4.0
        uncategorizedCallView.layer.shadowColor = UIColor.lightGray.cgColor
        uncategorizedCallView.layer.shadowOffset = .zero
        uncategorizedCallView.layer.shadowOpacity = 0.4
        
        screenTimeView.layer.masksToBounds = false
        screenTimeView.layer.cornerRadius = 10
        screenTimeView.layer.shadowRadius = 4.0
        screenTimeView.layer.shadowColor = UIColor.lightGray.cgColor
        screenTimeView.layer.shadowOffset = .zero
        screenTimeView.layer.shadowOpacity = 0.4
        
        callTableView.layer.masksToBounds = true
        callTableView.layer.cornerRadius = 20
        callTableView.layer.shadowRadius = 4.0
        callTableView.layer.shadowColor = UIColor.lightGray.cgColor
        callTableView.layer.shadowOffset = .zero
        callTableView.layer.shadowOpacity = 0.4
        
        
    }
    
}

