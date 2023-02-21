//
//  FrequentNumberViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Contacts

class CallDetailViewCell: UITableViewCell {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var categoryTypeLbl: UILabel!
    override  func awakeFromNib() {
        personImage.layer.cornerRadius = personImage.bounds.height / 2
        personImage.clipsToBounds = true
        editBtn.layer.cornerRadius = 5
        editBtn.clipsToBounds = true
    }
}


struct FrequentContactsDataModel{
      
    var phonenumber : String?
    var name : String?
    var businessname : String?
    var ein : String?
    var naicscode : String
    var location : String?
    var userUuid : String?
    var  category : String?
    var uuId : String?
    var createdAt : String?
    var profileUrl : String?
}

class FrequentNumberViewController: UIViewController {

   
    var requentContactsArr : [FrequentContactsDataModel] = []
    let db = Firestore.firestore()
    var yourViewBorder = CAShapeLayer()
    @IBOutlet weak var frequentNumberView: UIView!
    @IBOutlet weak var addNewBtn: UIButton!
    @IBOutlet weak var CallListTableView: UITableView!
    @IBOutlet weak var addBtnView: UIView!
    override func viewWillAppear(_ animated: Bool) {
        CallListInDetail()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = addBtnView.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: addBtnView.bounds).cgPath
        addBtnView.layer.addSublayer(yourViewBorder)
        
        
        
        frequentNumberView.layer.cornerRadius = 30
        frequentNumberView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        frequentNumberView.layer.masksToBounds = false
        frequentNumberView.layer.backgroundColor = UIColor.white.cgColor
        frequentNumberView.layer.shadowColor = UIColor.lightGray.cgColor
        frequentNumberView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        frequentNumberView.layer.shadowOpacity = 0.5
        CallListInDetail()
        
        //CallListTableView.reloadData()
    }
    
    func CallListInDetail(){
        CurrentUserUid = UserDefaults.standard.string(forKey: "current_userUid") ?? ""
                print("CurrentUserUid in load msg R", CurrentUserUid)
                db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").addSnapshotListener{ (DocumentSnapshot, error) in
                        self.requentContactsArr = []
                        if let e = error {
                            print("error is \(e)")
                        }else {
                            if let snapshotDocuments = DocumentSnapshot?.documents{
                                for doc in snapshotDocuments {
                                    print("\(doc.documentID) => \(doc.data())")
                                    let data = doc.data()
                                    if let category = data ["category"] as? String,
                                    let name = data ["name"] as? String,
                                    let phonenumber = data ["phonenumber"] as? String,
                                    let userUuid = data ["userUuid"] as? String,
                                    let uuId = data ["uuId"] as? String,
                                    let businessname = data ["businessname"] as? String,
                                    let ein = data ["ein"] as? String,
                                    let naicscode = data ["naicscode"] as? String,
                                    let createdAt = data ["createdAt"] as? String,
                                    let profileUrl = data ["profileUrl"] as? String,
                                    let location = data ["location"] as? String
                                    {
                                        let callObj = FrequentContactsDataModel(phonenumber: phonenumber, name: name, businessname: businessname, ein: ein, naicscode: naicscode, location: location,userUuid: userUuid, category: category, uuId: uuId, createdAt: createdAt, profileUrl: profileUrl)
                                        self.requentContactsArr.append(callObj)
                                    }
                                    
                                    
                                    print("items are, ", self.requentContactsArr)
                                    self.CallListTableView.delegate = self
                                    self.CallListTableView.dataSource = self
                                   
                                   
                                    
                                }
                                self.requentContactsArr.sort(by: { (item1, item2) -> Bool in
                                    return item1.name!.uppercased().compare(item2.name!.uppercased()) == ComparisonResult.orderedAscending
                                    }) 
                            }
                            DispatchQueue.main.async {
                                
                                self.CallListTableView.reloadData()
                            }
                        }
                }
    }
    
   
    @IBAction func actionAddNew(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNumberViewController") as! AddNumberViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - Table Work

extension FrequentNumberViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return requentContactsArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallDetailViewCell", for: indexPath) as! CallDetailViewCell
        
        let index = requentContactsArr[indexPath.row]
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteConatct), for:
                                        .touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editConatct), for:
                                        .touchUpInside)
        cell.personNameLabel.text = index.name
        cell.contactNumberLabel.text = index.phonenumber
        if index.profileUrl != ""{
            cell.personImage.sd_setImage(with: URL(string: index.profileUrl ?? ""), placeholderImage: UIImage(named: "businessperson"))
        }else {
            cell.personImage.image = UIImage(named: "businessperson")
        }
        if index.category == "1"{
            cell.categoryTypeLbl.text = "(Personal)"
        }else if index.category == "2"{
            cell.categoryTypeLbl.text = "(Business)"
        }else {
            cell.categoryTypeLbl.text = ""
        }
        return cell
    }
    
    
    @objc func editConatct(sender: UIButton){
        print(sender.tag)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditFrequentContactViewController") as! EditFrequentContactViewController
        vc.conatctName = requentContactsArr[sender.tag].name ?? ""
        vc.conatctPhNum = requentContactsArr[sender.tag].phonenumber ?? ""
        vc.conatctBusiness = requentContactsArr[sender.tag].businessname ?? ""
        vc.conatctEIN = requentContactsArr[sender.tag].ein ?? ""
        vc.conatctNAICS = requentContactsArr[sender.tag].naicscode
        vc.conatctLocation = requentContactsArr[sender.tag].location ?? ""
        vc.conatctCategory = requentContactsArr[sender.tag].category ?? ""
        vc.conatctUUId = requentContactsArr[sender.tag].uuId ?? ""
        
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    
    @objc func deleteConatct(sender: UIButton){
        print(sender.tag)
        
        var refreshAlert = UIAlertController(title: "Alert", message: "Are you sure you want to Delete Contact ?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
          print("Handle Ok logic here")
            let uid = self.requentContactsArr[sender.tag].uuId
            print("uid ==",uid)
            self.db.collection("USERS").document(CurrentUserUid).collection("CONTACTS").document(uid ?? "").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document of CONTACTS successfully removed!")
                    self.CallListInDetail()
                }
             }
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle Cancel Logic here")
          }))

        present(refreshAlert, animated: true, completion: nil)
    }
}

