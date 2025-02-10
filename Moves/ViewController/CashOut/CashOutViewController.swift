//
//  CashOutViewController.swift
//  Movess
//
//  Created by Mac on 02/11/2022.
//

import UIKit

class CashOutViewController: UIViewController {
    private let viewModel = MyWalletViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    // MARK: - Outlets
    
    @IBOutlet var btnCashOut: UIButton!
    @IBOutlet var lblTotalWalletCoins: UILabel!
    @IBOutlet var lblTotalCoins: UILabel!
    @IBOutlet var lblTotalCash: UILabel!
    
    var Wallet: CGFloat = 0.0
    var strprice = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCoinValues()
        
        self.lblTotalWalletCoins.text! = UserDefaultsManager.shared.wallet
        self.lblTotalCoins.text! = UserDefaultsManager.shared.wallet
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    // MARK: - Button Action
    
    @IBAction func btnCashOutAction(_ sender: Any) {
        self.Cash_Out_request()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Handler
    
    func getCoinValues() {
        self.loader.isHidden = false
        self.viewModel.showCoinWorth()
        self.observeEvent()
    }
    
    // MARK: - Get Wallet
    
    func Cash_Out_request() {
        self.loader.isHidden = false
        
        //        ApiHandler.sharedInstance.coinWithDrawRequest(user_id: UserDefaultsManager.shared.user_id, amount: Int(self.strprice)) { isSuccess, response in
        //            if isSuccess {
        //                self.loader.isHidden = true
        //                print(response)
        //                if response?.value(forKey: "code") as! NSNumber == 201 {
        //                    self.alertModule(title: "Error", msg: response?.value(forKey: "msg") as! String)
        //                    return
        //                }
        //                UserDefaultsManager.shared.wallet = "0"
        //                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        //                self.navigationController?.isNavigationBarHidden = true
        //                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        //
        //            } else {
        //                self.loader.isHidden = true
        //                print("failed: ", response as Any)
        //            }
        //        }
    }
    
    func observeEvent() {
        self.viewModel.eventHandler = { [weak self] event in
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
                    self.loader.isHidden = true
                }
            case .purchaseCoin(purchaseCoin: let purchaseCoin): break
            case .showCoinWorth(showCoinWorth: let showCoinWorth):
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    let coinWorth = showCoinWorth.msg?.coinWorth.price ?? 0
                    let walletBalance = UserDefaultsManager.shared.wallet.toDouble() ?? 0.0

                    let totalCash = walletBalance * coinWorth
                    let strPrice = walletBalance * coinWorth
                        
                    // Update the label with formatted price
                    self.lblTotalCash.text = String(format: "$ %.2f", strPrice)
                        
                    // Configure the cashout button state
                    let isCashOutEnabled = totalCash > 0
                    self.btnCashOut.isEnabled = isCashOutEnabled
                    self.btnCashOut.backgroundColor = UIColor.appColor(isCashOutEnabled ? .theme : .buttonColor)
                    self.btnCashOut.setTitleColor(UIColor.appColor(isCashOutEnabled ? .white : .black), for: .normal)
                }
            }
        }
    }
}
