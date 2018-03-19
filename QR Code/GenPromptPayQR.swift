//
//  GenPromptPayQR.swift
//  QR Code
//
//  Created by Saran Pinpan on 22/2/18.
//  Copyright © 2018 Saran Pinpan. All rights reserved.
//

import Foundation

struct GenPromptPayQR: Codable {
    private static let ID_PAYLOAD_FORMAT:String = "00";
    private static let ID_POI_METHOD:String = "01";
    private static let ID_MERCHANT_INFORMATION_BOT:String = "29";
    private static let ID_MERCHANT_BILL_PAY:String = "30";
    private static let ID_MERCHANT_CATEGORY_CODE:String = "52";
    private static let ID_TRANSACTION_CURRENCY:String = "53";
    private static let ID_TRANSACTION_AMOUNT:String = "54";
    private static let ID_COUNTRY_CODE:String = "58";
    private static let ID_MERCHANT_NAME:String = "59";
    private static let ID_MERCHANT_CITY:String = "60";
    private static let ID_ADDITIONAL_DATA:String = "62";
    private static let ID_CRC:String = "63";
    
    private static let PAYLOAD_FORMAT_EMV_QRCPS_MERCHANT_PRESENTED_MODE:String = "01";
    private static let POI_METHOD_STATIC:String = "11";
    private static let POI_METHOD_DYNAMIC:String = "12";
    private static let MERCHANT_CODE_TYPE:String = "5651";
    private static let MERCHANT_INFORMATION_TEMPLATE_ID_GUID:String = "00";
    private static let BOT_ID_MERCHANT_PHONE_NUMBER:String = "01";
    private static let BOT_ID_MERCHANT_TAX_ID:String = "02";
    private static let BOT_ID_MERCHANT_EWALLET_ID:String = "03";
    private static let GUID_PROMPTPAY:String = "A000000677010111";
    private static let TRANSACTION_CURRENCY_THB:String = "764";
    private static let COUNTRY_CODE_TH:String = "TH";
    
    //Bill payment
    private static let AID_ID:String = "00";
    private static let AID_BILLPAY:String = "A000000677010112";
    private static let BILLER_ID:String = "01";
    private static let REF_1:String = "02";
    private static let REF_2:String = "03";
    private static let REF_ADTN_ID:String = "05";
    private static let TERMINAL_ID:String = "07";
    
    public static func genPromptpay(target: String , amount: String) -> String {
        let typePP: String = targetTypePP(target: target)
        let TAG_29:[String] = [
            tagConcat(id: MERCHANT_INFORMATION_TEMPLATE_ID_GUID, value: GUID_PROMPTPAY),
            tagConcat(id: typePP, value:formatTarget(id: target))
        ]
//        print("TAG29: \(TAG_29)")
//        print("SumTAG29: \(sumStr(value: TAG_29))")

        let RESULT_PP:[String] = [
            tagConcat(id: ID_PAYLOAD_FORMAT, value: PAYLOAD_FORMAT_EMV_QRCPS_MERCHANT_PRESENTED_MODE),
            tagConcat(id: ID_POI_METHOD, value: amount.isEmpty ? POI_METHOD_DYNAMIC : POI_METHOD_STATIC),
            tagConcat(id: ID_MERCHANT_INFORMATION_BOT, value: sumStr(value: TAG_29)),
            tagConcat(id: ID_MERCHANT_CATEGORY_CODE, value: MERCHANT_CODE_TYPE),
            tagConcat(id: ID_COUNTRY_CODE, value: COUNTRY_CODE_TH),
            tagConcat(id: ID_TRANSACTION_CURRENCY, value: TRANSACTION_CURRENCY_THB),
            tagConcat(id: ID_TRANSACTION_AMOUNT, value: formatAmount(amount: amount)),
            tagConcat(id: ID_ADDITIONAL_DATA, value: "")
        ]
//        print(RESULT_PP)
        
        let sumPP = sumStr(value: RESULT_PP) + ID_CRC + "04"
        
        return sumPP + CRC16.getCRC(input: sumPP)
    }
    
