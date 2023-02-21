//
//  SendReportViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import FirebaseFirestore
import PDFKit



struct TableDataItem {
    var callCategory : String?
    var callDurationInSecond : String?
    var createdAt : String?
    var name : String?
    var phoneNumber : String?
    var sNo : String?
    var FilePath = ""
    init(sNo: String?, name: String?, phoneNumber: String?, callCategory: String?,createdAt : String?,callDurationInSecond:String? ) {
        self.name = name
        self.sNo = sNo
        self.phoneNumber = phoneNumber
        self.callCategory = callCategory
        self.callDurationInSecond = callDurationInSecond
        self.createdAt = createdAt
    }
}
class SendReportViewController: UIViewController {
    
    

    @IBOutlet weak var sendReportView: UIView!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var viewPDF: UIView!
    @IBOutlet weak var viewCSV: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    var db = Firestore.firestore()
    var tableDataItems : [TableDataItem] = []
    var employeeArray:[Dictionary<String, AnyObject>] =  Array()
    var ifpdfPressed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        uiDesign()
        fetchCallLog()
        fetchUserDetail()

    }
    func fetchUserDetail(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email  = data["email"] as? String {
                            self.emailLbl.text = email
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    @IBAction func csvBtnPressed(_ sender: UIButton) {
        ifpdfPressed = false
        self.view.makeToast("CSV Created Successfully", duration: 2.0, position: .center)
        
    }
    @IBAction func pdfBtnPressed(_ sender: UIButton) {
        ifpdfPressed = true
        self.view.makeToast("PDF Created Successfully", duration: 2.0, position: .center)
    }
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        if ifpdfPressed {
            // pdf will be generated
            createPDFFILE()
        }else{
            // csv file will generated
            createCSV(from: employeeArray)
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    }

extension Array {
    func chunkedElements(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class PDFCreator: NSObject {
    let defaultOffset: CGFloat = 20
    let tableDataHeaderTitles: [String]
    var tableDataItems: [TableDataItem]

    init(tableDataItems: [TableDataItem], tableDataHeaderTitles: [String]) {
        self.tableDataItems = tableDataItems
        self.tableDataHeaderTitles = tableDataHeaderTitles
    }
// below functions are used to draw Table lines
    func create() -> Data {
        // default page format
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: UIGraphicsPDFRendererFormat())

        let numberOfElementsPerPage = calculateNumberOfElementsPerPage(with: pageRect)
        var tableDataChunked: [[TableDataItem]] = tableDataItems.chunkedElements(into: numberOfElementsPerPage)

        let data = renderer.pdfData { context in
            
            for tableDataChunk in tableDataChunked {
                context.beginPage()
                let cgContext = context.cgContext
                drawTableHeaderRect(drawContext: cgContext, pageRect: pageRect)
                drawTableHeaderTitles(titles: tableDataHeaderTitles, drawContext: cgContext, pageRect: pageRect)
                drawTableContentInnerBordersAndText(drawContext: cgContext, pageRect: pageRect, tableDataItems: tableDataChunk)
            }
        }
        return data
    }

    func calculateNumberOfElementsPerPage(with pageRect: CGRect) -> Int {
        let rowHeight = (defaultOffset * 3)
        let number = Int((pageRect.height - rowHeight) / rowHeight)
        return number
    }
}

// Drawings
extension PDFCreator {
    func drawTableHeaderRect(drawContext: CGContext, pageRect: CGRect) {
        drawContext.saveGState()
        drawContext.setLineWidth(3.0)

        // Draw header's 1 top horizontal line
        drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset))
        drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset))
        drawContext.strokePath()

        // Draw header's 1 bottom horizontal line
        drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset * 3))
        drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset * 3))
        drawContext.strokePath()

        // Draw header's 3 vertical lines
        drawContext.setLineWidth(2.0)
        drawContext.saveGState()
        let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(6)
        for verticalLineIndex in 0..<8 {
            let tabX = CGFloat(verticalLineIndex) * tabWidth
            drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset))
            drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset * 3))
            drawContext.strokePath()
        }

        drawContext.restoreGState()
    }

    func drawTableHeaderTitles(titles: [String], drawContext: CGContext, pageRect: CGRect) {
        // prepare title attributes
        let textFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        let titleAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]

        // draw titles
        let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(6)
        for titleIndex in 0..<titles.count {
            let attributedTitle = NSAttributedString(string: titles[titleIndex].capitalized, attributes: titleAttributes)
            let tabX = CGFloat(titleIndex) * tabWidth
            let textRect = CGRect(x: tabX + defaultOffset,
                                  y: defaultOffset * 3 / 2,
                                  width: tabWidth,
                                  height: defaultOffset * 2)
            attributedTitle.draw(in: textRect)
        }
    }

    func drawTableContentInnerBordersAndText(drawContext: CGContext, pageRect: CGRect, tableDataItems: [TableDataItem]) {
        drawContext.setLineWidth(1.0)
        drawContext.saveGState()

        let defaultStartY = defaultOffset * 3

        for elementIndex in 0..<tableDataItems.count {
            let yPosition = CGFloat(elementIndex) * defaultStartY + defaultStartY

            // Draw content's elements texts
            let textFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            let textAttributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: textFont
            ]
            let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(6)
            for titleIndex in 0..<6 {
                var attributedText = NSAttributedString(string: "", attributes: textAttributes)
                switch titleIndex {
                case 0: attributedText = NSAttributedString(string: tableDataItems[elementIndex].sNo ?? "", attributes: textAttributes)
                case 1: attributedText = NSAttributedString(string: tableDataItems[elementIndex].name ?? "", attributes: textAttributes)
                case 2: attributedText = NSAttributedString(string: tableDataItems[elementIndex].phoneNumber ?? "", attributes: textAttributes)
                case 3: attributedText = NSAttributedString(string: tableDataItems[elementIndex].callCategory ?? "", attributes: textAttributes)
                case 4: attributedText = NSAttributedString(string: tableDataItems[elementIndex].callDurationInSecond ?? "", attributes: textAttributes)
                case 5: attributedText = NSAttributedString(string: tableDataItems[elementIndex].createdAt ?? "", attributes: textAttributes)
                default:
                    break
                }
                let tabX = CGFloat(titleIndex) * tabWidth
                let textRect = CGRect(x: tabX + defaultOffset,
                                      y: yPosition + defaultOffset,
                                      width: tabWidth,
                                      height: defaultOffset * 3)
                attributedText.draw(in: textRect)
            }

            // Draw content's 3 vertical lines
            for verticalLineIndex in 0..<7 {
                let tabX = CGFloat(verticalLineIndex) * tabWidth
                drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: yPosition))
                drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: yPosition + defaultStartY))
                drawContext.strokePath()
            }

            // Draw content's element bottom horizontal line
            drawContext.move(to: CGPoint(x: defaultOffset, y: yPosition + defaultStartY))
            drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: yPosition + defaultStartY))
            drawContext.strokePath()
        }
        drawContext.restoreGState()
    }
}







