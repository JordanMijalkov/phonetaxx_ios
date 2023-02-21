//
//  SupportViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 01/06/21.
//

import UIKit
import SafariServices
import MessageUI
class SupportViewController: UIViewController {

    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var helpAndSupportView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneNumberView: UIView!
    var recepients = ["admin@phonetaxx.com"]
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewShadowAndCurve()
        // Do any additional setup after loading the view.

    }
    @IBAction func threeMenuButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func emailSendButtonTapped(_ sender: Any) {
        self.sendEmail(recepientss: self.recepients, subjects: "General Help or Feedback")
    }
    
    @IBAction func btnHelpCenterTapped(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.phonetaxx.com/blog"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    @IBAction func phoneNumberCallButtonTapped(_ sender: Any) {
        if let url = URL(string: "tel://8585229316"),
        UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("Call initiated")
        }
    }
    
    func sendEmail(recepientss:[String],subjects:String) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(recepientss)
                mail.setMessageBody("<p>Please leave the information below so we can better assist you.</p><p>Device Name:</p><p>iOS Version:</p><p>App Version:</p><p>Customer ID:</p><p>Localisation:</p><p>Internet Connection Status</p>", isHTML: true)
                mail.setSubject(subjects)
                present(mail, animated: true)
            } else {
                // show failure alert
                self.openAlert(title: "Error", message: "We apologize for the incovenience, email is not configured in your mail box" , alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    print("Okay Clicked")
                }])
//                self.showAlertWithMsgNCancelBtn(withTitle: "Error", withMessage: "We apologize for the incovenience, email is not configured in your mail box")
                print("FAILED TO SEND MAIL")
            }
        }
    
}
extension SupportViewController {
    
    func ViewShadowAndCurve(){
        
        helpAndSupportView.layer.cornerRadius = 30
        helpAndSupportView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        helpAndSupportView.layer.masksToBounds = false
        helpAndSupportView.layer.backgroundColor = UIColor.white.cgColor
        helpAndSupportView.layer.shadowColor = UIColor.lightGray.cgColor
        helpAndSupportView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        helpAndSupportView.layer.shadowOpacity = 0.5
        
        
        emailView.layer.masksToBounds = false
        emailView.layer.cornerRadius = 20
        emailView.layer.shadowRadius = 4.0
        emailView.layer.shadowColor = UIColor.lightGray.cgColor
        emailView.layer.shadowOffset = .zero
        emailView.layer.shadowOpacity = 0.4
        
        phoneNumberView.layer.masksToBounds = false
        phoneNumberView.layer.cornerRadius = 20
        phoneNumberView.layer.shadowRadius = 4.0
        phoneNumberView.layer.shadowColor = UIColor.lightGray.cgColor
        phoneNumberView.layer.shadowOffset = .zero
        phoneNumberView.layer.shadowOpacity = 0.4
        
        helpView.layer.masksToBounds = false
        helpView.layer.cornerRadius = 20
        helpView.layer.shadowRadius = 4.0
        helpView.layer.shadowColor = UIColor.lightGray.cgColor
        helpView.layer.shadowOffset = .zero
        helpView.layer.shadowOpacity = 0.4
        
    }
    
}

extension SupportViewController:MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        switch result {
        case .cancelled:
            break
        case .failed:
            self.view.makeToast("Sorry email send failed",duration:3.0, position:.center)
            break
        case .saved:
            self.view.makeToast("Email saved",duration:3.0, position:.center)
            break
        case .sent:
            self.view.makeToast("Email sent",duration:3.0, position:.center)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.navigationController?.popViewController(animated: true)
              }
            break
        @unknown default:
            return
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
