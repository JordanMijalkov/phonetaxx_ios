//
//  NotificationViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var pushNoticationAndNotificationSoundView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationView.layer.cornerRadius = 25
        notificationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        notificationView.layer.masksToBounds = false
        notificationView.layer.backgroundColor = UIColor.white.cgColor
        notificationView.layer.shadowColor = UIColor.lightGray.cgColor
        notificationView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        notificationView.layer.shadowOpacity = 0.5

        
        pushNoticationAndNotificationSoundView.layer.masksToBounds = false
        pushNoticationAndNotificationSoundView.layer.cornerRadius = 20
        pushNoticationAndNotificationSoundView.layer.shadowRadius = 4.0
        pushNoticationAndNotificationSoundView.layer.shadowColor = UIColor.lightGray.cgColor
        pushNoticationAndNotificationSoundView.layer.shadowOffset = .zero
        pushNoticationAndNotificationSoundView.layer.shadowOpacity = 0.4
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchButton(_ sender: Any) {
       
    }
    

}
