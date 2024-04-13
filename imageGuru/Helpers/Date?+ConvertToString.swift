//
//  Date+ConvertToString.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.04.2024.
//

import Foundation

extension Date? {
    func convertToStringRu() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMMM yyyy"
        df.locale = Locale(identifier: "ru_RU")
        return df.string(from: self ?? Date())
    }
}
