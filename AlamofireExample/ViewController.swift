//
//  ViewController.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import MBProgressHUD // Pod だと arm64エラーになるので Package でインストールする

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // 利用しないが例のために記述
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.bind()
    }

    func bind() {
        // 検索バー
        self.searchBar.rx.text.asObservable()
            .map { $0 ?? "" }
            .bind(to: self.viewModel.searchWord)
            .disposed(by: rx.disposeBag)
        
        // キャンセルボタン
        self.searchBar.rx.cancelButtonClicked.asDriver()
            .drive(onNext :{ [weak self] in
                self?.searchBar.resignFirstResponder()
                self?.searchBar.showsCancelButton = false
            }).disposed(by: rx.disposeBag)
        
        self.searchBar.rx.textDidBeginEditing.asDriver().drive(onNext: { [weak self] in
                self?.searchBar.showsCancelButton = true
                self?.viewModel.reset()
            })
            .disposed(by: rx.disposeBag)

        // 検索ボタン
        self.searchBar.rx.searchButtonClicked.asDriver()
            .drive(onNext :{ [weak self] in
                self?.searchBar.resignFirstResponder()
                self?.searchBar.showsCancelButton = false
                self?.viewModel.searchTrigger.onNext(())
            })
            .disposed(by: rx.disposeBag)
        
        // UITableViewCell Items
        self.viewModel.drinks.asObservable().bind(to:
                tableView.rx.items(cellIdentifier: "CocktailTableViewCell", cellType: CocktailTableViewCell.self))
                    {
                        index, model, cell in
                            cell.configure(model)
                    }
            .disposed(by: rx.disposeBag)
        
        // ローディング
        self.viewModel.isLoading.asDriver()
            .drive(MBProgressHUD.rx.isAnimating(view: self.view))
            .disposed(by: rx.disposeBag)
        
        /*
        // UIActivityIndicatorView 利用時
        self.viewModel.isLoading.asDriver()
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: rx.disposeBag)
        */
    }
}

