//
//  Date+Ex.swift
//  NewsApp
//
//  Created by Дарья Астапова on 19.03.21.
//
import Foundation

extension Date {
    func formatDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
