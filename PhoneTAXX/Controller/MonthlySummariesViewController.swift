//
//  MonthlySummariesViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import Charts
import FirebaseFirestore
public var monthValue = ""
public var freeCallCount = 0
class MonthlySummariesViewController: UIViewController {

    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var monthlySummeriesView: UIView!
    @IBOutlet weak var totalCallLbl: UILabel!
    @IBOutlet weak var selectedMonthDownView: UIView!
    @IBOutlet weak var monthlyPhoneCallsAndPayCompleteView: UIView!
    @IBOutlet weak var pieChartINBusinessPersonalAndUncategorizedView: PieChartView!
    
    @IBOutlet weak var calenderMonthLbl: UILabel!
    @IBOutlet weak var goToPhoneUsageButton: UIButton!
    @IBOutlet weak var viewEditAllCallsButton: UIButton!
    let db = Firestore.firestore()
    var call_LogArr : [Call_LogData] = []
    var pCallCount = 0
    var bSCallCount = 0
    var uCallCount = 0
    var pCallPercent = 0.0
    var bCallPercent = 0.0
    var uCallPercent = 200.0
    var totalCall = 0
    var mothlyBill = 0.0
    var businessTalkTime = 0
    var minTalktemp = 0
    @IBOutlet weak var completeLbl: UILabel!
    @IBOutlet weak var potentialLbl: UILabel!
    @IBOutlet weak var monthlBillLbl: UILabel!
    @IBOutlet weak var mbLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        UiDesign()
        loadCallLogDetail()
        fetchUserDetail()
        monthValue = getCurrentMonth()
        monthLbl.text = monthValue
        calenderMonthLbl.text = monthValue
        NotificationCenter.default.addObserver(self, selector: #selector(self.MoveToReviewController(notification:)), name: Notification.Name("updateMonthValue"), object: nil)
    }
    @objc func MoveToReviewController(notification: Notification) {
        print("updateMonthValue",monthValue)
        monthLbl.text = monthValue
        calenderMonthLbl.text = monthValue
        loadCallLogDetail()
        
    }
    func fetchUserDetail(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let mothlyBillAmount  = data["mothlyBillAmount"] as? String {
                            self.monthlBillLbl.text = "$\(mothlyBillAmount)"
                            self.mbLabel.text = "$\(mothlyBillAmount)"
                            monthlyBill = Float(mothlyBillAmount) ?? 0.0
                            self.potentialLbl.text = "$\(Float(mothlyBillAmount)!) Potential"
                            let bexpense = UserDefaults.standard.float(forKey: "businessExpense") ?? 0.0
                            let complete = Int(Float(bexpense * 100)/Float(mothlyBillAmount)!)
                            print("complete percentage is ",complete)
                            self.completeLbl.text = "\(complete)% Complete"
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    
    @IBAction func openCalenderBtn(_ sender: UIButton) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowCalenderVC") as! ShowCalenderVC
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: false, completion: nil)
    }
    @IBAction func threeMenuButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewAllCallLogBtn(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @IBAction func gotoPhoneUsage(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CallHistoryVC") as! CallHistoryVC
        secondViewController.ifComeFromMS = true
        secondViewController.ifComeforPUsge = true
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }

    func loadCallLogDetail(){
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid in load msg R", CurrentUserUid)
        db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
            
                self.call_LogArr = []
                self.pCallCount = 0
                self.bSCallCount = 0
                self.uCallCount = 0
                self.totalCall = 0
                self.bCallPercent = 0
                self.uCallPercent = 0
                self.pCallPercent = 0
                self.businessTalkTime = 0
                self.minTalktemp = 0
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
                                     let duration = callObj.callDurationInSecond
                                    let d =  Int(duration!) ?? 0
                                    self.minTalktemp = self.minTalktemp + d
                                    let month = monthValue
                                    if callObj.callMonth == month{
                                        self.totalCall = self.totalCall + 1
                                        if callObj.callCategory == "0"{
                                        // uncategory
                                            self.uCallCount = self.uCallCount + 1
                                        }else if callObj.callCategory == "1"{
                                        //personal
                                            self.pCallCount = self.pCallCount + 1
                                        }else if callObj.callCategory == "2"{
                                        //business
                                            self.bSCallCount = self.bSCallCount + 1
                                            let durationCount = callObj.callDurationInSecond
                                            let d =  Int(duration!)
                                            self.businessTalkTime = self.businessTalkTime + d!
                                            print("businessTalkTime Talktime ",self.businessTalkTime)
                                        }
                                    }
                            }
                            print("total calls are , ",self.uCallCount,self.pCallCount,self.bSCallCount)
                            DispatchQueue.main.async {
                                self.totalCallLbl.text = "\(self.totalCall) Phone Calls"
                                
                                let pPercent = (Float(self.pCallCount)/Float(self.totalCall))*200
                                self.pCallPercent = Double(pPercent)
                                let bPercent = (Float(self.bSCallCount)/Float(self.totalCall))*200
                                self.bCallPercent = Double(bPercent)
                                let uPercent = (Float(self.uCallCount)/Float(self.totalCall))*200
                                self.uCallPercent = Double(uPercent)
                                let min = (Float(self.minTalktemp) / 60)
                                let totalbMin = (Float(self.businessTalkTime)/60)
                                print("totalbMin", totalbMin)
                                let bexpense = (totalbMin/Float(min))*Float(monthlyBill)
                                 print("bexpense complete ", bexpense)
                                print("monthlyBill", monthlyBill)
                                let complete = Int(Float(bexpense * 100)/Float(monthlyBill))
                                print("complete percentage is complete ",complete)
                                self.completeLbl.text = "\(complete)% Complete"
                                self.pieChartInMiddleView()
                            }
                            
                            //print("items are, ", self.call_LogArr)
                        }
                    }
                }
           }
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
}
//MARK: - PieChat and Ui Work

