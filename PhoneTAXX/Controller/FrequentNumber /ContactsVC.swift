//
//  ContactSVC.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 27/05/21.
//

import UIKit
import  Contacts
import ContactsUI
class ContactsTVCell: UITableViewCell , CNContactPickerDelegate {
    @IBOutlet weak var contactNameLBL: UILabel!
    
    @IBOutlet weak var contactImg: UIImageView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var ContactPHNumLabl: UILabel!
    
    override func awakeFromNib() {
        contactView.layer.cornerRadius = 20
        contactView.layer.masksToBounds = false
        contactView.layer.cornerRadius = 10
        contactView.layer.shadowRadius = 4.0
        contactView.layer.shadowColor = UIColor.lightGray.cgColor
        contactView.layer.shadowOffset = .zero
        contactView.layer.shadowOpacity = 0.4
        contactImg.layer.cornerRadius = contactImg.bounds.height / 2
        contactImg.clipsToBounds = true
    }

}
class ContactsVC: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var contactMainView: UIView!
    var contacts : [FetchedContact]? = []
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        contactMainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contactMainView.layer.masksToBounds = false
        contactMainView.layer.backgroundColor = UIColor.white.cgColor
        contactMainView.layer.shadowColor = UIColor.lightGray.cgColor
        contactMainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        contactMainView.layer.shadowOpacity = 0.5
        contactMainView.layer.cornerRadius = 30
        contactTableView.delegate = self
        contactTableView.dataSource = self
        fetchContacts()
        
    }
//    @IBAction func contactsPressed(_ sender: AnyObject) {
//        let contactPicker = CNContactPickerViewController()
//        contactPicker.delegate = self;
//
//        self.present(contactPicker, animated: true, completion: nil)
//    }
    @IBAction func backBtnAction(_ sender: UIButton) {
               
        self.navigationController?.popViewController(animated: true)
    }
    
//    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
//
//       let contact = contactProperty.contact
//       if contact.imageDataAvailable {
//          // there is an image for this contact
//        let image = UIImage(data: contact.imageData ?? Data())
//          // Do what ever you want with the contact image below
//          print("image is ", image)
//       }
//    }
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
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey , CNContactImageDataKey , CNContactImageDataAvailableKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        var imageData:UIImage?
                        if contact.imageDataAvailable {
                              // there is an image for this contact
                             imageData = UIImage(data: contact.imageData ?? Data())
                              print("image is ", imageData)
                           }
                        else {
                            
                        }
                        self.contacts?.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName,telephone: String(contact.phoneNumbers.first?.value.stringValue.filter { !" \n\t-\r".contains($0) } ?? ""), image: imageData
                        ))
                        self.contacts?.sort(by: { (item1, item2) -> Bool in
                            return item1.firstName!.compare(item2.firstName!) == ComparisonResult.orderedAscending
                            })
                        print("contacts are ", self.contacts)
                        
                    })
                    DispatchQueue.main.async {
                        self.contactTableView.reloadData()
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    

}
//MARK: - TableWork

extension ContactsVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTVCell", for: indexPath) as! ContactsTVCell
    
        cell.contactNameLBL.text = contacts?[indexPath.row].firstName ?? "" + " " + ((contacts?[indexPath.row].lastName)!) ?? ""
        cell.ContactPHNumLabl.text = contacts?[indexPath.row].telephone
        if contacts?[indexPath.row].image != nil{
            cell.contactImg.image = contacts?[indexPath.row].image
        }else {
            cell.contactImg.image = UIImage(named: "businessperson")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTVCell", for: indexPath) as! ContactsTVCell
        FrequentNumberSave.instance.conatctName = contacts?[indexPath.row].firstName ?? "" + " " + ((contacts?[indexPath.row].lastName)!) ?? ""
        FrequentNumberSave.instance.conatctPhNo = contacts?[indexPath.row].telephone ?? ""
        FrequentNumberSave.instance.ifComeFromContact = true
        FrequentNumberSave.instance.contactImg = contacts?[indexPath.row].image ?? cell.contactImg.image as! UIImage
        
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNumberViewController") as! AddNumberViewController
//        vc.conatctName = contacts?[indexPath.row].firstName ?? "" + " " + ((contacts?[indexPath.row].lastName)!) ?? ""
//        vc.conatctPhNo = contacts?[indexPath.row].telephone ?? ""
//        vc.contactImg = contacts?[indexPath.row].image ?? cell.contactImg.image
//        vc.ifComeFromContact = true
        print("conatctName",FrequentNumberSave.instance.conatctName)
        print("contactImg",FrequentNumberSave.instance.conatctPhNo)
//        vc.isComeFromContact = true
        self.navigationController?.popViewController(animated: true)
       // self.navigationController?.pushViewController(vc, animated: true)
    }
}


public class FrequentNumberSave{
    
    static var instance = FrequentNumberSave()
    var conatctName=""  //= contacts?[indexPath.row].firstName ?? "" + " " + ((contacts?[indexPath.row].lastName)!) ?? ""
    var conatctPhNo = "" //contacts?[indexPath.row].telephone ?? ""
     var contactImg = UIImage() //contacts?[indexPath.row].image ?? cell.contactImg.image
    var ifComeFromContact = true
}
