//
//  ImagesListCell.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.02.2024.
//
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet var gradientView: UIView!
    @IBOutlet var cellPicture: UIImageView!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        self.cellPicture.kf.cancelDownloadTask()
    }
    
    // MARK: - IB Actions
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
