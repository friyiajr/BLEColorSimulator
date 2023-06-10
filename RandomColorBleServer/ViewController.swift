//
//  ViewController.swift
//  RandomColorBleServer
//
//  Created by Daniel Friyia on 2023-06-10.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var appBackground: UIView!
  
  let kRandomColorServiceUUID =
    "96e4d99a-066f-444c-b67c-112345e3b1a2".uppercased()
  let kNotifyRandomColorCharactaristicUUID =
    "7c0209c0-93f0-437a-828a-a58379b230c4".uppercased()
  let kReadRandomColorCharactaristicUUID =
    "3d84e60b-90d0-40d4-993a-1b83424cb868".uppercased()
  let kWriteRandomColorCharactaristicUUID =
    "1b3dcc2d-cc56-4b47-b6c2-13745858c7df".uppercased()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    BleAdvertiser.shared
  }
  
  @IBAction func onSendColorPressed(_ sender: Any) {
    let color = "#\(generateRandomPalette(amount: 1)[0])"
    BleAdvertiser.shared.sendNotifyValue(
      charactaristicUuid: kNotifyRandomColorCharactaristicUUID,
      base64Response: color
    )
  }
  
  @IBAction func onScanForDevicesPressed(_ sender: Any) {
    configureCharactaristicsAndServices()
    BleAdvertiser.shared.startAdvertising(deviceName: "iPhone")
  }
  
  func configureCharactaristicsAndServices() {
    BleAdvertiser.shared.addService(
      serviceUUID: kRandomColorServiceUUID,
      charactaristicConfigs: [
        [
          "uuid": kNotifyRandomColorCharactaristicUUID,
          "properties": ["NOTIFY"],
          "permissions": ["READABLE", "WRITABLE"]
        ],
        [
          "uuid": kReadRandomColorCharactaristicUUID,
          "properties": ["READ"],
          "permissions": ["READABLE"]
        ],
        [
          "uuid": kWriteRandomColorCharactaristicUUID,
          "properties": ["WRITE"],
          "permissions": ["WRITABLE"]
        ]
      ]
    )
    
    BleAdvertiser.shared.setReadValueForCharactaristic(
      charactaristicUuid: kReadRandomColorCharactaristicUUID,
      base64Response: "#00FF00"
    )
    
    BleAdvertiser.shared.setListener(eventDispatcher: { newValue in
      self.appBackground.backgroundColor = hexStringToUIColor(hex: newValue)
    })
  }
}

/* Randomly choose if number of letter, then randomly give
 back a value */
func randomCharacter() -> String? {
  let numbers = [0,1,2,3,4,5,6, 7, 8, 9]
  let letters = ["A","B","C","D","E","F"]
  
  let numberOrLetter = arc4random_uniform(2)
  
  switch numberOrLetter {
    case 0: return String(numbers[Int(arc4random_uniform(10))])
    case 1: return letters[Int(arc4random_uniform(6))]
    default: return nil
  }
}


func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

/* Translate a character array of a color to a string
 representing a HEX*/
func characterArrayToHexString(array: [String]) -> String {
  var hexString = ""
  for character in array {
    hexString += character
  }
  return hexString
}

// Generate a random color in HEX
func generateRandomColor() -> String {
  var characterArray: [String] = []
  for _ in 0...5 {
    characterArray.append(randomCharacter()!)
  }
  return characterArrayToHexString(array: characterArray)
}

// Generate an palette (array) of random HEX colors
func generateRandomPalette(amount: Int) -> [String] {
  var colors: [String] = []
  for _ in 0...amount - 1 {
    colors.append(generateRandomColor())
  }
  return colors
}

