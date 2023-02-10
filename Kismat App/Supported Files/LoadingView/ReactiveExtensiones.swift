//
//  ReactiveExtensiones.swift
//  
//
//  Created by Mohammad Zakizadeh on 7/27/18.
//  Copyright © 2018 Storm. All rights reserved.
//

import Foundation


import UIKit
import RxSwift
import RxCocoa

/*struct LoadingObj {
    var isloading: Bool = false
    var loadingTxt: String
    
    init(isloading: Bool, loadingTxt: String) {
        self.isloading = isloading
        self.loadingTxt = loadingTxt
    }
}*/

extension UIViewController: loadingViewable {}

extension Reactive where Base: UIViewController {
    
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (vc, active) in
                if active {
                    vc.startAnimating(loadingTxt: "Loading...")
                } else {
                    vc.stopAnimating()
                }
        })
    }
    
}




/*extension Reactive where Base: UIViewController {
    
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: Binder<Dictionary<String, Any>> {
        return Binder(self.base, binding: { (vc, obj) in
//            if obj.isloading {
//                vc.startAnimating(loadingTxt: obj.loadingTxt)
//            } else {
//                vc.stopAnimating()
//            }
        })
    }
    
}*/


