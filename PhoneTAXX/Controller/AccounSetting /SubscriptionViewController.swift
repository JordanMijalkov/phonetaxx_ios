//
//  SubscriptionViewController.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 12/04/21.
//

import UIKit
import StoreKit
import FirebaseFirestore
class SubscriptionViewController: UIViewController {
 
    

    @IBOutlet weak var ultimatePlanView: UIView!
    @IBOutlet weak var savePercentageView: UIView!
    @IBOutlet weak var oneYearPlanView: UIView!
    @IBOutlet weak var monthlyPlanView: UIView!
    let db = Firestore.firestore()
    var products: [SKProduct] = []
    var plantype = ""
    var planStartDate = ""
    var planExpiryDate = ""
    var price = "$14.99"
    var premium = false
    var errorText = "N/A"
    override func viewDidLoad() {
        super.viewDidLoad()

        ultimatePlanView.layer.masksToBounds = false
        ultimatePlanView.layer.cornerRadius = 20
        ultimatePlanView.layer.shadowRadius = 4.0
        ultimatePlanView.layer.shadowColor = UIColor.lightGray.cgColor
        ultimatePlanView.layer.shadowOffset = .zero
        ultimatePlanView.layer.shadowOpacity = 0.4
        
        savePercentageView.layer.masksToBounds = false
        savePercentageView.layer.cornerRadius = 20
        savePercentageView.layer.shadowRadius = 4.0
        savePercentageView.layer.shadowColor = UIColor.lightGray.cgColor
        savePercentageView.layer.shadowOffset = .zero
        savePercentageView.layer.shadowOpacity = 0.4
        savePercentageView.visibility = .gone
        oneYearPlanView.layer.masksToBounds = false
        oneYearPlanView.layer.cornerRadius = 20
        oneYearPlanView.layer.shadowRadius = 4.0
        oneYearPlanView.layer.shadowColor = UIColor.lightGray.cgColor
        oneYearPlanView.layer.shadowOffset = .zero
        oneYearPlanView.layer.shadowOpacity = 0.4
        
        monthlyPlanView.layer.masksToBounds = false
        monthlyPlanView.layer.cornerRadius = 20
        monthlyPlanView.layer.shadowRadius = 4.0
        monthlyPlanView.layer.shadowColor = UIColor.lightGray.cgColor
        monthlyPlanView.layer.shadowOffset = .zero
        monthlyPlanView.layer.shadowOpacity = 0.4
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        InAppManager.shared.loadProducts()
//        let product1 = SubscriptionProductsObjects.instance.products[0]
//        let product2 = SubscriptionProductsObjects.instance.products[1]
//        
//        let price1 = InAppManager.shared.getPriceFormatted(for: product1)
//        let price2 = InAppManager.shared.getPriceFormatted(for: product2)
//        
//        print("PRODUCTS PRICES ARE \(price1) anddd \(price2)")
//        print("NO OF PRODUCTS IS \(self.products.count)")
//        print("PRODUCTS ARE \(productsss)")
         
        
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    func getPlanDetail(){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                if let snapshotDocuments = result?.documents,snapshotDocuments != [] {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let subscription  = data["Subscription"] as? String,
                        let planStartDate  = data["PlanStartDate"] as? String,
                        let planExpiryDate  = data["PlanExpiryDate"] as? String {
                            self.plantype = subscription
                            self.planStartDate = planStartDate
                            self.planExpiryDate = planExpiryDate
                            
                        }
                    }
                }
            } else {
                print("Error",error?.localizedDescription)
                
            }
        }
    }
    @IBAction func monthlyPlanTapped(_ sender: Any) {
        if plantype == "Free" {
            //        if nftStatusss == 1{
            //            self.saveImageToPhotoGallery()
            //        }
            //        else{
                    let product = SubscriptionProductsObjects.instance.products[1]
                       print("PRODUCT IDENTIFIER  MONTHLY IS \(product.productIdentifier)")
            //           print("RageProducts IDENTIFIER IS \(RageProducts.GirlfriendOfDrummerRage)")
            //            if (product.productIdentifier == RageProducts.GirlfriendOfDrummerRage) {
               //           self.performSegue(withIdentifier: showRandomFaceSegueIdentifier, sender: self)
                        InAppManager.shared.purchaseProduct(productType: ProductType.monthly)
                    /*
                    { (result) in
                               print("RESULT OF STORE DELEGATE IS \(result)")
                               switch result {
                               case .success(_): print("PAYMENT BEING INITIATED")//self.sendPremiumToFirebase()
                               case .failure(let error): print("PAYMENT ERROR ERROR\(error.localizedDescription)") //self.displayMyAlertMessage(userMessage: error.localizedDescription)
                               print("PAYMENT COMPLETED")
                               }
                           }
                           print("PAYMENT STATUS IS completeddd")
             */
            //            }
            //
            //            else
            //            {
            //            print("PRODUCT DETAILS \(product)")
            //            }
            //        }

                    
            //        let initiatePayment = { product in
            //          RageProducts.store.buyProduct(product)
            //        }
            //        print("STATUS OF PAYMENT IS \(String(describing: initiatePayment))")
                    
                    
                    
                    /*
                    if self.nftStatusss == 1{
                        self.saveImageToPhotoGallery()
                    }
                    else {
                        self.showDropIn(clientTokenOrTokenizationKey: brainTreeClientTokenOrTokenizationKey)
                    }
                   */
        } else {
            if planExpiryDate > getCurrentDate() {
                // plan already subscribed
                 self.view.makeToast("Plan Already Subscribed",duration:3.0, position:.center)
            }
            else
            {
    // plan expired
               
                //        if nftStatusss == 1{
                //            self.saveImageToPhotoGallery()
                //        }
                //        else{
                        let product = SubscriptionProductsObjects.instance.products[1]
                           print("PRODUCT IDENTIFIER  MONTHLY IS \(product.productIdentifier)")
                //           print("RageProducts IDENTIFIER IS \(RageProducts.GirlfriendOfDrummerRage)")
                //            if (product.productIdentifier == RageProducts.GirlfriendOfDrummerRage) {
                   //           self.performSegue(withIdentifier: showRandomFaceSegueIdentifier, sender: self)
                            InAppManager.shared.purchaseProduct(productType: ProductType.monthly)
                        /*
                        { (result) in
                                   print("RESULT OF STORE DELEGATE IS \(result)")
                                   switch result {
                                   case .success(_): print("PAYMENT BEING INITIATED")//self.sendPremiumToFirebase()
                                   case .failure(let error): print("PAYMENT ERROR ERROR\(error.localizedDescription)") //self.displayMyAlertMessage(userMessage: error.localizedDescription)
                                   print("PAYMENT COMPLETED")
                                   }
                               }
                               print("PAYMENT STATUS IS completeddd")
                 */
                //            }
                //
                //            else
                //            {
                //            print("PRODUCT DETAILS \(product)")
                //            }
                //        }

                        
                //        let initiatePayment = { product in
                //          RageProducts.store.buyProduct(product)
                //        }
                //        print("STATUS OF PAYMENT IS \(String(describing: initiatePayment))")
                        
                        
                        
                        /*
                        if self.nftStatusss == 1{
                            self.saveImageToPhotoGallery()
                        }
                        else {
                            self.showDropIn(clientTokenOrTokenizationKey: brainTreeClientTokenOrTokenizationKey)
                        }
                       */
                
                
            }
        }
        
     

            
    }
    
    @IBAction func btntermNdCondition(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.phonetaxx.com/privacy"){
            UIApplication.shared.openURL(url as URL)
           }
    }
    
    @IBAction func annualPlanTapped(_ sender: Any) {
        if plantype == "Free" {
            //        if nftStatusss == 1{
            //            self.saveImageToPhotoGallery()
            //        }
            //        else{
                    let product = SubscriptionProductsObjects.instance.products[0]
                       print("PRODUCT IDENTIFIER ANNUAL IS \(product.productIdentifier)")
            //           print("RageProducts IDENTIFIER IS \(RageProducts.GirlfriendOfDrummerRage)")
            //            if
            //                (product.productIdentifier == product.productIdentifier)
            //            {
               //           self.performSegue(withIdentifier: showRandomFaceSegueIdentifier, sender: self)
                        InAppManager.shared.purchaseProduct(productType: ProductType.yearly)
                           /*{ (result) in
                               print("RESULT OF STORE DELEGATE IS \(result)")
                               switch result {
                               case .success(_): print("PAYMENT BEING INITIATED")//self.sendPremiumToFirebase()
                               case .failure(let error): print("PAYMENT ERROR ERROR\(error.localizedDescription)") //self.displayMyAlertMessage(userMessage: error.localizedDescription)
                               print("PAYMENT COMPLETED")
                               }
                           }
                           print("PAYMENT STATUS IS completeddd")
             */
            //            }
                        
            //            else
            //            {
            //            print("PRODUCT DETAILS \(product)")
            //            }
            //        }

                    
            //        let initiatePayment = { product in
            //          RageProducts.store.buyProduct(product)
            //        }
            //        print("STATUS OF PAYMENT IS \(String(describing: initiatePayment))")
                    
                    
                    
                    /*
                    if self.nftStatusss == 1{
                        self.saveImageToPhotoGallery()
                    }
                    else {
                        self.showDropIn(clientTokenOrTokenizationKey: brainTreeClientTokenOrTokenizationKey)
                    }
                   */
        } else {
            
            
            if planExpiryDate > getCurrentDate() {
                // plan already subscribed
                 self.view.makeToast("Plan Already Subscribed",duration:3.0, position:.center)
            } else {
        // plan expired
                //        if nftStatusss == 1{
                //            self.saveImageToPhotoGallery()
                //        }
                //        else{
                        let product = SubscriptionProductsObjects.instance.products[0]
                           print("PRODUCT IDENTIFIER ANNUAL IS \(product.productIdentifier)")
                //           print("RageProducts IDENTIFIER IS \(RageProducts.GirlfriendOfDrummerRage)")
                //            if
                //                (product.productIdentifier == product.productIdentifier)
                //            {
                   //           self.performSegue(withIdentifier: showRandomFaceSegueIdentifier, sender: self)
                            InAppManager.shared.purchaseProduct(productType: ProductType.yearly)
                               /*{ (result) in
                                   print("RESULT OF STORE DELEGATE IS \(result)")
                                   switch result {
                                   case .success(_): print("PAYMENT BEING INITIATED")//self.sendPremiumToFirebase()
                                   case .failure(let error): print("PAYMENT ERROR ERROR\(error.localizedDescription)") //self.displayMyAlertMessage(userMessage: error.localizedDescription)
                                   print("PAYMENT COMPLETED")
                                   }
                               }
                               print("PAYMENT STATUS IS completeddd")
                 */
                //            }
                            
                //            else
                //            {
                //            print("PRODUCT DETAILS \(product)")
                //            }
                //        }

                        
                //        let initiatePayment = { product in
                //          RageProducts.store.buyProduct(product)
                //        }
                //        print("STATUS OF PAYMENT IS \(String(describing: initiatePayment))")
                        
                        
                        
                        /*
                        if self.nftStatusss == 1{
                            self.saveImageToPhotoGallery()
                        }
                        else {
                            self.showDropIn(clientTokenOrTokenizationKey: brainTreeClientTokenOrTokenizationKey)
                        }
                       */
            }
        }
    }
}

extension SubscriptionViewController {
    func subscriptionIsGood(products: [SKProduct]) {
        self.products = products
        let product1 = products[0]
        let product2 = products[1]
        
        let price1 = InAppManager.shared.getPriceFormatted(for: product1)
        let price2 = InAppManager.shared.getPriceFormatted(for: product2)
        
        print("PRODUCTS PRICES ARE \(price1) anddd \(price2)")
        print("NO OF PRODUCTS IS \(self.products.count)")
//        if self.products.count > 0 {
//            if let proposedPrice = MyStoreKitDelegate.shared.getPriceFormatted(for: self.products[0]) {
//                price = proposedPrice
//                print("PROPOSED PRICE IS \(proposedPrice)")
//
//                if premium {
////                    priceLabel.text = "\(price) / mo"
//                } else {
////                    detailLabel.text = "\(price) per month will be charged."// after free trial period"
//                }
//
//            }
//        }
        
        
        
    }
}
