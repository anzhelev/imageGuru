//
//  imageGuruUITests.swift
//  imageGuruUITests
//
//  Created by Andrey Zhelev on 28.04.2024.
//
import XCTest

final class imageGuruUITests: XCTestCase {
    private let app = XCUIApplication()
    
    // введите ваши данные для авторизации
    enum User: String {
        case email = "mailfor@unsplash.com"
        case password = "Y0uRpAs5w0rD"
        case profileName = "Your Name"
        case login = "@yourlogin"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(User.email.rawValue)
        app.toolbars.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(User.password.rawValue)
        app.toolbars.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 7))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
        _ = cell.waitForExistence(timeout: 5)
        
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.descendants(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["favoritesButton"].tap()
        
        sleep(3)
        
        cellToLike.buttons["favoritesButton"].tap()
        
        sleep(3)
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        _ = image.waitForExistence(timeout: 5)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["backwardButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(2)
        
        XCTAssertTrue(app.staticTexts[User.profileName.rawValue].exists)
        XCTAssertTrue(app.staticTexts[User.login.rawValue].exists)
        
        sleep(3)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Чао какао!"].scrollViews.otherElements.buttons["Угу"].tap()
    }
}
