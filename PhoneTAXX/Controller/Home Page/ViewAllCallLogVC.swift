//
//  ViellAllCallLogVC.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 03/06/21.
//

import UIKit
import FirebaseFirestore
class ViewAllCallHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var callDateLbl: UILabel!
    @IBOutlet weak var CallImage: UIImageView!
    @IBOutlet weak var callTimeLbl: UILabel!
    @IBOutlet weak var callDetailview: UIView!
    @IBOutlet weak var callerPhNumLbl: UILabel!
    @IBOutlet weak var callerNameLbl: UILabel!
  
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
    override func awakeFromNib() {
        dateLbl.visibility = .gone
        categoryLbl.isHidden = true
        categoryImg.isHidden = true
        callDetailview.layer.masksToBounds = false
        callDetailview.layer.cornerRadius = 10
        callDetailview.layer.shadowRadius = 4.0
        callDetailview.layer.shadowColor = UIColor.lightGray.cgColor
        callDetailview.layer.shadowOffset = .zero
        callDetailview.layer.shadowOpacity = 0.4
    }
}

class ViewAllCallLogVC: UIViewController {
    
    
    let db = Firestore.firestore()
    var call_LogArr : [Call_LogData] = []
    var call_LogArrBusiness : [Call_LogData] = []
    var ifComeforPUsge = false
    var ifpressPersonal = false
    var ifunPressed = false
    var pCallCount = 0
    var bSCallCount = 0
    var uCallCount = 0
    @IBOutlet weak var todayTopView: UIView!
    @IBOutlet weak var bCallCount: UILabel!
    @IBOutlet weak var noRecordLbl: UILabel!
    