    public static func genBillpay(amount: String, billerId:String, ref1:String, ref2:String, ref3:String) -> String {
    
        let TAG_30:[String] = [
            tagConcat(id: AID_ID, value: AID_BILLPAY),
            tagConcat(id: BILLER_ID, value: billerId),
            tagConcat(id: REF_1, value: ref1),
            tagConcat(id: REF_2, value: ref2)
    ]
    
        let TAG_62:[String] = [
            tagConcat(id: REF_ADTN_ID, value: ref1),
            tagConcat(id: TERMINAL_ID, value: ref3)
    ]
    
        let RESULT_PP:String = tagConcat(id: ID_PAYLOAD_FORMAT, value: PAYLOAD_FORMAT_EMV_QRCPS_MERCHANT_PRESENTED_MODE)
            + tagConcat(id: ID_POI_METHOD, value: amount.isEmpty ? POI_METHOD_DYNAMIC : POI_METHOD_STATIC)
            + tagConcat(id: ID_MERCHANT_BILL_PAY, value: sumStr(value: TAG_30))
            + tagConcat(id: ID_MERCHANT_CATEGORY_CODE, value: MERCHANT_CODE_TYPE)
            + tagConcat(id: ID_COUNTRY_CODE, value: COUNTRY_CODE_TH)
            + tagConcat(id: ID_TRANSACTION_CURRENCY, value: TRANSACTION_CURRENCY_THB)
            + tagConcat(id: ID_TRANSACTION_AMOUNT, value: formatAmount(amount: amount))
            + tagConcat(id: ID_ADDITIONAL_DATA, value: sumStr(value: TAG_62))
    
        let sumBP:String = RESULT_PP + ID_CRC + "04";
        return sumBP + CRC16.getCRC(input: sumBP)
    }
    
    public static func formatAmount (amount:String) -> String {
        var pp_amount = ""
        if amount.count > 0{
            if amount.contains(".") {
                let index = amount.index(of: ".")!
                let addDecimal = amount + "00"
                let subAmount = String(addDecimal.prefix(upTo: index))
                let newAmount = String(addDecimal[index...])
                let toFloat = String(format: "%.2f", (newAmount as NSString).floatValue)
                pp_amount = subAmount + String(toFloat[index...])
            } else {
                pp_amount = amount + ".00"
            }
        }
        
        return pp_amount
    }
    
    public static func tagConcat(id:String, value:String) -> String {
        if value == "" {
            return ""
        }
        
        if value.isEmpty {
            return value
        }
        
        let data:String = value.trimmingCharacters(in: .whitespaces)
        let sum:String = "00" + data
        let index = sum.index(sum.startIndex, offsetBy: 2)
        let subValue = sum[index...]
        
        return id + zero(value: String(subValue.count)) + data
        
    }
    
    public static func zero(value:String) -> String {
        return value.count == 1 ? "0" + value : value
    }
    
    public static func targetTypePP(target:String) -> String {
        if target.count >= 15 {
            return BOT_ID_MERCHANT_EWALLET_ID
        } else if target.count >= 13 {
            return BOT_ID_MERCHANT_TAX_ID
        } else {
            return BOT_ID_MERCHANT_PHONE_NUMBER
        }
    }
    
    public static func formatTarget(id:String) -> String {
        let numbers:String = id
        if (numbers.count >= 13) {
            return numbers
        }
        let index = numbers.index(numbers.startIndex, offsetBy: 1)
        let chkSum = ("0066" + numbers[index...])
        
        return chkSum
    }
    
    public static func sumStr(value:[String]) -> String {
        var sumPP:String = ""
        
        for i in 0..<value.count {
            sumPP += value[i]
        }
        
    return sumPP;
    }
    
    public static func parseInt(number:String) -> Int {
        return (number as NSString).integerValue
    }
    
