//
//  MakeCallVC.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 25/05/21.
//

import UIKit
import FirebaseFirestore
import  Contacts
class MakeCallVC: UIViewController {

    @IBOutlet weak var clrAllBtn: UIButton!
    @IBOutlet weak var makeCallBtn: UIButton!
    @IBOutlet weak var phNumTxtFeild: UITextField!
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    var ref2: DocumentReference? = nil
    var phnum = ""
    var callerName = ""
    var callduration = 0
    var contacts : [FetchedContact]? = []
    var CallCategory = "0"
    var CallCat = "0"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.phNumTxtFeild.isUserInteractionEnabled = false
        clrAllBtn.layer.cornerRadius = clrAllBtn.bounds.height / 2
        clrAllBtn.clipsToBounds = true
        makeCallBtn.layer.cornerRadius = makeCallBtn.bounds.height / 2
        makeCallBtn.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.MoveToReviewController(notification:)), name: Notification.Name("createCallEntry"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createEmptyCallEntry(notification:)), name: Notification.Name("createEmptyCallEntry"), object: nil)
       
        print("viewDidLoad ")
        fetchContacts()
    }
    @objc func createEmptyCallEntry(notification: Notification) {
        print("emptycall")
    }
    @objc func MoveToReviewController(notification: Notification) {
        callEntryForOutgoing()
        callEntryForIncoming()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear ")
        print("callduration is ",callDuration)
    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func makeCallAction(_ sender: UIButton) {
        if phNumTxtFeild.text != ""{
            if let url = URL(string: "tel://\(phNumTxtFeild.text!)"),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                print("Call initiated")
            }
            callOutGoing = true
            print("call Completed ")
        } else {
            self.view.makeToast("Please Dial any Number.", duration: 2.0, position: .center)
        }
    }
    func dataEntryForIncoming(category : String , uid : String){
        var numberType = "0"
        if category == "0"{
            numberType = "0"
        }else {
            numberType = "1"
        }
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let cDate = self.getCurrentDate()
        let cMonth = self.getCurrentMonth()
        let cYear = self.getCurrentYear()
        let cWeek = self.getCurrentWeek()
        let date = Date()
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let dSUTC = self.localToUTC(dateStr: dateString)   // convert current date from local to UTC
        let newDate = dateFormatter.date(from: dSUTC!)    // get date from date string
        let timeStampLTUTC = newDate!.timeIntervalSince1970   // create time stamp of utc time
        let realTStamp =  String(format: "%.0f", timeStampLTUTC)
        self.ref = self.db.collection("USERS").document(uid).collection("CALL_LOGS").addDocument(data:
                    ["callCategory": category,
                    "callDate" : cDate,
                    "callDateTimeLocal" : "\(timeStamp)",  //local time stamp
                    "callDateTimeUTC": realTStamp,  // utc time stamp
                    "callDurationInSecond": "\(callDuration)",
                    "callMonth": cMonth,
                    "callType": "INCOMING",
                    "callWeek": cWeek,
                    "callYear": cYear,
                    "createdAt":"\(timeStamp)" ,   // local time stamp
                    "deleted": "0",
                    "name": myName,
                    "phoneNumber": myPhoneNum,
                    "userUuid": uid,
                    "uuId": self.ref?.documentID]){ (error) in
                        if error != nil {
                            print("Error while entering CallLog is ",error?.localizedDescription)
                
                        }else {
                        print("Document added with ID: \(self.ref!.documentID)")
            self.db.collection("USERS").document(uid).collection("CALL_LOGS")
                .whereField("createdAt", isEqualTo: "\(timeStamp)")
                .getDocuments { (result, error) in
                    if error == nil{
                        for document in result!.documents{
                            document.reference.setData(["uuId": self.ref!.documentID] , merge: true)
                                    }
                                }
                            }
                        }
                    }
        
        
        
// database entry in CALL_CATEGORY Collection
            self.ref2 =  self.db.collection("USERS").document(uid).collection("CALL_CATEGORY").addDocument(data:
                                       ["callCategory": category, // 0 for uncategorized
                                        "numberType" : numberType,    // 0 for normal , 1 for frequent
                                        "phoneImage" : "",
                                        "phoneName": self.callerName,
                                        "phoneNumber": self.phNumTxtFeild.text!,
                                        "userUuid": uid,
                                        "uuId": self.ref2?.documentID]){ (error) in
                                            if error != nil {
                                                print("Error while entering CallLog is ",error?.localizedDescription)
                                            }else {
                                                self.db.collection("USERS").document(uid).collection("CALL_CATEGORY")
                                                    .document(self.ref2!.documentID)
                                                    .setData(["uuId": self.ref2!.documentID] , merge: true)
                                                }
                                      }
    }
    
    
    func callEntryForIncoming(){
        db.collection("USERS").whereField("phonenumber", isEqualTo: phNumTxtFeild.text).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    print("snapshotDocuments", snapshotDocuments)
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        print("data for incoming ",data)
                        if let uid  = data["uid"] as? String {
                            self.detectCallCategoryForIncoming(uid: uid)
                        }
                    }
                }
            }
        }
             
    }