    @IBOutlet weak var bCallLbl: UILabel!
    @IBOutlet weak var pCallLbl: UILabel!
    @IBOutlet weak var uncategoryCallView: UIView!
    @IBOutlet weak var pcallCountLbl: UILabel!
    @IBOutlet weak var pCallImage: UIImageView!
    @IBOutlet weak var uCallLbl: UILabel!
    @IBOutlet weak var uCallImage: UIImageView!
    @IBOutlet weak var uCallCountLbl: UILabel!
    @IBOutlet weak var bcallImage: UIImageView!
    @IBOutlet weak var personalCallView: UIView!
    @IBOutlet weak var businessCallView: UIView!
    @IBOutlet weak var pUsageLbl: UILabel!
    @IBOutlet weak var callSelectionView: UIView!
    @IBOutlet weak var monthlyBillLbl: UILabel!
    @IBOutlet weak var todayLabl: UILabel!
    @IBOutlet weak var callHistoryTableView: UITableView!
    var callDetailFor = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        todayTopView.layer.cornerRadius = 25
        todayTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        todayTopView.layer.masksToBounds = false
        todayTopView.layer.backgroundColor = UIColor.white.cgColor
        todayTopView.layer.shadowColor = UIColor.lightGray.cgColor
        todayTopView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        todayTopView.layer.shadowOpacity = 0.5
        
       
        self.businessCallView.layer.cornerRadius = 10
        self.personalCallView.layer.cornerRadius = 10
        self.uncategoryCallView.layer.cornerRadius = 10
        monthlyBill = UserDefaults.standard.float(forKey: "monthlyBill")
        print("monthlyBillfrom Defaults",monthlyBill)
        let mb = String(format: "%.2f", monthlyBill as! CVarArg)
        self.monthlyBillLbl.text = "$\(mb)"
        loadCallLogDetail()
        self.pUsageLbl.text = "Phone Usage"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MoveToReviewController(notification:)), name: Notification.Name("changeSortTitle"), object: nil)
    }
    @objc func MoveToReviewController(notification: Notification) {
          
        if sortData.instance.sortType == 0 {
            //TODAY
            self.todayLabl.text = "Today"
            callDetailFor = "0"
            if ifunPressed{
                loadCallLogDetailForUncategoryCall()
            } else {
                loadCallLogDetail()
            }
            
        }
        else if sortData.instance.sortType == 1 {
//            WEEKLY
            self.todayLabl.text = "Weekly"
            callDetailFor = "1"
            if ifunPressed{
                loadCallLogDetailForUncategoryCall()
            } else {
                loadCallLogDetail()
            }
        }
        else {
//            MONTHLY
            self.todayLabl.text = "Monthly"
            callDetailFor = "2"
            if ifunPressed{
                loadCallLogDetailForUncategoryCall()
            } else {
                loadCallLogDetail()
            }
        }
    }
    
    @IBAction func todayBtnTapped(_ sender: UIButton) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TimeSelectionPopUpViewController") as! TimeSelectionPopUpViewController
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: false, completion: nil)
    }
    @IBAction func threeMenuButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bCallBtnTapped(_ sender: UIButton) {
        ifpressPersonal = false
        ifunPressed = false
        loadCallLogDetail()
        bCallLbl.textColor = UIColor.white
        bCallCount.textColor = UIColor.white
        bcallImage.image = UIImage(named: "businessimagewhite")
        businessCallView.backgroundColor = UIColor(hexString: "#1844A3")
        
        pcallCountLbl.textColor = UIColor(hexString: "#1844A3")
        pCallLbl.textColor = UIColor(hexString: "#1844A3")
        pCallImage.image = UIImage(named: "ic_record_voice_over_24px")
        personalCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
        
        uCallLbl.textColor = UIColor(hexString: "#1844A3")
        uCallCountLbl.textColor = UIColor(hexString: "#1844A3")
        uCallImage.image = UIImage(named: "uncategoryBlue")
        uncategoryCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
    }
    @IBAction func pCallBtnTapped(_ sender: UIButton) {
        ifpressPersonal = true
        ifunPressed = false
        loadCallLogDetail()
        pcallCountLbl.textColor = UIColor.white
        pCallLbl.textColor = UIColor.white
        pCallImage.image = UIImage(named: "personimagewhite")
        personalCallView.backgroundColor = UIColor(hexString: "#1844A3")
        
        bCallLbl.textColor = UIColor(hexString: "#1844A3")
        bCallCount.textColor = UIColor(hexString: "#1844A3")
        bcallImage.image = UIImage(named: "businessicon")
        businessCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
        
        uCallLbl.textColor = UIColor(hexString: "#1844A3")
        uCallCountLbl.textColor = UIColor(hexString: "#1844A3")
        uCallImage.image = UIImage(named: "uncategoryBlue")
        uncategoryCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
        
    }
    @IBAction func uCallBtnTapped(_ sender: UIButton) {
        ifpressPersonal = false
        ifunPressed = true
        loadCallLogDetailForUncategoryCall()
        uCallLbl.textColor = UIColor.white
        uCallCountLbl.textColor = UIColor.white
        uCallImage.image = UIImage(named: "Uncategorized")
        uncategoryCallView.backgroundColor = UIColor(hexString: "#1844A3")
        
        pcallCountLbl.textColor = UIColor(hexString: "#1844A3")
        pCallLbl.textColor = UIColor(hexString: "#1844A3")
        pCallImage.image = UIImage(named: "ic_record_voice_over_24px")
        personalCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
        
        bCallLbl.textColor = UIColor(hexString: "#1844A3")
        bCallCount.textColor = UIColor(hexString: "#1844A3")
        bcallImage.image = UIImage(named: "businessicon")
        businessCallView.backgroundColor = UIColor(hexString: "#DEE6FB")
    }
    
    func loadCallLogDetail(){
       // db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").addDocument
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid in load msg R", CurrentUserUid)
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
            
                self.call_LogArr = []
            self.call_LogArrBusiness = []
            self.pCallCount = 0
            self.bSCallCount = 0
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
                                if callObj.callCategory == "1"{
                                    self.call_LogArr.append(callObj)
                                    self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })

                                    self.pCallCount = self.pCallCount + 1
                                 } else if callObj.callCategory == "2"{
                                    self.call_LogArrBusiness.append(callObj)
                                    self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//
                                    self.bSCallCount = self.bSCallCount + 1
                                } else {
                                    self.uCallCount = self.uCallCount + 1
                                }
                            }
                            print("items are,loadCallLogDetail ", self.call_LogArr)
                            self.callHistoryTableView.delegate = self
                            self.callHistoryTableView.dataSource = self
                            DispatchQueue.main.async {
                                self.pcallCountLbl.text = "\(self.pCallCount)"
                                self.bCallCount.text = "\(self.bSCallCount)"
                                self.uCallCountLbl.text = "\(self.uCallCount)"
                                
                                self.callHistoryTableView.reloadData()
                            }
                        }
                    }
                }
        }
    
    }
    
    func loadCallLogDetailForUncategoryCall(){
       // db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").addDocument
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid in load msg R", CurrentUserUid)
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
            
                self.call_LogArrBusiness = []
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
                                        if callObj.callCategory == "0"{
                                            self.call_LogArrBusiness.append(callObj)
                                            self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
                                                }
                                            }
                            }
                           // print("items are, ", self.call_LogArr)
                            self.callHistoryTableView.delegate = self
                            self.callHistoryTableView.dataSource = self
                            DispatchQueue.main.async {
                                self.callHistoryTableView.reloadData()
                            }
                           
                            
                        }
                        
                    }
                }
        }
    
    }



