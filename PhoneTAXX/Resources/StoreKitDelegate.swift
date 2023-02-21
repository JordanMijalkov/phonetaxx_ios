
//
//  InAppManager.swift
//
//  Created by Ellina Kuznetcova on 12/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//
import Foundation
import StoreKit
import FirebaseFirestore
enum ProductType: String {
    
//    case monthly = "PlanMonthly"
//    case yearly = "PlanB"
    case monthly = "monthltySubscriptions"
    case yearly = "annualPlan"
    
    static var all: [ProductType] {
        return [.monthly, .yearly]
    }
}

enum InAppErrors: Swift.Error {
    case noSubscriptionPurchased
    case noProductsAvailable
    
    var localizedDescription: String {
        switch self {
        case .noSubscriptionPurchased:
            return "No subscription purchased"
        case .noProductsAvailable:
            return "No products available"
        }
    }
}

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    func subscriptionStatusUpdated(value: Bool)
}

class InAppManager: NSObject {
    static let shared = InAppManager()
    
    weak var delegate: InAppManagerDelegate?
    let db = Firestore.firestore()
    var products: [SKProduct] = []
    
    var isTrialPurchased: Bool?
    var expirationDate: Date?
    var purchasedProduct: ProductType?
    
    var isSubscriptionAvailable: Bool = true
        {
        didSet(value) {
            self.delegate?.subscriptionStatusUpdated(value: value)
        }
    }
    
    func startMonitoring() {
        SKPaymentQueue.default().add(self)
//        self.updateSubscriptionStatus()
    }
    
