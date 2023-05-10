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
    }


}

