//
//  Utilities.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation
import UIKit

func getIOSVersion() -> String{
    return "iOS " + UIDevice.current.systemVersion
}


func getIPhoneModel() -> String{
    return UIDevice().type.rawValue
}


public enum Model : String {

    case simulator     = "simulator",

    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6Plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6SPlus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7Plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8Plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    iPhone11           = "iPhone 11",
    iPhone11Pro        = "iPhone 11 Pro",
    iPhone11ProMax     = "iPhone 11 Pro Max",
    iPhoneSE2          = "iPhone SE 2",
    iPhone12Mini       = "iPhone 12 Mini",
    iPhone12           = "iPhone 12",
    iPhone12Pro        = "iPhone 12 Pro",
    iPhone12ProMax     = "iPhone 12 Pro Max",
    iPhone13Mini       = "iPhone 13 Mini",
    iPhone13           = "iPhone 13",
    iPhone13Pro        = "iPhone 13 Pro",
    iPhone13ProMax     = "iPhone 13 Pro Max",
    unrecognized       = "unrecognized"
}

public extension UIDevice {

    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }

        let modelMap : [String: Model] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6Plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax,
            "iPhone14,4" : .iPhone13Mini,
            "iPhone14,5" : .iPhone13,
            "iPhone14,2" : .iPhone13Pro,
            "iPhone14,3" : .iPhone13ProMax
    ]

        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}

func getPhoneDate() -> String{
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter.string(from: now)
}

public extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

public extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

func identifierForVendor() -> String{
    guard let id = UIDevice.current.identifierForVendor?.uuidString
    else {return ""}
    return id
}

func getAllLanguages() -> [String]{
    return ["en-au"]
}

func getCurrentLanguage() -> String{
    let language = Locale.current.languageCode;
    let country = Locale.current.regionCode;
    let lang = "\(language ?? "en")-\(country?.lowercased() ?? "au")"
    let allLangs = getAllLanguages()
    if allLangs.contains(lang){
        return lang
    }
    else{
    return "en-au"
    }
}
