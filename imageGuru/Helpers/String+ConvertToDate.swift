//
//  String+ConvertToDate.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 07.04.2024.
//

import Foundation

extension String {
    func convertToDate() -> Date? {
        //        func convertToDate(as dateFormat: String) -> String? {
        //        let df = DateFormatter()
        //        df.dateFormat = dateFormat
        //        return df.date(from: self)
        let df = DateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return df.date(from: self)
        //        let date = df.date(from: self)
        //        df.dateFormat = dateFormat
        //        return df.string(from: date)
    }
}
