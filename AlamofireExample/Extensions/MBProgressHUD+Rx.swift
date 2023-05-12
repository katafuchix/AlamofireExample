//
//  MBProgressHUD+Rx.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/12.
//

import UIKit
import MBProgressHUD
import RxSwift
import RxCocoa

extension Reactive where Base: MBProgressHUD {
    static func isAnimating(view: UIView) -> AnyObserver<Bool> {
        return AnyObserver { event in
            MainScheduler.ensureExecutingOnScheduler()  // なくてもよい？
            switch event {
            case .next(let value):
                if value {
                    MBProgressHUD.showAdded(to: view, animated: true)
                } else {
                    MBProgressHUD.hide(for: view, animated: true)
                }
            default:
                break
            }
        }
    }
}