extension MonthlySummariesViewController {
    func UiDesign(){
        monthlySummeriesView.layer.cornerRadius = 25
        monthlySummeriesView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        monthlySummeriesView.layer.masksToBounds = false
        monthlySummeriesView.layer.backgroundColor = UIColor.white.cgColor
        monthlySummeriesView.layer.shadowColor = UIColor.lightGray.cgColor
        monthlySummeriesView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        monthlySummeriesView.layer.shadowOpacity = 0.5
       
        
        selectedMonthDownView.layer.masksToBounds = false
        selectedMonthDownView.layer.cornerRadius = 20
        selectedMonthDownView.layer.shadowRadius = 4.0
        selectedMonthDownView.layer.shadowColor = UIColor.lightGray.cgColor
        selectedMonthDownView.layer.shadowOffset = .zero
        selectedMonthDownView.layer.shadowOpacity = 0.4
        
        monthlyPhoneCallsAndPayCompleteView.layer.masksToBounds = false
        monthlyPhoneCallsAndPayCompleteView.layer.cornerRadius = 20
        monthlyPhoneCallsAndPayCompleteView.layer.shadowRadius = 4.0
        monthlyPhoneCallsAndPayCompleteView.layer.shadowColor = UIColor.lightGray.cgColor
        monthlyPhoneCallsAndPayCompleteView.layer.shadowOffset = .zero
        monthlyPhoneCallsAndPayCompleteView.layer.shadowOpacity = 0.4
        
        goToPhoneUsageButton.layer.cornerRadius = goToPhoneUsageButton.bounds.height / 2
        goToPhoneUsageButton.layer.shadowRadius = goToPhoneUsageButton.bounds.height / 2
        goToPhoneUsageButton.layer.shadowColor = UIColor.lightGray.cgColor
        
        
        viewEditAllCallsButton.layer.cornerRadius = viewEditAllCallsButton.bounds.height / 2
        viewEditAllCallsButton.layer.shadowRadius = viewEditAllCallsButton.bounds.height / 2
        viewEditAllCallsButton.layer.shadowColor = UIColor.lightGray.cgColor
    
    }
    func  pieChartInMiddleView() {
        
        pieChartINBusinessPersonalAndUncategorizedView.chartDescription?.enabled = false
        //MARK:- SET FONT ---DETAIL LABEL INSIDE CHART
        pieChartINBusinessPersonalAndUncategorizedView.drawHoleEnabled = false
        pieChartINBusinessPersonalAndUncategorizedView.chartDescription = nil
    

       pieChartINBusinessPersonalAndUncategorizedView.centerText = "Pie Chart"
        pieChartINBusinessPersonalAndUncategorizedView.usePercentValuesEnabled = true
        pieChartINBusinessPersonalAndUncategorizedView.setExtraOffsets(left: -10, top: -10, right: -10, bottom: -10)
        
        pieChartINBusinessPersonalAndUncategorizedView.contentMode = .scaleAspectFill
        pieChartINBusinessPersonalAndUncategorizedView.drawHoleEnabled = true //This pie is hollow
                pieChartINBusinessPersonalAndUncategorizedView.holeRadiusPercent = 0.382 //Hollow radius golden ratio
                pieChartINBusinessPersonalAndUncategorizedView.holeColor = UIColor.white //The hollow color is set to white
                pieChartINBusinessPersonalAndUncategorizedView.transparentCircleRadiusPercent = 0 //translucent hollow radius
        
                pieChartINBusinessPersonalAndUncategorizedView.drawCenterTextEnabled = true //Show center text
                pieChartINBusinessPersonalAndUncategorizedView.centerText = "pie chart" //Set the center text, you can also set the rich text `centerAttributedText`
     
     
        
        pieChartINBusinessPersonalAndUncategorizedView.rotationAngle = 0
        pieChartINBusinessPersonalAndUncategorizedView.rotationEnabled = false
        pieChartINBusinessPersonalAndUncategorizedView.isUserInteractionEnabled = false
       
        
        //MARK:- SET FONT ---DETAIL LABEL
        pieChartINBusinessPersonalAndUncategorizedView.legend.font = UIFont.systemFont(ofSize: 15)  // font size of lbl
        
        pieChartINBusinessPersonalAndUncategorizedView.legend.enabled = true
        pieChartINBusinessPersonalAndUncategorizedView.legend.horizontalAlignment = .center
     
        
        pieChartINBusinessPersonalAndUncategorizedView.drawCenterTextEnabled = false
       
        pieChartINBusinessPersonalAndUncategorizedView.legend.formSize = 20  // image size
        pieChartINBusinessPersonalAndUncategorizedView.legend.formToTextSpace = 8  // space between image and label
        pieChartINBusinessPersonalAndUncategorizedView.legend.xEntrySpace = 40  //
      
        
        
        
    //    pieChartINBusinessPersonalAndUncategorizedView.centerText = "No Data Available"
    //    pieChartINBusinessPersonalAndUncategorizedView.isUserInteractionEnabled = true

        
        
        let l = self.pieChartINBusinessPersonalAndUncategorizedView.legend
        _ = CGFloat.nan

        let firstLegend = LegendEntry.init(label: "\(bSCallCount) calls", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor(patternImage: UIImage(named: "businessicon")!))
        
        let secondLegend = LegendEntry.init(label: "\(pCallCount) calls", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor(patternImage: UIImage(named: "call detection")!))
        let thirdLegend = LegendEntry.init(label: "\(uCallCount) calls", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor(patternImage: UIImage(named: "uncategorized-1")!))

       let customLegendEntries = [firstLegend, secondLegend, thirdLegend]
        l.setCustom(entries: customLegendEntries)
        
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: bCallPercent, icon: NSUIImage(named: "businessimagewhite")))

        entries.append(PieChartDataEntry(value: pCallPercent , icon: NSUIImage(named: "personimagewhite")))
        entries.append(PieChartDataEntry(value: uCallPercent, icon: NSUIImage(named: "Uncategorized")))
        
        let dataSet = PieChartDataSet(entries: entries)
        
        
        let c1 = NSUIColor(displayP3Red: 24/255, green: 68/255, blue: 168/255, alpha: 2)
        let c2 = NSUIColor(displayP3Red: 24/255, green: 140/255, blue: 164/255, alpha: 2)
        let c3 = NSUIColor(displayP3Red: 158/255, green: 158/255, blue: 158/255, alpha: 2)
        
        
         dataSet.colors = [c1, c2, c3]
         dataSet.drawValuesEnabled = false
        pieChartINBusinessPersonalAndUncategorizedView.data = PieChartData(dataSet: dataSet)
        
    }
}