extension SendReportViewController{
    
    func createPDFFILE(){
        print("START EXPORTING...........")
        let fileName = "MY CONTACT DETAIL TODAY, WEEKLY, MONTHLY.PDF" // my file name
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        print("path is ",path)
        let tableDataHeaderTitles =  ["No.", "Name", "Phone Number","Category","Call Duration","Date"]
        let pdfCreator = PDFCreator(tableDataItems: tableDataItems, tableDataHeaderTitles: tableDataHeaderTitles)

        let data = pdfCreator.create()
        PDFDocument(data: data)
        
        do {
            try PDFDocument(data: data)?.write(to: path!)
            let excelSheet = UIActivityViewController(activityItems: [path as Any], applicationActivities: nil)
            self.present(excelSheet,animated: true,completion: nil)
            print("EXPORTED ")
        } catch {
            print("ERROR")
        }
    }
    
    func createCSV(from recArray:[Dictionary<String, AnyObject>]) {
            var csvString = "\("SNo"),\("Name"),\("Phone Number"),\("Call Category"),\("Call Duration"),\("Created At")\n"
            for dct in recArray {
             csvString = csvString.appending("\(String(describing: dct["SNo"]!)),\(String(describing: dct["name"]!)),\(String(describing: dct["phoneNumber"]!)),\(String(describing: dct["callCategory"]!)),\(String(describing: dct["callDurationInSecond"]!)),\(String(describing: dct["createdAt"]!))\n")
            }

            let fileManager = FileManager.default
            do {
                let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
                let fileURL = path.appendingPathComponent("CallHistory.csv")
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                let excelSheet = UIActivityViewController(activityItems: [fileURL as Any], applicationActivities: nil)
                self.present(excelSheet,animated: true,completion: nil)
                print("EXPORTED ")
            } catch {
                print("error creating file")
            }

        }

