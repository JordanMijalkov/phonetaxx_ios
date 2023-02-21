//
//  ShowCalenderVC.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 03/06/21.
//

import UIKit
import FSCalendar
class ShowCalenderVC: UIViewController {

   
   
    @IBOutlet weak var monthlabel: UILabel!
    @IBOutlet weak var viewForPicker: UIView!
    var month = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        self.monthlabel.text = getCurrentMonth()
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: (viewForPicker.bounds.height - 300) / 2), size: CGSize(width: viewForPicker.bounds.width, height: 300)))
        picker.maximumDate =  Date()
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        viewForPicker.addSubview(picker)
    }
    @objc func dateChanged(_ picker: MonthYearPickerView) {
            print("date changed: \(picker.date)")
        let date = picker.date
        let datFormater = DateFormatter()
        datFormater.dateFormat = "yyyy-MM-dd HH:mm:ss z"   // format of  given date
        let dateString = datFormater.string(from: date)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM yyyy"
        let ddate: NSDate? = datFormater.date(from: dateString) as NSDate?
         let currentdate = dateFormatterPrint.string(from: ddate! as Date)
            print(currentdate)
          month = currentdate
        self.monthlabel.text = currentdate
        
        }
    @IBAction func BtnCancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BtnOKPressed(_ sender: UIButton) {
        monthValue = month
        print("month is , ",monthValue)
        NotificationCenter.default.post(name: Notification.Name("updateMonthValue"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
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
