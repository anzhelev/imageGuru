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
    func activityIndicator(show: Bool) { }
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
    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) { }
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
    
    func testGetPhotoCount() {
        let presenter = ImagesListPresenter()
        presenter.imagesListService.addMockPhotosForTests()
        presenter.viewDidLoad()
                
        XCTAssertEqual(presenter.getPhotosCount(), 5)
    }
    
    func testCleanPhotos() {
        let presenter = ImagesListPresenter()
        presenter.imagesListService.addMockPhotosForTests()
        presenter.viewDidLoad()

        presenter.cleanPhotos()
        XCTAssertEqual(presenter.getPhotosCount() , 0)
    }
    
    func testUpdateTableViewAnimatedIsCalled() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.viewDidLoad()

        presenter.cleanPhotos()
        presenter.imagesListService.addMockPhotosForTests()
        NotificationCenter.default.post(name: .imageListUpdated,
                                        object: self)
        
        XCTAssert(viewController.updateTableViewAnimatedIsCalled)
    }
    
    func testGetSingleImageUrl() {
        let presenter = ImagesListPresenter()
        presenter.imagesListService.addMockPhotosForTests()
        presenter.viewDidLoad()
        
        var singleImageUrl: URL?
        singleImageUrl = presenter.getSingleImageUrl(for: 0)
        
        XCTAssert(singleImageUrl != nil)
    }
    
    func testGetCellHeight() {
        let presenter = ImagesListPresenter()
        presenter.imagesListService.addMockPhotosForTests()
        presenter.viewDidLoad()
        let indexPath = IndexPath(row: 1, section: 0)
        let photoWidth = presenter.imagesListService.photos[indexPath.row].size.width
        let photoHeight = presenter.imagesListService.photos[indexPath.row].size.height
        let insets = presenter.cellImageInsets

        let cellHeight = presenter.getCellHeight(
            indexPath: indexPath,
            tableBoundsWidth: photoWidth + insets.left + insets.right
        )
        
        XCTAssertEqual(cellHeight, photoHeight + insets.top + insets.bottom)
    }
}
