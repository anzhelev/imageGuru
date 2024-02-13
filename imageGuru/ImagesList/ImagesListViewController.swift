//
//  ViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 04.02.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Override Properties
    //    override var preferredStatusBarStyle: UIStatusBarStyle { // меняем цвет StatusBar на белый
    //        return .lightContent
    //    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configCell(for cell: ImagesListCell) { }
    
}

