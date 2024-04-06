//
//  NotificationName+Extention.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 31.03.2024.
//

import Foundation

extension Notification.Name {
    static let userImageUrlUpdated = Notification.Name(rawValue: "userImageUrlUpdated")
    static let imageListUpdated = Notification.Name(rawValue: "ImagesListServiceDidChange")
}
