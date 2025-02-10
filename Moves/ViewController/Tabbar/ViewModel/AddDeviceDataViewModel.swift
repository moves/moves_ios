//
//  AddDeviceDataViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 10/05/2024.
//

import Foundation

final class AddDeviceDataViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func addDeviceData(parameters: AddDeviceDataRequest) {
        APIManager.shared.request(
            modelType: AddDeviceDataResponse.self,
            type: ProductEndPoint.addDeviceData(addDeviceData: parameters)) { result in
                switch result {
                case .success(let addDeviceData):
                    self.eventHandler?(.newAddDeviceData(addDeviceData: addDeviceData))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func registerDevice(parameters: RegisterDeviceRequest) {
    APIManager.shared.request(
            modelType: RegisterDeviceResponse.self,
            type: ProductEndPoint.registerDevice(registerDevice: parameters)) { result in
                switch result {
                case .success(let registerDevice):
                    self.eventHandler?(.newRegisterDevice(registerDevice: registerDevice))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension AddDeviceDataViewModel {
    enum Event {
        case error(Error?)
        case newAddDeviceData(addDeviceData: AddDeviceDataResponse)
        case newRegisterDevice(registerDevice: RegisterDeviceResponse)
    }
}
