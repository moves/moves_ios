//
//  MyWalletViewModel.swift
//  Moves
//
//  Created by Wasiq Tayyab on 19/10/2024.
//

import Foundation

final class MyWalletViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func purchaseCoin(parameter: PurchaseCoinRequest) {
        APIManager.shared.request(
            modelType: PurchaseCoinResponse.self,
            type: ProductEndPoint.purchaseCoin(purchaseCoin: parameter)) { result in
                switch result {
                case .success(let purchaseCoin):
                    self.eventHandler?(.purchaseCoin(purchaseCoin: purchaseCoin))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showCoinWorth() {
        APIManager.shared.request(
            modelType: CoinWorthResponse.self,
            type: ProductEndPoint.showCoinWorth){ result in
                switch result {
                case .success(let showCoinWorth):
                    self.eventHandler?(.showCoinWorth(showCoinWorth: showCoinWorth))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func withdrawRequest(parameter: CoinWithDrawRequest) {
        APIManager.shared.request(
            modelType: CoinWorthResponse.self,
            type: ProductEndPoint.coinWithDrawRequest(coinWithDrawRequest: parameter)){ result in
                switch result {
                case .success(let showCoinWorth):
                    self.eventHandler?(.showCoinWorth(showCoinWorth: showCoinWorth))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}


extension MyWalletViewModel {
    enum Event {
        case error(Error?)
        case purchaseCoin(purchaseCoin: PurchaseCoinResponse)
        case showCoinWorth(showCoinWorth: CoinWorthResponse)
    }
}

