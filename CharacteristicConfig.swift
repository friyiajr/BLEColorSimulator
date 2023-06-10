//
//  Charactaristic.swift
//  BleAdvertiserExpo
//
//  Created by Daniel Friyia on 2023-04-05.
//

import Foundation
import CoreBluetooth

struct CharactaristicConfig {
  var rawUuid: String
  var rawProperties = [String]()
  var rawInitialValue: Data? = nil
  var rawPermissions = [String]()
  
  var uuid: CBUUID {
    return CBUUID(nsuuid: UUID(uuidString: rawUuid)!)
  }
  
  var properties: CBCharacteristicProperties {
    var properties = CBCharacteristicProperties()
    
    for rawProperty in rawProperties {
      switch rawProperty {
      case "NOTIFY":
        properties.insert(.notify)
      case "WRITE":
        properties.insert(.write)
      case "READ":
        properties.insert(.read)
      default:
        continue
      }
    }
    
    return properties
  }
  
  var permissions: CBAttributePermissions {
    var newPermissions = CBAttributePermissions()
    
    for rawPermission in rawPermissions {
      switch rawPermission {
      case "READABLE":
        newPermissions.insert(.readable)
      case "WRITABLE":
        newPermissions.insert(.writeable)
      default:
        continue
      }
    }
    
    return newPermissions
  }
}
