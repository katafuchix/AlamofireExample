//
//  ViewModel.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/11.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire

class ViewModel {
    
    let disposeBag = DisposeBag()
    
    // input
    let searchTrigger = PublishSubject<Void>()
    let searchWord   = BehaviorRelay<String>(value: "")
    
    // output
    let drinks: BehaviorRelay<[Cocktail]>
    let errorMessage: Driver<String>
    let isLoading: Driver<Bool>
    
    init() {
        
        // 内部変数
        // BehaviorSubjectを使って初期値を設定
        let keyword = BehaviorSubject<String>(value: "")
        // エラーメッセージを表すDriver
        let errorMessage_ = BehaviorSubject<String>(value: "")
        // API実行中かどうかを表すDriver
        let isLoading_ = BehaviorSubject<Bool>(value: false)
        
        // output変数の初期化
        self.drinks = BehaviorRelay<[Cocktail]>(value: [])
        self.errorMessage = errorMessage_.asDriver(onErrorDriveWith: .empty())
        self.isLoading = isLoading_.asDriver(onErrorDriveWith: .empty())
        
        // 検索トリガ
        self.searchTrigger
            .withLatestFrom(searchWord)
            .bind(to: keyword)
            .disposed(by: disposeBag)
        
        keyword.asObservable()                      // ここはsubscribeで結果とエラーを出し分けてもOK
            .observe(on: MainScheduler.instance)
            .filter { $0.count > 0 } // 空文字でない場合にAPI実行
            .flatMapLatest { keyword -> Observable<CocktailSearchResult> in
                // API実行中にisLoadingをtrueにする
                isLoading_.onNext(true)
                let request: Observable<CocktailSearchResult> = HttpClientRx.sendRequest(url: "https://www.thecocktaildb.com/api/json/v1/1/search.php", method: .get, parameters: ["s": keyword])
                return request.catch {
                    errorMessage_.onNext($0.localizedDescription)
                    isLoading_.onNext(false)
                    return Observable.empty()
                }
            }
            .map(\.drinks)
            .catch({            // ここはいらなかも
                errorMessage_.onNext($0.localizedDescription)
                isLoading_.onNext(false)
                return Observable.empty()
            })
            .do(onNext: { _ in
                isLoading_.onNext(false)
            })
            .bind(to: self.drinks)
            .disposed(by: disposeBag)
    }
    
    func reset() {
        self.searchWord.accept("")
        self.searchTrigger.onNext(())
    }
}
