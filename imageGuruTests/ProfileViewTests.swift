//
//  ProfileViewTests.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.04.2024.
//

import XCTest
@testable import imageGuru

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    func profileLogout() {}
    func userImageUrlUpdateMonitor() {}
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    func viewDidLoad() {
        viewDidLoadCalled.toggle()
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
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
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsConfigureUIElements() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.configureUIElementsCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        NotificationCenter.default.post(name: .userImageUrlUpdated,
                                        object: self,
                                        userInfo: ["URL": Constants.defaultBaseURL ?? ""])
        
        //then
        XCTAssertTrue(viewController.profileImageDidSet)
    }
}