//    func detectCallCategory(phnum : String)-> String{
//        //check if from database
//
//        var callCategory = "0"
//        print("CurrentUserUid", CurrentUserUid)
//        self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phonenumber", isEqualTo: phnum).getDocuments { (result, error) in
//            if error == nil{
//                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
//                    print("snapshotDocuments for detectCallCategory", snapshotDocuments)
//                    for doc in snapshotDocuments {
//                        let data = doc.data()
//                        print("data for detectCallCategory ",data)
//                        if let category  = data["category"] as? String {
//
//                            callCategory = category
//                            print("ph num already exist detectCallCategory  ", callCategory)
//
//
//                        }
//
//                    }
//
//                } else {
//                    callCategory = "0"
//                    print("no not exist detectCallCategory",self.CallCategory)
//                }
//
//            }else {
//                print("Error detectCallCategory")
//            }
//        }
//        print("callCategory", callCategory)
//        return callCategory
//    }
    func detectCallCategoryForIncoming(uid :String){
        //check if from database
        self.db.collection("USERS").document(uid).collection("CONTACTS").whereField("phonenumber", isEqualTo: myPhoneNum).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    print("snapshotDocuments for detectCallCategory", snapshotDocuments)
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        print("data for detectCallCategory ",data)
                        if let category  = data["category"] as? String {
                            print("ph num already exist detectCallCategory  ",category)
                            self.dataEntryForIncoming(category: category, uid: uid)
                           // self.CallCategory = category
                            
                        }
                    }
                } else {
                    //self.CallCategory = "0"
                    self.dataEntryForIncoming(category: "0", uid: uid)
                    print("no not exist detectCallCategory",self.CallCategory)
                }
            }else {
                print("Error detectCallCategory")
            }
        }
      
    }
    
    func callEntryForOutgoing(){
        
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        print("CurrentUserUid for out going ",CurrentUserUid)
//  database entry in CALL_LOGS Collection
                fetchNameFromFrequent(phoneNum: phNumTxtFeild.text!)
        }
    
    func DataEntryOutgoing(name: String , Category : String){
        var numberType = "0"
        if Category == "0"{
            numberType = "0"
        }else {
            numberType = "1"
        }
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let cDate = getCurrentDate()
        let cMonth = getCurrentMonth()
        let cYear = getCurrentYear()
        let cWeek = getCurrentWeek()
        let date = Date()
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let dSUTC = self.localToUTC(dateStr: dateString)   // convert current date from local to UTC
        let newDate = dateFormatter.date(from: dSUTC!)    // get date from date string
        let timeStampLTUTC = newDate!.timeIntervalSince1970   // create time stamp of utc time
        let realTStamp =  String(format: "%.0f", timeStampLTUTC)
        print("call Duration \(callduration)")
        ref = db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addDocument(data:
                                        ["callCategory": Category, // 0 for uncategorized call
                                         "callDate" : cDate,
                                         "callDateTimeLocal" : "\(timeStamp)",  //local time stamp
                                         "callDateTimeUTC": realTStamp,  // utc time stamp
                                         "callDurationInSecond": "\(callDuration)",
                                         "callMonth": cMonth,
                                         "callType": "OUTGOING",
                                         "callWeek": cWeek,
                                         "callYear": cYear,
                                         "createdAt":"\(timeStamp)" ,   // local time stamp
                                         "deleted": "0",
                                         "name": name,
                                         "phoneNumber": phNumTxtFeild.text!,
                                         "userUuid": CurrentUserUid,
                                         "uuId": self.ref?.documentID]){ (error) in
                                    if error != nil {
                                        print("Error while entering CallLog is ",error?.localizedDescription)
                
                                    }else {
                                        print("Document added with  ID for out going: \(self.ref!.documentID)")
                                        self.db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").whereField("createdAt", isEqualTo: "\(timeStamp)").getDocuments { (result, error) in
                                            if error == nil{
                                                for document in result!.documents{
                                                    document.reference.setData(["uuId": self.ref!.documentID] , merge: true)
                                                }
                                            }
                                        }
                                    }

                        }
        
