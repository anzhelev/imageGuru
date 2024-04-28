//
//  imageGuruUITests.swift
//  imageGuruUITests
//
//  Created by Andrey Zhelev on 28.04.2024.
//
import XCTest

final class imageGuruUITests: XCTestCase {
    private let app = XCUIApplication()
    
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
        loginTextField.typeText("e-mail") // ! сюда подставить свой е-мейл
        app.children(matching: .window).element(boundBy: 0).tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 7))
        
        passwordTextField.tap()
        passwordTextField.typeText("******") // ! сюда подставить свой пароль
        app.children(matching: .window).element(boundBy: 0).tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
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
        
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["backwardButton"]
        print("CONSOLE: ", app.buttons)
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(2)
        
        // ! сюда подставить свои данные пользователя
        XCTAssertTrue(app.staticTexts["User Name"].exists)
        XCTAssertTrue(app.staticTexts["@userlogin"].exists)
        
        sleep(1)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Чао какао!"].scrollViews.otherElements.buttons["Угу"].tap()
    }
}
