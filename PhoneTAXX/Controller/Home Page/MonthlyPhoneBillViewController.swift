//
//  MonthlyPhoneBillViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import FirebaseFirestore
class MonthlyPhoneBillViewController: UIViewController {

    @IBOutlet weak var monthlyPhoneBillView: UIView!
    
    @IBOutlet weak var textmonthlyBill: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    let db = Firestore.firestore()
    var ifComeFromACSetting = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        uIDesignMethod()
       // monthlyBill = textmonthlyBill.text ?? ""
    }
    
    @IBAction func cancelButton(_ sender: Any) {
//        if ifComeFromACSetting{
//            self.navigationController?.popViewController(animated: true)
//        }else {
//
//            self.dismiss(animated: true, completion: nil)
//        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        print("CurrentUserUid", CurrentUserUid)
        let monthlyBillInteger = self.textmonthlyBill.text!
        if monthlyBillInteger == "" {
            self.dismiss(animated: true, completion: nil)
            return
        }
        print("monthlyBillInteger", monthlyBillInteger)
            UserDefaults.standard.set(monthlyBillInteger, forKey: "monthlyBill")
        NotificationCenter.default.post(name: Notification.Name("updateMonthlyBill"), object: nil, userInfo: nil)
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                print("result!.documents",result!.documents)
                for document in result!.documents{
                    var monthlyBill = self.textmonthlyBill.text!
                    let monthlyBillInteger = Float(monthlyBill)
                    let mb = String(format: "%.2f", monthlyBillInteger as! CVarArg)
                    print("mb",mb)
                    print("monthlyBillInteger Float",monthlyBillInteger!)
                    document.reference.setData(["mothlyBillAmount": "\(mb)" ] , merge: true)
                    //monthlyBill = monthlyBillInteger
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    func uIDesignMethod(){
        monthlyPhoneBillView.layer.masksToBounds = false
        monthlyPhoneBillView.layer.cornerRadius = 20
        monthlyPhoneBillView.layer.shadowRadius = 4.0
        monthlyPhoneBillView.layer.shadowColor = UIColor.lightGray.cgColor
        monthlyPhoneBillView.layer.shadowOffset = .zero
        monthlyPhoneBillView.layer.shadowOpacity = 0.4
        
        textmonthlyBill.layer.masksToBounds = true
        textmonthlyBill.layer.cornerRadius = textmonthlyBill.frame.size.height / 2
        textmonthlyBill.layer.shadowRadius = textmonthlyBill.frame.size.height / 2
        textmonthlyBill.layer.shadowColor = UIColor.lightGray.cgColor
        textmonthlyBill.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textmonthlyBill.layer.shadowOpacity = 0.4
        textmonthlyBill.leftView = UIView(frame: CGRect(x: 10, y: 43.67, width: 23, height: textmonthlyBill.frame.height))
        textmonthlyBill.leftViewMode = .always
        
        saveButton.layer.cornerRadius = saveButton.bounds.height / 2
        saveButton.layer.shadowRadius = 20
        saveButton.layer.shadowRadius = saveButton.bounds.height / 2
        saveButton.layer.shadowColor = UIColor.lightGray.cgColor
        
    }

}
