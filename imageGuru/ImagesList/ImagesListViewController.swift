//
//  ViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 04.02.2024.
//
import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Visual Components
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.imagesListService
    private var ImagesListServiceObserver: NSObjectProtocol?
    private let dateToStringFormatter = DateFormatter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        photos = imagesListService.photos
        
        dateToStringFormatter.dateFormat = "dd MMMM yyyy"
        dateToStringFormatter.locale = Locale(identifier: "ru_RU")
        
        ImagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: .imageListUpdated,
            object: nil,
            queue: .main
        ) {[weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    // MARK: - Overrided Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController,
               let indexPath = sender as? IndexPath {
                viewController.imageURL = photos[indexPath.row].largeImageURL
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    // MARK: - Public methods
    /// перерисовываем таблицу при добавлении новых фото
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    /// функция очистки массива фотографий
    func cleanPhotos() {
        photos.removeAll()
    }
    
    // MARK: - Private methods
    /// функция установки картинки в ячейку с помощью KingFicher
    private func setImageWithKF(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.cellPicture.kf.indicatorType = .activity
        
        cell.cellPicture.kf.setImage(
            with: photos[indexPath.row].thumbImageURL,
            placeholder: UIImage(named: "picture_load_placeholder")
        ) {[weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    /// настройка внешнего вида ячейки и компонентов
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        setImageWithKF(for: cell, with: indexPath)
        cell.dateLabel.text = self.dateToStringFormatter.string(from: self.photos[indexPath.row].createdAt ?? Date())
        
        let favoriteImage = UIImage(named: self.photos[indexPath.row].isLiked ? "favorites_active" : "favorites_no_active")
        cell.favoritesButton.setImage(favoriteImage, for: .normal)
        
        // добавляем градиент на поле с датой
        cell.gradientView.layer.masksToBounds = true
        cell.gradientView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        cell.gradientView.layer.cornerRadius = 16
        let gradient = CAGradientLayer()
        gradient.frame = cell.gradientView.bounds
        gradient.colors = [UIColor.igGradientAlpha0.cgColor, UIColor.igGradientAlpha20.cgColor]
        cell.gradientView.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        
        //проверка на необходимость подгрузки следующей страницы фотографий
        if indexPath.row == self.photos.count - 2, imagesListService.task == nil {
            print("CONSOLE func tableView: Достигнут конец ленты")
            self.imagesListService.fetchPhotosNextPage { }
        }
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.photos.count > 0 else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoIndex: indexPath.row) {result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let like):
                guard let favoriteImage = UIImage(named: like ? "favorites_active" : "favorites_no_active") else {
                    return
                }
                cell.favoritesButton.setImage(favoriteImage, for: .normal)
                print("CONSOLE func changeLike: изменен лайк для фото",
                      self.photos[indexPath.row].id,
                      self.photos[indexPath.row].welcomeDescription ?? "")
            case .failure(let error):
                print("CONSOLE func changeLike:", error.localizedDescription)
            }
        }
    }
}
