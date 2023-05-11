//
//  ViewController.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {

    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        HttpClientRx.sendGETRequestRxAlamofire(url: "https://example.com/api/data", parameters: ["key": "value"])
            .subscribe(onNext: { data in
                // 受信したデータを処理する
                print("Received data: \(data)")
            }, onError: { error in
                print("Error: \(error.localizedDescription)")
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.searchWord.accept("Blue")
        self.viewModel.searchTrigger.onNext(())
        
        self.viewModel.drinks.subscribe(onNext: {
            print($0)
        }).disposed(by: rx.disposeBag)
        
        self.viewModel.isLoading.asObservable().subscribe(onNext: {
            print("============")
            print($0)
            print("============")
        }).disposed(by: rx.disposeBag)
        
        self.viewModel.errorMessage.asObservable().subscribe(onNext: {
            print("============")
            print($0)
            print("============")
        }).disposed(by: rx.disposeBag)
    }


}

