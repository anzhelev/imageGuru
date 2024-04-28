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
    @IBOutlet private var gradientView: UIView!
    @IBOutlet private var cellPicture: UIImageView!
    @IBOutlet private var favoritesButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
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
    
    func configure(with imageUrl: URL, date: String, favoriteButtonImage: UIImage?, completion: @escaping () -> Void) {
        
        dateLabel.text = date
        setFavoriteButtonImage(image: favoriteButtonImage)
        setGradientLayer()
        
        cellPicture.kf.indicatorType = .activity
        cellPicture.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "picture_load_placeholder")
        ) {weak in
            completion()
        }
    }
    
    func setFavoriteButtonImage(image: UIImage?) {
        favoritesButton.setImage(image, for: .normal)
    }
    
    func setGradientLayer() {
        guard gradientView.layer.sublayers?.count ?? 0 < 2 else {
            return
        }
        gradientView.layer.masksToBounds = true
        gradientView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        gradientView.layer.cornerRadius = 16
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.igGradientAlpha0.cgColor, UIColor.igGradientAlpha20.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)
    }
}
