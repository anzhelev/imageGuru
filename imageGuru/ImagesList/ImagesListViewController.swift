//
//  ViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 04.02.2024.
//
import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(with rangeOfCells: Range <Int>)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Visual Components
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Public Properties
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter  = ImagesListPresenter()
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    // MARK: - Overrided Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController,
               let indexPath = sender as? IndexPath {
                viewController.imageURL = presenter?.getSingleImageUrl(for: indexPath.row)
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    // MARK: - Public methods
    /// перерисовываем таблицу при добавлении новых фото
    func updateTableViewAnimated(with rangeOfCells: Range <Int>) {
        tableView.performBatchUpdates {
            let indexPaths = rangeOfCells.map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotosCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newCell = presenter?.prepareNewCell(for: tableView, with: indexPath, on: self) else {
            return UITableViewCell()
        }
        return newCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.getCellHeight(indexPath: indexPath, tableBoundsWidth: tableView.bounds.width) ?? 0
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.changeLike(for: cell, in: tableView)
    }
}
