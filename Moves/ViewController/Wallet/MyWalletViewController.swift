//
//  MyWalletViewController.swift
//  Vibez
//
//  Created by Mac on 27/10/2020.
//  Copyright © 2020 Dinosoftlabs. All rights reserved.
//

import Alamofire
import SDWebImage
import StoreKit
import SwiftyStoreKit
import UIKit

class MyWalletViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private let viewModel = MyWalletViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    private var models = [SKProduct]()

    // MARK: - Variables

    var coin_name = ""
    var coin = ""
    var price = ""
    var profileResponse: ProfileResponse?

    // MARK: - Outlets

    @IBOutlet var tblGetAllCoins: UITableView!
    @IBOutlet var lblTotalCoin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTotalCoin.text = UserDefaultsManager.shared.wallet
        self.loader.isHidden = false
        SKPaymentQueue.default().add(self)
        self.fetchProducts()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    // MARK: - Button Action
    
    @IBAction func btnCashout(_ sender: Any) {
        let myViewController = CashOutViewController(nibName: "CashOutViewController", bundle: nil)
        
        self.navigationController?.pushViewController(myViewController, animated: true)
    }

    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinShareCell") as! CoinShareTableViewCell
        let product = self.models[indexPath.row]
        cell.lblCoin.text = "\(product.localizedTitle)"
        cell.lblCoinPrice.text = "\(product.priceLocale.currencySymbol ?? "$")\(product.price)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.models[indexPath.row]
        let objCoin = product.localizedTitle.components(separatedBy: " ")
        self.coin = objCoin[0]
        self.coin_name = product.localizedTitle
        self.price = "\(product.priceLocale.currencySymbol ?? "$")\(product.price)"
    
        let payment = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    private func addCointToWallet(coin: String, name: String, price: String, TID: String) {
        let purchaseCoin = PurchaseCoinRequest(userId: UserDefaultsManager.shared.user_id, coin: coin, title: name, price: price, transactionId: TID, device: "iOS")
        viewModel.purchaseCoin(parameter: purchaseCoin)
        self.observeEvent()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding:
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .purchaseCoin(purchaseCoin: let purchaseCoin):
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    if purchaseCoin.code == 200 {
                        UserDefaultsManager.shared.wallet = purchaseCoin.msg?.user.wallet?.stringValue ?? ""
                        guard let navigationController = self.navigationController else { return }
                        for controller in navigationController.viewControllers {
                            if controller.isKind(of: ProfileViewController.self) {
                                _ = navigationController.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                }
            case .showCoinWorth(showCoinWorth: let showCoinWorth): break
            }
        }
    }
    
  
    // Products
    
    enum Product: String, CaseIterable {
        case buy100Coins = "com.dinosoftlab.tiktik.buy100Coins"
        case buy500Coins = "com.dinosoftlab.tiktik.buy500Coins"
        case buy2000Coins = "com.dinosoftlab.tiktik.buy2000Coins"
        case buy5000Coins = "com.dinosoftlab.tiktik.buy5000Coins"
        case buy10000Coins = "com.dinosoftlab.tiktik.buy10000Coins"
    }
    
    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap { $0.rawValue }))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("Count: \(response.products.count)")
            let validProducts = response.products
            for i in 0 ..< validProducts.count {
                let product = validProducts[i]
                self.models.append(product)
            }
            self.models.sort { Double(truncating: $0.price) < Double(truncating: $1.price) }
            self.tblGetAllCoins.reloadData()
            self.loader.isHidden = true
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.error != nil {
                print("error: \(transaction.error?.localizedDescription)")
                Utility.showMessage(message: transaction.error?.localizedDescription ?? "", on: self.view)
            }
            switch transaction.transactionState {
            case .purchasing:
                print("handle purchasing state")
            case .purchased:
                print("handle purchased state")
                self.loader.isHidden = false
                SKPaymentQueue.default().finishTransaction(transaction)
                   
                print("transaction.transactionIdentifier", transaction.transactionIdentifier!)
        
                self.addCointToWallet(coin: self.coin, name: self.coin_name, price: self.price, TID: "\(transaction.transactionIdentifier!)")
            case .restored:
                print("handle restored state")
            case .failed:
                print("handle failed state")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                print("handle deferred state")
                break
            @unknown default:
                print("Fatal Error")
            }
        }
    }
}
