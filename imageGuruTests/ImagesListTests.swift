//
//  ImagesListTests.swift
//  imageGuruTests
//
//  Created by Andrey Zhelev on 25.04.2024.
//

import XCTest
@testable import imageGuru

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any imageGuru.ImagesListPresenterProtocol)?
    func updateTableViewAnimated(with rangeOfCells: Range<Int>) {}
    func setGradientLayer(for cell: imageGuru.ImagesListCell) {}
}

final class ImagesListTests: XCTestCase {
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    
    var view: (any imageGuru.ImagesListViewControllerProtocol)?
    
    func viewDidLoad() {
        viewDidLoadCalled.toggle()
    }
    
    func cleanPhotos() {}
    
    func getPhotosCount() -> Int {
        return 0
    }
    
    func getSingleImageUrl(for row: Int) -> URL {
        return Constants.defaultBaseURL!
    }
    
    func changeLike(for cell: imageGuru.ImagesListCell, in table: UITableView) {
        
    }
    
    func getFormattedDate(for cellIndex: IndexPath) -> String {
        return ""
    }
    
    func getFavoriteButtonImage(for cellIndex: IndexPath) -> UIImage? {
        return UIImage()
    }
    
    func getCellHeight(for indexPath: IndexPath, in table: UITableView) -> CGFloat {
        return 0
    }
    
    func setImageWithKF(for cell: imageGuru.ImagesListCell, with indexPath: IndexPath, in table: UITableView) {
        
    }
    
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: any imageGuru.ImagesListCellDelegate) -> UITableViewCell {
        return UITableViewCell()
    }
    

    final class ImagesListTests: XCTestCase {
     
        func testViewControllerCallsViewDidLoad() {
            //given
            let viewController = ImagesListViewController()
            let presenter = ImagesListPresenterSpy()
            viewController.presenter = presenter
            presenter.view = viewController
            
            //when
            _ = viewController.view
            
            //then
            XCTAssertTrue(presenter.viewDidLoadCalled)
        }
        
        
        
        
    }
    
    
}