    //todo is check promptpay code
//    public static func isStandardThaiQr(qrValue:String) -> Bool {
//        // let length:Int = qrValue.count
//        // let index:Int = qrValue.count - 4
//
////        if length < 4
////        {
////            return false
////        }
//
//        var newIndex:Int = 0
//        var lengthValue:Int = 0
//        print("value: \(qrValue.count-4)")
//
////        for var i in 0 ..< (qrValue.count - 4) {
////            // print(i)
////            newIndex = i + 4
////
////            let subIndex = qrValue.index(qrValue.startIndex, offsetBy: 2)
////            print("suffix: \(qrValue.dropFirst(newIndex-2))")
////
////            lengthValue = (qrValue.suffix(from: subIndex) as NSString).integerValue
////            // lengthValue = Integer.parseInt(qrValue.substring(newIndex - 2, newIndex));
////            i = newIndex + lengthValue - 1
////
//////            if i + 1 == length {
//////                return true
//////            } else if i + 1 > length {
//////                return false
//////            }
////        }
////        return false
//
//        var i = 0
//        while i < (qrValue.count - 4) {
//            newIndex = i + 4
//
//            // let subIndex = qrValue.index(qrValue.startIndex, offsetBy: 2)
//            let first = qrValue.dropFirst(newIndex-2)
//            let result = first.dropLast(qrValue.count-newIndex)
//            print("result: \(result)")
//
//            lengthValue = (result as NSString).integerValue
//            print("length: \(lengthValue)")
//
//            // lengthValue = Integer.parseInt(qrValue.substring(newIndex - 2, newIndex));
//            i = newIndex + lengthValue - 1;
//            print("i: \(i)")
//
//            if i + 1 == qrValue.count {
//                return true
//
//            } else if i + 1 > qrValue.count {
//                return false
//            }
//        }
//        return false
//    }
    
    public static func decode(value:String) -> String {
    
    //if (!isFormatCRC(value)) return "CRC Invalid";
    //else if (!isStandardThaiQr(value)) return "Format Error";
    
        var result:String = "";
        var tag:String = "";
        var tagValue:String = "";
        var newIndex:Int
        var subIndex:Int
        var chkIndex:Int
        var i = 0
        for _ in i ..< value.count - 4 {
            newIndex = i + 4
            let subValue = value.dropFirst(i)
            tag = String(subValue.dropLast(newIndex - 2))
            let subValue2 = value.dropFirst(newIndex - 2)
            subIndex = (subValue2.dropLast(newIndex) as NSString).integerValue
            chkIndex = newIndex + subIndex
            
            if chkIndex > value.count {
                let subValue3 = value.dropFirst(newIndex)
                tagValue = String(subValue3.dropLast(value.count))
            } else {
                let subValue4 = value.dropFirst(newIndex)
                tagValue = String(subValue4.dropLast(newIndex + subIndex))
            }
            
            if (isTag(tag: tag, chk: "29") || isTag(tag: tag, chk: "30") || isTag(tag: tag, chk: "31") || isTag(tag: tag, chk: "62") || isTag(tag: tag, chk: "80")) {
                let getData:[String] = subDataDecode(tagId: tag, value: tagValue);
                result += "{"
                    + "\"tag\":\"" + tag + "\","
                    + "\"desc\":\"" + tagInfo(tag: tag) + "\","
                    + "\"qtyData\":" + getData[1] + ","
                    + "\"data\":[" + getData[0] + "]"
                    + "},"
            } else {
//                result += "{"
//                    + "\"tag\":\"" + tag + "\","
//                    + "\"desc\":\"" + tagInfo(tag: tag) + "\","
//                    + "\"qtyData\":" + 0 + ","
//                    + "\"data\":\"" + tagValue + "\""
//                    + "},"
            }
            
            i = newIndex + subIndex - 1
        }
        
        var verifyResult:String = String(result.dropLast(result.count - 1))
        verifyResult = "[" + verifyResult + "]"
        
        return verifyResult
    }
    
    public static func subDataDecode(tagId:String, value:String) -> [String] {
        var result:String = ""
        var tag:String = ""
        var tagValue:String = ""
        var newIndex:Int
        var subIndex:Int
        var chkIndex:Int
    
        var sum:Int = 0
        var i = 0
        for _ in i ..< value.count - 4 {
            newIndex = i + 4
            let subValue = value.dropFirst(i)
            tag = String(subValue.dropLast(newIndex - 2))
            let subValue2 = value.dropFirst(newIndex - 2)
            subIndex = (subValue2.dropLast(newIndex) as NSString).integerValue
            chkIndex = newIndex + subIndex
            
            if (chkIndex > value.count) {
                tagValue = String(value.dropLast(value.count))
            } else {
                let subValue3 = value.dropFirst(newIndex)
                tagValue = String(subValue3.dropLast(newIndex + subIndex))
            }
    
            result += "{"
                + "\"subTag\":\"" + tag + "\","
                + "\"subDesc\":\"" + subTagInfo(tag: tagId, subTag: tag) + "\","
                + "\"subValue\":\"" + tagValue + "\"" +
            "},"
            sum += 1
            i = newIndex + subIndex - 1
        }
    
        var verifyResult:String = result
        
        do {
            verifyResult = String(result.dropLast(result.count - 1))
        }
    
        let ss:[String] = [verifyResult, String(sum)]
    
        return ss
    }
    
