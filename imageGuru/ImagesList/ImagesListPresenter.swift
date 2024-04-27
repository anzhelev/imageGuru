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
    func changeLike(for cell: ImagesListCell, in tableView: UITableView)
    func getFavoriteButtonImage(for cellIndex: IndexPath) -> UIImage?
    func getCellHeight(indexPath: IndexPath, tableBoundsWidth: CGFloat) -> CGFloat
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: ImagesListCellDelegate) -> UITableViewCell
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    let imagesListService = ImagesListService.imagesListService
    
    // MARK: - Private Properties
    private let dateToStringFormatter = DateFormatter()
    private var photos: [Photo] = []
    private var ImagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        dateToStringFormatter.dateFormat = "dd MMMM yyyy"
        dateToStringFormatter.locale = Locale(identifier: "ru_RU")
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
    func changeLike (for cell: ImagesListCell, in tableView: UITableView) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoIndex: indexPath.row) {[weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let like):
                guard let favoriteImage = UIImage(named: like ? "favorites_active" : "favorites_no_active") else {
                    return
                }
                cell.setFavoriteButtonImage(image: favoriteImage)
                print("CONSOLE func changeLike: изменен лайк для фото",
                      self?.photos[indexPath.row].id ?? "",
                      self?.photos[indexPath.row].welcomeDescription ?? "")
            case .failure(let error):
                print("CONSOLE func changeLike:", error.localizedDescription)
            }
        }
    }
    
    /// настраиваем внешний вид кнопки Лайк в соответствии с текущим статусом
    func getFavoriteButtonImage(for indexPath: IndexPath) -> UIImage? {
        return UIImage(named: self.photos[indexPath.row].isLiked ? "favorites_active" : "favorites_no_active")
    }
    
    /// функция расчета высоты ячейки по соотношению сторон фото
    func getCellHeight(indexPath: IndexPath, tableBoundsWidth: CGFloat) -> CGFloat {
        guard photos.count > 0 else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableBoundsWidth - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
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
                                favoriteButtonImage: getFavoriteButtonImage(for: indexPath)) {[weak tableView] in
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
