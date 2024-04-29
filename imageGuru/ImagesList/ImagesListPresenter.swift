//
//  ImagesListPresenter.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 22.04.2024.
//
import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func cleanPhotos()
    func getPhotosCount() -> Int
    func getSingleImageUrl(for row: Int) -> URL
    func changeLike (for indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func getCellHeight(indexPath: IndexPath, tableBoundsWidth: CGFloat) -> CGFloat
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: ImagesListCellDelegate) -> UITableViewCell
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    let imagesListService = ImagesListService.imagesListService
    let cellImageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    
    // MARK: - Private Properties
    private let dateToStringFormatter = DateFormatter()
    private var photos: [Photo] = []
    private var ImagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        dateToStringFormatter.dateFormat = "dd MMMM yyyy"
        photos = imagesListService.photos
        
        ImagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: .imageListUpdated,
            object: nil,
            queue: .main
        ) {[weak self] _ in
            self?.updateTable()
        }
    }
    
    /// функция очистки массива фотографий для функции logout
    func cleanPhotos() {
        photos.removeAll()
    }
    
    /// запускаем обновление таблицы при получении новых фото
    func updateTable () {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            self.view?.updateTableViewAnimated(with: oldCount..<newCount)
        }
    }
    
    /// получаем текущее количество фото в массиве
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    /// достаем из массива ссылку на фото в большом разрешении для SingleImageView
    func getSingleImageUrl(for row: Int) -> URL {
        return photos[row].largeImageURL
    }
    
    /// меняем статус Лайк фото по нажатию на соответствующую кнопку
    func changeLike (for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
        view?.activityIndicator(show: true)
        imagesListService.changeLike(photoIndex: indexPath.row) {[weak self] result in
            self?.view?.activityIndicator(show: false)
            switch result {
            case .success(let like):
                completion(like)
                print("CONSOLE func changeLike: изменен лайк для фото",
                      self?.photos[indexPath.row].id ?? "",
                      self?.photos[indexPath.row].welcomeDescription ?? "")
            case .failure(let error):
                print("CONSOLE func changeLike:", error.localizedDescription)
            }
        }
    }
    
    /// функция расчета высоты ячейки по соотношению сторон фото
    func getCellHeight(indexPath: IndexPath, tableBoundsWidth: CGFloat) -> CGFloat {
        guard photos.count > 0 else {
            return 0
        }
        let imageViewWidth = tableBoundsWidth - cellImageInsets.left - cellImageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + cellImageInsets.top + cellImageInsets.bottom
        return cellHeight
    }
    
    /// готовим для отображения новую ячейку с фото
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: ImagesListCellDelegate) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = viewController
        let photo = photos[indexPath.row]
        imageListCell.configure(with: photo.thumbImageURL,
                                date: dateToStringFormatter.string(from: photo.createdAt ?? Date()),
                                isLiked: photo.isLiked) {[weak tableView] in
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
        
        //проверка на необходимость подгрузки следующей страницы фотографий
        if indexPath.row == self.photos.count - 2, imagesListService.task == nil {
            print("CONSOLE func tableView: Достигнут конец ленты")
            self.imagesListService.fetchPhotosNextPage { }
        }
        return imageListCell
    }
}