//MARK: - Table Work
extension ViewAllCallLogVC: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ifpressPersonal{
            if call_LogArr.count == 0 {
                callHistoryTableView.isHidden = true
                noRecordLbl.isHidden = false
            } else {
                callHistoryTableView.isHidden = false
                noRecordLbl.isHidden = true
            }
            return call_LogArr.count
        } else {
            if call_LogArrBusiness.count == 0 {
                callHistoryTableView.isHidden = true
                noRecordLbl.isHidden = false
            } else {
                callHistoryTableView.isHidden = false
                noRecordLbl.isHidden = true
            }
            return call_LogArrBusiness.count
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllCallHistoryTVCell", for: indexPath) as! ViewAllCallHistoryTVCell
        //var indx = call_LogArrBusiness[indexPath.row]
        if ifpressPersonal{
            let  indx = call_LogArr[indexPath.row]
            cell.callerPhNumLbl.text = indx.phoneNumber
            cell.callerNameLbl.text = indx.name
            if indx.callType == "INCOMING"{
                
                cell.CallImage.image = UIImage(named: "IncomingCall")
            }else if indx.callType == "OUTGOING"{
                cell.CallImage.image = UIImage(named: "call outgoging")
            }
            let timeStamp = indx.createdAt!
            let callTime = cell.getTimeOfCall(timeStamp: timeStamp)
            cell.callDateLbl.text = callTime
            let totalSec = Int(indx.callDurationInSecond!)!
            let timeofcall = cell.secondsToHoursMinutesSeconds(seconds: totalSec)
            cell.callTimeLbl.text = timeofcall
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
            
// Show day label according to filter
            if callDetailFor == "0"{
            // Call According to day
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callDate
                } else if call_LogArr[indexPath.row ].callDate != call_LogArr[indexPath.row - 1].callDate{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callDate
                } else {
                    cell.dateLbl.visibility = .gone
                }
                            
            } else if callDetailFor == "1"{
                // Call According to Week
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callWeek
                } else if call_LogArr[indexPath.row ].callWeek != call_LogArr[indexPath.row - 1].callWeek{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callWeek
                } else {
                    cell.dateLbl.visibility = .gone
                }
                            
            } else if callDetailFor == "2"{
                // Call According to  Month
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callMonth
                } else if call_LogArr[indexPath.row ].callMonth != call_LogArr[indexPath.row - 1].callMonth{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callMonth
                } else {
                    cell.dateLbl.visibility = .gone
                }
            }   
   // details of uncategorized or business Calls
            
        } else {
          let   indx = call_LogArrBusiness[indexPath.row]
            
            cell.callerPhNumLbl.text = indx.phoneNumber
            cell.callerNameLbl.text = indx.name
            if indx.callType == "INCOMING"{
                cell.CallImage.image = UIImage(named: "IncomingCall")
            }else if indx.callType == "OUTGOING"{
                cell.CallImage.image = UIImage(named: "call outgoging")
            }
            let timeStamp = indx.createdAt!
            let callTime = cell.getTimeOfCall(timeStamp: timeStamp)
            cell.callDateLbl.text = callTime
            let totalSec = Int(indx.callDurationInSecond!)!
            let timeofcall = cell.secondsToHoursMinutesSeconds(seconds: totalSec)
            cell.callTimeLbl.text = timeofcall
// Show day label according to filter
            if callDetailFor == "0"{
            // Call According to day
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callDate
                } else if call_LogArrBusiness[indexPath.row ].callDate != call_LogArrBusiness[indexPath.row - 1].callDate{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callDate
                } else {
                    cell.dateLbl.visibility = .gone
                }
            } else if callDetailFor == "1"{
            // Call According to Week
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callWeek
                } else if call_LogArrBusiness[indexPath.row ].callWeek != call_LogArrBusiness[indexPath.row - 1].callWeek{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callWeek
                } else {
                    cell.dateLbl.visibility = .gone
                }
                
            } else if callDetailFor == "2"{
            // Call According to  Month
                if indexPath.row == 0{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callMonth
                } else if call_LogArrBusiness[indexPath.row ].callMonth != call_LogArrBusiness[indexPath.row - 1].callMonth{
                    cell.dateLbl.visibility = .visible
                    cell.dateLbl.text = indx.callMonth
                } else {
                    cell.dateLbl.visibility = .gone
                }
            }
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
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllCallHistoryTVCell", for: indexPath) as! ViewAllCallHistoryTVCell
        if ifpressPersonal{
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
        }else {
            let indx = call_LogArrBusiness[indexPath.row]
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
}

