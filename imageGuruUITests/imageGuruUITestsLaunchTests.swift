//
//  imageGuruUITestsLaunchTests.swift
//  imageGuruUITests
//
//  Created by Andrey Zhelev on 28.04.2024.
//
import XCTest

final class imageGuruUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
