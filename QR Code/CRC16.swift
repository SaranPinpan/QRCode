//
//  CRC16.swift
//  CRC16
//
//  Created by LimChihi on 11/30/16.
//  Copyright © 2016 linzhiyi. All rights reserved.
//

import Foundation

class CRC16: Codable {
    public static func getCRC(input : String) -> String{
        var crc = 0xFFFF;          // initial value
        let polynomial = 0x1021;   // 0001 0000 0010 0001  (0, 5, 12)
        let buf: [UInt8] = Array(input.utf8)
        var aStr = ""
        
        for b in buf {
            var i = 0
            while (i < 8){
                let bit = ((b   >> (7-i) & 1) == 1) // boolean
                let c15 = ((crc >> 15    & 1) == 1) // boolean
                crc <<= 1
                if (XORCase(lhs: bit, rhs: c15)){
                    crc ^= polynomial
                }
                i = i + 1
            }
            crc &= 0xffff
            aStr = String(format: "%04x", crc)
            
        }
        return aStr.uppercased()
    }
    
    private static func XORCase(lhs: Bool, rhs: Bool) -> Bool {
        return lhs != rhs
    }
}