//MARK: -  Date and Time Work
extension ViewAllCallLogVC{
    
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
   
    func getCurrentYear() -> String {
        let ddate = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: ddate)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy"

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













//if self.callDetailFor == "0"{
//                                                // today calls
//                                                    let today = self.getCurrentDate()
//
//                                                    self.call_LogArrBusiness.append(callObj)
//                                                    self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
////     once for testing                              if callObj.callDate == today{
////                                                        print("todays calls ")
////                                                        self.call_LogArrBusiness.append(callObj)
////                                                        self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
////                                                    }
//                                                }else if self.callDetailFor == "1"{
//                                                // weekly calls
//                                                    let week = self.getCurrentWeek()
//                                                    if callObj.callWeek == week{
//                                                        print("week calls ")
//
//                                                        self.call_LogArrBusiness.append(callObj)
//                                                        self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                                    }
//                                                }else if self.callDetailFor == "2" {
//                                                // monthly calls
//                                                    let month = self.getCurrentMonth()
//                                                    if callObj.callMonth == month {
//
//                                                        print("month calls ")
//                                                        self.call_LogArrBusiness.append(callObj)
//                                                        self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//   else {
//                                                    print("All Calls")
//                                                    self.tableHeaderLbl.isHidden = true
//                                                    self.call_LogArrBusiness.append(callObj)
//                                                    self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                                }                                                  }
//if self.callDetailFor == "0"{
//                                        // today Calls
//                                        let today = self.getCurrentDate()
//
//                                        self.call_LogArrBusiness.append(callObj)
//                                        self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
////                                        if callObj.callDate == today{
////                                            print("todays calls ")
////                                            self.call_LogArrBusiness.append(callObj)
////                                            self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
////                                        }
//
//                                    } else if self.callDetailFor == "1"{
//                                        // weekly calls
//                                            let week = self.getCurrentWeek()
//
//                                            if callObj.callWeek == week{
//                                                print("week calls ")
//                                                self.call_LogArrBusiness.append(callObj)
//                                                self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                            }
//
//                                    } else if self.callDetailFor == "2"{
//                                        // monthly calls
//                                            let month = self.getCurrentMonth()
//
//                                            if callObj.callMonth == month {
//                                                print("month calls ")
//                                                self.call_LogArrBusiness.append(callObj)
//                                                self.call_LogArrBusiness.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                            }
//                                    }
//                                    if self.callDetailFor == "0"{
//                                        // today Calls
//                                        let today = self.getCurrentDate()
//                                        self.call_LogArr.append(callObj)
//                                        self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })
////                                        if callObj.callDate == today{
////                                            print("todays calls ")
////                                            self.call_LogArr.append(callObj)
////                                            self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })
////                                        }
//
//                                    } else if self.callDetailFor == "1"{
//                                        // weekly calls
//                                            let week = self.getCurrentWeek()
//
//                                            if callObj.callWeek == week{
//                                                print("week calls ")
//                                                self.call_LogArr.append(callObj)
//                                                self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                            }
//                                    } else if self.callDetailFor == "2"{
//                                        // monthly calls
//                                            let month = self.getCurrentMonth()
//
//                                            if callObj.callMonth == month {
//                                                print("month calls ")
//                                                self.call_LogArr.append(callObj)
//                                                self.call_LogArr.sort(by:{   $0.createdAt! > $1.createdAt! })
//                                            }
//                                    }
