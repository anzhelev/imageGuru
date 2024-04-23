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
    func changeLike(for cell: ImagesListCell, in table: UITableView)
    func getFormattedDate(for cellIndex: IndexPath) -> String
    func getFavoriteButtonImage(for cellIndex: IndexPath) -> UIImage?
    func getCellHeight(for indexPath: IndexPath, in table: UITableView) -> CGFloat
    func setImageWithKF(for cell: ImagesListCell, with indexPath: IndexPath, in table: UITableView)
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: ImagesListCellDelegate) -> UITableViewCell
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    private let dateToStringFormatter = DateFormatter()
    private let imagesListService = ImagesListService.imagesListService
    private var photos: [Photo] = []
    private var ImagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Initializers
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
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
    
    /// получаем текущее количество фото в массиве
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    /// достаем из массива ссылку на фото в большом разрешении для SingleImageView
    func getSingleImageUrl(for row: Int) -> URL {
        return photos[row].largeImageURL
    }
    
    /// меняем статус Лайк фото по нажатию на соответствующую кнопку
    func changeLike (for cell: ImagesListCell, in table: UITableView) {
        guard let indexPath = table.indexPath(for: cell) else {
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
                cell.favoritesButton.setImage(favoriteImage, for: .normal)
                print("CONSOLE func changeLike: изменен лайк для фото",
                      self?.photos[indexPath.row].id ?? "",
                      self?.photos[indexPath.row].welcomeDescription ?? "")
            case .failure(let error):
                print("CONSOLE func changeLike:", error.localizedDescription)
            }
        }
    }
    
    /// получаем строку с датой создания фото в нужном формате
    func getFormattedDate(for cellIndex: IndexPath) -> String {
        return dateToStringFormatter.string(from: self.photos[cellIndex.row].createdAt ?? Date())
    }
    
    /// настраиваем внешний вид кнопки Лайк в соответствии с текущим статусом
    func getFavoriteButtonImage(for cellIndex: IndexPath) -> UIImage? {
        return UIImage(named: self.photos[cellIndex.row].isLiked ? "favorites_active" : "favorites_no_active")
    }
    
    /// функция расчета высоты ячейки по соотношению сторон фото
    func getCellHeight(for indexPath: IndexPath, in table: UITableView) -> CGFloat {
        guard photos.count > 0 else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = table.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    /// функция установки картинки в ячейку с помощью KingFicher
    func setImageWithKF(for cell: ImagesListCell, with indexPath: IndexPath, in table: UITableView) {
        cell.cellPicture.kf.indicatorType = .activity
        
        cell.cellPicture.kf.setImage(
            with: photos[indexPath.row].thumbImageURL,
            placeholder: UIImage(named: "picture_load_placeholder")
        ) {[weak table] _ in
            table?.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    /// готовим для отображения новую ячейку с фото
    func prepareNewCell(for tableView: UITableView, with indexPath: IndexPath, on viewController: ImagesListCellDelegate) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = viewController
        imageListCell.dateLabel.text = getFormattedDate(for: indexPath)
        imageListCell.favoritesButton.setImage(getFavoriteButtonImage(for: indexPath), for: .normal)
        setImageWithKF(for: imageListCell, with: indexPath, in: tableView)
        self.view?.setGradientLayer(for: imageListCell)
        
        //проверка на необходимость подгрузки следующей страницы фотографий
        if indexPath.row == self.photos.count - 2, imagesListService.task == nil {
            print("CONSOLE func tableView: Достигнут конец ленты")
            self.imagesListService.fetchPhotosNextPage { }
        }
        return imageListCell
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
}
