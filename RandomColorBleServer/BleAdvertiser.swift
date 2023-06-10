//
//  BleAdvertiser.swift
//  BleAdvertiserExpo
//
//  Created by Daniel Friyia on 2023-04-04.
//

import Foundation
import CoreBluetooth

class BleAdvertiser: NSObject, CBPeripheralManagerDelegate, CBPeripheralDelegate {
  
  ///
  /// Static variable representing the shared singleton for BluetoothLeService
  ///
  private static var _sharedInstance: BleAdvertiser!
  
  ///
  /// Peripheral manager used to call various functions with the Device
  ///
  private var peripheralManager : CBPeripheralManager!
  
  ///
  /// An array of all broadcasted services
  ///
  private var serviceCBUUIDs = [CBUUID]()
  
  ///
  /// Sends events to the React-Native side
  ///
  private var eventDispatcher: ((String) -> Void)!
  
  ///
  /// A Map of all available charactaristics
  ///
  private var charactaristics = [String: CBMutableCharacteristic]()
  
  ///
  /// A map of all possible charactaristics and the values they return
  ///
  private var readResponseValues: [String: String] = [:]
  
  ///
  /// init is hidden because this is a singleton
  ///
  private override init() {
    super.init()
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  public func setListener(eventDispatcher: @escaping (String) -> Void) {
    self.eventDispatcher = eventDispatcher
  }
  
  ///
  /// Starts advertising your device to clients with a given name
  ///
  func startAdvertising(deviceName: String) {
    peripheralManager.startAdvertising(
      [
        CBAdvertisementDataLocalNameKey : deviceName,
        CBAdvertisementDataServiceUUIDsKey : serviceCBUUIDs
      ]
    )
  }
  
  ///
  /// Add a service to the peripheral manager to broadcast data
  ///
  public func addService(serviceUUID: String, charactaristicConfigs: [[String: Any?]]) {
    var newCharactaristics = [CharactaristicConfig]()
    for config in charactaristicConfigs {
      if let uuid = config["uuid"] as? String,
         let properties = config["properties"] as? [String],
         let permissions = config["permissions"] as? [String]
      {
        let newCharactaristic = CharactaristicConfig(
          rawUuid: uuid,
          rawProperties: properties,
          rawInitialValue: nil,
          rawPermissions: permissions
        )
        
        newCharactaristics.append(newCharactaristic)
      } else {
        MinLog.e("Passed in an invalid value for addService charactaristic")
      }
    }
    
    addServiceToManager(serviceUUID: serviceUUID, charactaristicConfigs: newCharactaristics)
  }
  
  private func addServiceToManager(serviceUUID: String, charactaristicConfigs: [CharactaristicConfig]) {
      let newCBUUID = CBUUID(nsuuid: UUID(uuidString: serviceUUID)!)
      let newService = CBMutableService(type: newCBUUID, primary: true)
      serviceCBUUIDs.append(newCBUUID)
  
      var newCharacteristics = [CBMutableCharacteristic]()
  
      for config in charactaristicConfigs {
        let newCharacteristic = CBMutableCharacteristic(
          type: config.uuid,
          properties: config.properties,
          value: config.rawInitialValue,
          permissions: config.permissions
        )
        
        charactaristics[config.uuid.uuidString] = newCharacteristic
        newCharacteristics.append(newCharacteristic)
      }
      newService.characteristics = newCharacteristics
      peripheralManager.add(newService)
  }
  
  ///
  /// The current state of the hardware Bluetooth manager
  ///
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
      switch peripheral.state {
      case .unknown:
        MinLog.i("Bluetooth Device is UNKNOWN")
      case .unsupported:
        MinLog.i("Bluetooth Device is UNSUPPORTED")
      case .unauthorized:
        MinLog.i("Bluetooth Device is UNAUTHORIZED")
      case .resetting:
        MinLog.i("Bluetooth Device is RESETTING")
      case .poweredOff:
        MinLog.i("Bluetooth Device is POWERED OFF")
      case .poweredOn:
        MinLog.i("Bluetooth Device is POWERED ON")
      @unknown default:
        MinLog.i("Unknown State")
      }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    for request in requests {
      if let responseValue = request.value {
        eventDispatcher(String(decoding: responseValue, as: UTF8.self))
      }
      peripheral.respond(to: request, withResult: CBATTError.Code.success)
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    let responseUUID = request.characteristic.uuid.uuidString
    if let responseValue = readResponseValues[responseUUID] {
      request.value = responseValue.data(using: .utf8)!
      peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
    }
  }
  
  ///
  /// Sends Data as a Base64 to a subscriber
  ///
  func sendNotifyValue(charactaristicUuid: String, base64Response: String) {
      self.peripheralManager.updateValue(
          base64Response.data(using: .utf8)!,
          for: charactaristics[charactaristicUuid]!,
          onSubscribedCentrals: nil
      )
  }
  
  ///
  /// Set the value you want to return whenever there is a read request
  ///
  func setReadValueForCharactaristic(charactaristicUuid: String, base64Response: String) {
    readResponseValues[charactaristicUuid] = base64Response
  }
  
  ///
  /// Singelton Shared instance of the Bluetooth LE Service
  ///
  public static let shared: BleAdvertiser = {
      if _sharedInstance == nil {
          _sharedInstance = BleAdvertiser()
      }
      return _sharedInstance
  }()
}
