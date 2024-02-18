//
//  ViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 04.02.2024.
//
import UIKit

class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Override Properties
    override var preferredStatusBarStyle: UIStatusBarStyle { // меняем цвет StatusBar на белый
        return .lightContent
    }
    
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Private methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.cellPicture.image = image
        cell.dateLabel.text = dateToString(Date()-TimeInterval(indexPath.row * 86400))
        
        let isFavorite = indexPath.row % 2 == 0
        let favoriteImage = isFavorite ? UIImage(named: "favorites_active") : UIImage(named: "favorites_no_active")
        cell.favoritesButton.setImage(favoriteImage, for: .normal)
    }
    
    ///  функция форматирования даты в строку
    private func dateToString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMMM yyyy"
        return df.string(from: date)
    }
}

// MARK: - Extentions
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