    func fetchCallLog(){
            CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
            print("CurrentUserUid in load msg R", CurrentUserUid)
            db.collection("USERS").document(CurrentUserUid).collection("CALL_LOGS").addSnapshotListener{ (DocumentSnapshot, error) in
                    self.tableDataItems = []
                    var sNo = 0
                    var sNoCSV = 0
                    var dct = Dictionary<String, AnyObject>()
                    var dct1 = Dictionary<String, AnyObject>()
                    if let e = error {
                        print("error is \(e)")
                    }else {
                        if let snapshotDocuments = DocumentSnapshot?.documents{
                            for doc in snapshotDocuments {
                               // print("\(doc.documentID) => \(doc.data())")
                                let data = doc.data()
                                if let callCategory = data ["callCategory"] as? String,
                                let callDurationInSecond = data ["callDurationInSecond"] as? String,
                                let callDate = data ["callDate"] as? String,
                                let createdAt = data ["createdAt"] as? String,
                                let name = data ["name"] as? String,
                                let phoneNumber = data ["phoneNumber"] as? String
                                {
                                    let today = self.getCurrentDate()
                                    let timeStamp = createdAt
                                    let callTime = self.getTimeOfCall(timeStamp: timeStamp)
                                    var callCategoryy = "Uncategorized"
                                    if callCategory == "0" {
                                        callCategoryy = "Uncategorized"
                                    }else if callCategory == "1" {
                                        callCategoryy = "Personal"
                                    } else {
                                        callCategoryy = "Business"
                                    }
                                    dct.updateValue(name as AnyObject, forKey: "name")
                                    dct.updateValue(phoneNumber as AnyObject, forKey: "phoneNumber")
                                    dct.updateValue(callTime as AnyObject, forKey: "createdAt")
                                    dct.updateValue(callDurationInSecond as AnyObject, forKey: "callDurationInSecond")
                                    dct.updateValue(callCategoryy as AnyObject, forKey: "callCategory")
                                    dct.updateValue("1" as AnyObject, forKey: "SNo")
                                    print("today date ", today)
                                    print("callTime ", callDate)
                                    if callDate == today{
                                        self.employeeArray.append(dct)
                                        self.employeeArray.sort(by: { (object1, object2) in Bool()
                                                        guard let temp1 =  object1["createdAt"] as? String,
                                                      let temp2 = object2["createdAt"] as? String else { return false }
                                                        return temp1 > temp2
                                                })
                                    }
                                    
                                    let callObj = TableDataItem(sNo: "\(sNo)", name: name, phoneNumber: phoneNumber, callCategory: callCategoryy, createdAt: callTime, callDurationInSecond: callDurationInSecond)
                                    print("today date ", today)
                                    print("callTime ", callDate)
                                    if callDate == today{
                                        self.tableDataItems.append(callObj)
                                        self.tableDataItems.sort(by:{   $0.createdAt! > $1.createdAt! })
                                    }
                                   
                                    
                                }
                                print("items are, ", self.tableDataItems)
                            }
                        }
// update s.no value in csv file
                        for row in self.employeeArray.indices {
                            sNoCSV = sNoCSV + 1
                            print("row \(self.employeeArray[row])")

                            self.employeeArray[row]["SNo"] = "\(sNoCSV)" as AnyObject
                        }
// update s no in pdf file
                        self.tableDataItems.indices.forEach {
                        sNo = sNo+1
                        self.tableDataItems[$0].sNo = "\(sNo)"
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
    
    func uiDesign(){
        sendReportView.layer.masksToBounds = false
        sendReportView.layer.cornerRadius = 20
        sendReportView.layer.shadowRadius = 4.0
        sendReportView.layer.shadowColor = UIColor.lightGray.cgColor
        sendReportView.layer.shadowOffset = .zero
        sendReportView.layer.shadowOpacity = 0.4
        
        sendEmailButton.layer.cornerRadius = sendEmailButton.bounds.height / 2
        sendEmailButton.layer.shadowRadius = 20
        sendEmailButton.layer.shadowRadius = sendEmailButton.bounds.height / 2
        sendEmailButton.layer.shadowColor = UIColor.lightGray.cgColor
        
        viewPDF.layer.masksToBounds = false
        viewPDF.layer.cornerRadius = 20
        viewPDF.layer.shadowRadius = 4.0
        viewPDF.layer.shadowColor = UIColor.lightGray.cgColor
        viewPDF.layer.shadowOffset = .zero
        viewPDF.layer.shadowOpacity = 0.4
        
        viewCSV.layer.masksToBounds = false
        viewCSV.layer.cornerRadius = 20
        viewCSV.layer.shadowRadius = 4.0
        viewCSV.layer.shadowColor = UIColor.lightGray.cgColor
        viewCSV.layer.shadowOffset = .zero
        viewCSV.layer.shadowOpacity = 0.4
    }
    
}
