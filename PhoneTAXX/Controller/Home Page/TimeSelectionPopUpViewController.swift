//
//  TimeSelectionPopUpViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 10/04/21.
//

import UIKit

class TimeSelectionPopUpViewController: UIViewController {

    @IBOutlet weak var timeSelectionView: UIView!
    var timeLbl = "Today"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#1844A3").withAlphaComponent(0.6)
        timeSelectionView.layer.masksToBounds = false
        timeSelectionView.layer.cornerRadius = 20
        timeSelectionView.layer.shadowRadius = 4.0
        timeSelectionView.layer.shadowColor = UIColor.lightGray.cgColor
        timeSelectionView.layer.shadowOffset = .zero
        timeSelectionView.layer.shadowOpacity = 0.4
        
    }
    
    @IBAction func monthlyBtn(_ sender: UIButton) {
        timeLbl = "Monthly"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        sortData.instance.sortType = 2
        vc.timeSlotLbl = timeLbl
        NotificationCenter.default.post(name: Notification.Name("changeSortTitle"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func weeklyBtn(_ sender: UIButton) {
        timeLbl = "Weekly"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.timeSlotLbl = timeLbl
        sortData.instance.sortType = 1
        print("vc.timeSlotLbl",vc.timeSlotLbl)
        NotificationCenter.default.post(name: Notification.Name("changeSortTitle"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func todayBtn(_ sender: UIButton) {
        timeLbl = "Today"
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        vc.timeSlotLbl = timeLbl
        sortData.instance.sortType = 0
        NotificationCenter.default.post(name: Notification.Name("changeSortTitle"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