// database entry in CALL_CATEGORY Collection
        
        
       ref2 =  db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").addDocument(data:
                                ["callCategory": CallCat, // 0 for uncategorized
                                "numberType" : numberType,    // 0 for normal , 1 for frequent
                                "phoneImage" : "",
                                "phoneName": callerName,
                                "phoneNumber": phNumTxtFeild.text!,
                                "userUuid": CurrentUserUid,
                                "uuId": self.ref2?.documentID]){ (error) in
                                    if error != nil {
                                        print("Error while entering CallLog is ",error?.localizedDescription)

                                    }else {
                                        self.db.collection("USERS").document(CurrentUserUid).collection("CALL_CATEGORY").document(self.ref2!.documentID).setData(["uuId": self.ref2!.documentID] , merge: true)
                                    }
                                }
    }
    
    
    
}
//MARK: - Contact fetching Work

extension MakeCallVC {
    
// Function te fetch name from DB
    func fetchNameFromDB(phoneNum : String){
        var fullNName = ""
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
        db.collection("USERS").whereField("phonenumber", isEqualTo: phoneNum).getDocuments { (result, error) in
            if error == nil{
                print("result", result)
                if let snapshotDocuments = result?.documents {
                    print("document i s", snapshotDocuments)
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let fullname  = data["fullname"] as? String{
                            fullNName = fullname
                            //self.callerName = fullname
                            self.DataEntryOutgoing(name: fullname, Category: "0")
                        }
                    }
                }
                if fullNName == "" {
                    print("fullNName" , fullNName)
                    self.fetchNameFromContact(phoneNum: self.phNumTxtFeild.text!)
                       }
            } else {
                print("fetchNameFromDB error ", error?.localizedDescription)
            }
        }
       
        
       // return fullNName ?? ""
    }
    
// Function te fetch name from Frequent Contact
    func fetchNameFromFrequent(phoneNum : String)  {
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
                print("CurrentUserUid in load msg R", CurrentUserUid)
        print("PhoneNumber ", phoneNum)
        var FullName = ""
        db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").whereField("phonenumber", isEqualTo: phoneNum).getDocuments{ (DocumentSnapshot, error) in
                        if let e = error {
                            print("error is \(e)")
                        }else {
                            if let snapshotDocuments = DocumentSnapshot?.documents{
                                print("document i s", snapshotDocuments)
                                for doc in snapshotDocuments {
                                    print("\(doc.documentID) => \(doc.data())")
                                    let data = doc.data()
                                    if let name = data ["name"] as? String,
                                    let category = data ["category"] as? String,
                                    let phonenumber = data ["phonenumber"] as? String
                                    {
                                        FullName = name
//                                        self.callerName = name
                                        self.CallCat = category
                                        print("callName = ", FullName)
                                        self.DataEntryOutgoing(name: name, Category: category)
                                    }
                                }
                            }
                            print("callerName,CallCat", FullName,self.CallCat)
                                    if FullName == "" {
                                        self.fetchNameFromDB(phoneNum: self.phNumTxtFeild.text!)
                                    }
                        }
                }
        
        //return (FullName,CallCat)
    }
