//
//  String+ConvertToDate.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 07.04.2024.
//
import Foundation

extension String {
    func convertToDate() -> Date? {
        let df = ISO8601DateFormatter()
        guard let date = df.date(from: self) else {
            return nil
        }
        return date
    }
}