    func stopMonitoring() {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() {
        let productIdentifiers = Set<String>(ProductType.all.map({$0.rawValue}))
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreSubscription() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.delegate?.inAppLoadingStarted()
    }
    /*
    func checkSubscriptionAvailability(_ completionHandler: @escaping (Bool) -> Void) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() as AnyObject else {
                completionHandler(false)
                return
        }
        
       let _ = Router.User.sendReceipt(receipt: receipt).request(baseUrl: "https://sandbox.itunes.apple.com").responseObject { (response: DataResponse<RTSubscriptionResponse>) in
           switch response.result {
           case .success(let value):
               guard let expirationDate = value.expirationDate,
                let productId = value.productId else {completionHandler(false); return}
               self.expirationDate = expirationDate
               self.isTrialPurchased = value.isTrial
               self.purchasedProduct = ProductType(rawValue: productId)
               completionHandler(Date().timeIntervalSince1970 < expirationDate.timeIntervalSince1970)
           case .failure(let error):
               completionHandler(false)
           }
       }
    }
 */
    /*
    func updateSubscriptionStatus() {
        self.checkSubscriptionAvailability({ [weak self] (isSubscribed) in
            self?.isSubscriptionAvailable = isSubscribed
        })
    }
     */
}


extension InAppManager: SKPaymentTransactionObserver {
    func updateMonthlyPlanDate()-> (String , String){
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = 1
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        print("current datekkvcj",currentDate)
        print("future date jhvckjdfs",futureDate!)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let dateString = dateFormatterGet.string(from: currentDate)
        let dateString2 = dateFormatterGet.string(from: futureDate!)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, MMMM dd, yyyy"
        let date: NSDate? = dateFormatterGet.date(from: dateString) as NSDate?
         let currentdate = dateFormatterPrint.string(from: date! as Date)
        let date2: NSDate? = dateFormatterGet.date(from: dateString2) as NSDate?
         let futuredate = dateFormatterPrint.string(from: date2! as Date)
            print("new date hello word ",currentdate)
            print("future date hello word ",futuredate)
        return (currentdate , futuredate)
    }
    func updateYearlyPlanDate() -> (String , String){
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = 1
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        print("current datekkvcj",currentDate)
        print("future date jhvckjdfs",futureDate!)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let dateString = dateFormatterGet.string(from: currentDate)
        let dateString2 = dateFormatterGet.string(from: futureDate!)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, MMMM dd, yyyy"
        let date: NSDate? = dateFormatterGet.date(from: dateString) as NSDate?
         let currentdate = dateFormatterPrint.string(from: date! as Date)
        let date2: NSDate? = dateFormatterGet.date(from: dateString2) as NSDate?
         let futuredate = dateFormatterPrint.string(from: date2! as Date)
            print("new date hello word ",currentdate)
            print("future date hello word ",futuredate)
        return (currentdate , futuredate)
    }
    func addMonthlyPlanDetailtoDB(subscription: String ,planExpiryDate: String , planStartDate : String){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                 for document in result!.documents{
                    document.reference.setData(["Subscription": subscription] , merge: true)
                    document.reference.setData(["PlanExpiryDate": planExpiryDate] , merge: true)
                    document.reference.setData(["PlanStartDate": planStartDate] , merge: true)
                    
                 }
              
            }
        
       }

    }
    func addYearlyPlanDetailtoDB(subscription: String ,planExpiryDate: String , planStartDate : String){
        db.collection("USERS").whereField("uid", isEqualTo: CurrentUserUid).getDocuments { (result, error) in
            if error == nil{
                 for document in result!.documents{
                    document.reference.setData(["Subscription": subscription] , merge: true)
                    document.reference.setData(["PlanExpiryDate": planExpiryDate] , merge: true)
                    document.reference.setData(["PlanStartDate": planStartDate] , merge: true)
                    
                 }
              
            }
        
       }

    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else {fatalError()}
            switch transaction.transactionState {
            case .purchasing:
                self.delegate?.inAppLoadingStarted()
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
//                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
                if productType == .monthly {
                    let planStartDate = updateMonthlyPlanDate()
                    addMonthlyPlanDetailtoDB(subscription: "Monthly", planExpiryDate: planStartDate.1, planStartDate: planStartDate.0)
                }
                else if productType == .yearly {
                    let planStartDate = updateYearlyPlanDate()
                        addMonthlyPlanDetailtoDB(subscription: "Yearly", planExpiryDate: planStartDate.1, planStartDate: planStartDate.0)
                }
                
                print("PRODUCT TYPE IS \(productType)")
            case .failed:
                if let transactionError = transaction.error as? NSError,
                    transactionError.code != SKError.paymentCancelled.rawValue {
                    self.delegate?.inAppLoadingFailed(error: transaction.error)
                    
                } else {
                    self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
//                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
                if productType == .monthly {
                    
                    
                }
                else if productType == .yearly {
                    
                    
                }
            case .deferred:
                self.delegate?.inAppLoadingSucceded(productType: productType)
            }
        }
    }
    
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Swift.Error) {
        self.delegate?.inAppLoadingFailed(error: error)
        print("PAYMENT ERROR IS \(error)")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("PAYMENT ERROR IS \(error)")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("PAYMENT GOT FINISHED")
    }
    
    
    
    
}

//MARK: - SKProducatsRequestDelegate
extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("RESPONSE PRODUCTS IS \(response.products)")
        guard response.products.count > 0 else {return}
        self.products = response.products
        SubscriptionProductsObjects.instance.products = self.products
        print("PRODUCTS FOR IAM IS \(products)")
        print("PUBLIC PRODUCTS IS \(SubscriptionProductsObjects.instance.products)")
        let product1 = SubscriptionProductsObjects.instance.products[0]
        let product2 = SubscriptionProductsObjects.instance.products[1]
        
        let price1 = InAppManager.shared.getPriceFormatted(for: product1)
        let price2 = InAppManager.shared.getPriceFormatted(for: product2)
        
        print("PRODUCTS PRICES ARE \(price1) anddd \(price2)")
        print("NO OF PRODUCTS IS \(self.products.count)")
    }
    
    
    
}

public class SubscriptionProductsObjects{
    static var instance = SubscriptionProductsObjects()
    var products = [SKProduct]()
    var price1 = ""
    var price2 = ""

}
