//
//  ImagesListTests.swift
//  imageGuruTests
//
//  Created by Andrey Zhelev on 25.04.2024.
//
import XCTest
@testable import imageGuru

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedIsCalled = false
    var presenter: ImagesListPresenterProtocol?
    
    func viewDidLoad() {
        presenter?.viewDidLoad()
    }
    func updateTableViewAnimated(with rangeOfCells: Range<Int>) {
        updateTableViewAnimatedIsCalled.toggle()
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled.toggle()
    }
    func cleanPhotos() { }
    func getPhotosCount() -> Int {
        0
    }
    func getSingleImageUrl(for row: Int) -> URL {
        return Constants.defaultBaseURL!
    }
    func changeLike(for cell: imageGuru.ImagesListCell, in table: UITableView) { }
    func getFavoriteButtonImage(for cellIndex: IndexPath) -> UIImage? {
        UIImage()
    }
    func getCellHeight(indexPath: IndexPath, tableBoundsWidth: CGFloat) -> CGFloat {
        0
    }
    func prepareNewCell(for tableView: UITableView,
                        with indexPath: IndexPath,
                        on viewController: any imageGuru.ImagesListCellDelegate) -> UITableViewCell {
        return UITableViewCell()
    }
}

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        viewController.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewPresenterMethods() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        let expectation = self.expectation(description: "Ждем завершения работы fetchPhotosNextPage")
        presenter.imagesListService.fetchPhotosNextPage {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        
        // тесты объединены в одну функцию, чтобы не дублировать сетевые запросы через imagesListService
        
        // проверка запуска updateTable в Presenter по уведомлению от imagesListService и работу функциии getPhotosCount
        let photoCount = presenter.getPhotosCount()
        XCTAssertEqual(photoCount , 10)
        
        // проверка работы функции getSingleImageUrl
        var singleImageUrl: URL?
        singleImageUrl = presenter.getSingleImageUrl(for: 0)
        XCTAssert(singleImageUrl != nil)
        
        // проверка работы функции cleanPhotos
        presenter.cleanPhotos()
        XCTAssertEqual(presenter.getPhotosCount() , 0)
        
        // Проверяем, происходит ли запуск updateTableViewAnimated на viewController при обновлении массива фото
        presenter.updateTable()
        XCTAssert(viewController.updateTableViewAnimatedIsCalled)
    }
}

