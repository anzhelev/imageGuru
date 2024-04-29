//
//  ProfileViewTests.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.04.2024.
//
import XCTest
@testable import imageGuru

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var logoutIsInitiated: Bool = false
    func profileLogout() {
        logoutIsInitiated.toggle()
    }
    func userImageUrlUpdateMonitor() {}
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    func viewDidLoad() {
        viewDidLoadCalled.toggle()
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var logoutAlert: UIAlertController?
    
    var userLogoutButton: UIButton?
    var profileImageDidSet: Bool = false
    func updateUserImage(url: URL) {
        profileImageDidSet.toggle()
    }
    var configureUIElementsCalled: Bool = false
    var presenter: ProfilePresenterProtocol?
    var profileImageView: UIImageView?
    func configureUIElements(userName: String, userLogin: String, userBio: String) {
        configureUIElementsCalled.toggle()
    }
}

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsConfigureUIElements() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.configureUIElementsCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        NotificationCenter.default.post(name: .userImageUrlUpdated,
                                        object: self,
                                        userInfo: ["URL": Constants.defaultBaseURL ?? ""])
        
        XCTAssertTrue(viewController.profileImageDidSet)
    }
    
    func testLogoutButtonAction() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.configureUIElements(userName: "User", userLogin: "User", userBio: "")
        viewController.userLogoutButton?.sendActions(for: .allTouchEvents)
        
        let alert = viewController.logoutAlert
        XCTAssertTrue(alert != nil)
    }
}
