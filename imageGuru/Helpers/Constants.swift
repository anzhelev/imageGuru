//
//  Constants.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 02.03.2024.
//
import Foundation

enum Constants {
    static let accessKey = "7X0Xb-7BJ4O97VjzUIQUxum5eXDYVM65-nd9mEMKmew"
    static let secretKey = "5YRMeSBi9_ABw2iv_uBqRvAQ_xIKIxF2228UtGWAhTU"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let imageServiceRequestUrl = "https://api.unsplash.com/photos"
    static let userProfileImageRequestUrl = "https://api.unsplash.com/users"
}