// Function to fetch name from From phone contacts
    func fetchNameFromContact(phoneNum : String) {
       // chatUserArr.filter { $0.name!.localizedCaseInsensitiveContains(searchText) }
        
        let filterd =  contacts!.first(where: { $0.telephone == phoneNum })
        let name = filterd.map { $0.firstName }
        print("filter is ", filterd)
        print("name is ", name)
        self.DataEntryOutgoing(name: ((name) ?? "")!, Category: "0")
        //return ((name) ?? "")!
    }
    
// code to fetch all the contacts from phone
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.contacts?.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: String(contact.phoneNumbers.first?.value.stringValue.filter { !" \n\t-\r".contains($0) } ?? "")))
                        print("contacts are ", self.contacts)
                        
                    })
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    
}
//MARK: - Date and Time Work


extension MakeCallVC {
    
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
    
    func localToUTC(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
// Convert locat to UTC
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
             print("value from local to utc is ...", dateFormatter.string(from: date) )
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    
    func utcToLocal(dateStr: String) -> String? {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
           dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
           print("testing date ",dateStr)
        
           if let date = dateFormatter.date(from: dateStr) {
               dateFormatter.timeZone = TimeZone.current
               dateFormatter.dateFormat = "MM-dd-yyyy,hh:mm a"
            print("return value from utc is ",dateFormatter.string(from: date))
               return dateFormatter.string(from: date)
            
           }
           let dateFormatter2 = DateFormatter()
           dateFormatter2.dateFormat = "MM-dd-yyyy,hh:mm"
           dateFormatter2.timeZone = TimeZone(abbreviation: "UTC")
           print("testing date ",dateStr)
        
           if let date = dateFormatter2.date(from: dateStr) {
              dateFormatter2.timeZone = TimeZone.current
              dateFormatter2.dateFormat = "MM-dd-yyyy,hh:mm"
           print("return value from utc is ",dateFormatter2.string(from: date))
             return dateFormatter2.string(from: date)
         
          }
           return nil
       }
    
}




//MARK: - DialPad work

extension MakeCallVC {
    
    @IBAction func clearTextOneByOneAction(_ sender: UIButton) {
        phnum =  String(phnum.dropLast())
        phNumTxtFeild.text = phnum
        
    }
    
    
    @IBAction func clearAllAction(_ sender: UIButton) {
        self.phNumTxtFeild.text = ""
        phnum = ""
    }
    
    @IBAction func btnOnePressed(_ sender: UIButton) {
        phnum = phnum + "1"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnTwoPressed(_ sender: UIButton) {
        // 2
        phnum = phnum + "2"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnThreePressed(_ sender: UIButton) {
        //3
        phnum = phnum + "3"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnFourPressed(_ sender: UIButton) {
        // 4
        phnum = phnum + "4"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnFivePressed(_ sender: UIButton) {
        //5
        phnum = phnum + "5"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnSixPressed(_ sender: UIButton) {
        //6
        phnum = phnum + "6"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnSevenPressed(_ sender: UIButton) {
        //7
        phnum = phnum + "7"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnEightPressed(_ sender: UIButton) {
        // 8
        phnum = phnum + "8"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnNinePressed(_ sender: UIButton) {
        // 9
        phnum = phnum + "9"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnZeroPressed(_ sender: UIButton) {
        // 0
        phnum = phnum + "0"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnHashPressed(_ sender: UIButton) {
        // #
        phnum = phnum + "#"
        phNumTxtFeild.text = phnum
    }
    
    @IBAction func btnStarPressed(_ sender: UIButton) {
        // *
        phnum = phnum + "*"
        phNumTxtFeild.text = phnum
    }
}