    public static func tagInfo(tag:String) -> String {
        var desc:String = "Unknown"
        
        if tag == "00" {
            desc = "PayloadFormatVersion"
        } else if tag == "01" {
            desc = "PointOfInitiationMethod"
        } else if tag == "29" {
            desc = "MccIdentifier"
        } else if tag == "30" {
            desc = "MccIdentifier"
        } else if tag == "31" {
            desc = "MccIdentifier"
        } else if tag == "52" {
            desc = "MccCategoryCode"
        } else if tag == "53" {
            desc = "CurrencyCode"
        } else if tag == "54" {
            desc = "Amount"
        } else if tag == "58" {
            desc = "CountryCode"
        } else if tag == "62" {
            desc = "AddData"
        } else if tag == "63" {
            desc = "crc"
        } else if (tag as NSString).integerValue >= 2 && (tag as NSString).integerValue <= 28 {
            desc = "MccInformation"
        } else if (tag as NSString).integerValue >= 32 && (tag as NSString).integerValue <= 51 {
            desc = "ReservedForAdditionalPaymentNetworks"
        } else if (tag as NSString).integerValue >= 65 && (tag as NSString).integerValue <= 79 {
            desc = "RFUForEMVCo"
        }
    
        return desc
    }
    
    public static func subTagInfo(tag:String, subTag:String) -> String {
        var desc:String = "unknown"
        
        switch (tag) {
        case "29":
            if isTag(tag: subTag, chk: "00") {
                desc = "Aid"
            } else if isTag(tag: subTag, chk: "01") {
                desc = "MobileNumber"
            } else if isTag(tag: subTag, chk: "02") {
                desc = "CitizenId"
            } else if isTag(tag: subTag, chk: "03") {
                desc = "EWalletId"
            } else if isTag(tag: subTag, chk: "04") {
                desc = "BankAcc"
            }
            return desc
            
        case "30":
            if isTag(tag: subTag, chk: "00") {
                desc = "Aid"
            } else if isTag(tag: subTag, chk: "01") {
                desc = "BillerId"
            } else if isTag(tag: subTag, chk: "02") {
                desc = "Ref1"
            } else if isTag(tag: subTag, chk: "03") {
                desc = "Ref2"
            }
            return desc
            
        case "31":
            if isTag(tag: subTag, chk: "00") {
                desc = "Aid"
            } else if isTag(tag: subTag, chk: "01") {
                desc = "AcquirerId"
            } else if isTag(tag: subTag, chk: "02") {
                desc = "CitizenId"
            } else if (subTag as NSString).integerValue >= 2 && (subTag as NSString).integerValue <= 99 {
                desc = "AcquirerSpec"
            }
            return desc
            
        case "62":
            if isTag(tag: subTag, chk: "01") {
                desc = "BillNumber"
            } else if isTag(tag: subTag, chk: "02") {
                desc = "MobileNumber"
            } else if isTag(tag: subTag, chk: "03") {
                desc = "StoreID"
            } else if isTag(tag: subTag, chk: "04") {
                desc = "LoyaltyNumber"
            } else if isTag(tag: subTag, chk: "05") {
                desc = "ReferenceID"
            } else if isTag(tag: subTag, chk: "06") {
                desc = "CustomerID"
            } else if isTag(tag: subTag, chk: "07") {
                desc = "TerminalID"
            } else if isTag(tag: subTag, chk: "08") {
                desc = "PurposeOfTransaction"
            } else if isTag(tag: subTag, chk: "09") {
                desc = "AdditionalConsumerDataRequest"
            }
            return desc
            
        case "80":
            if isTag(tag: subTag, chk: "00") {
                desc = "SellerTax";
            } else if isTag(tag: subTag, chk: "01") {
                desc = "VatRate";
            } else if isTag(tag: subTag, chk: "02") {
                desc = "VatAmount";
            }
            return desc
            
        default:
            return desc
        }
    }
    
    public static func isTag(tag:String, chk:String) -> Bool {
        return tag == chk ? true : false
    }

}
