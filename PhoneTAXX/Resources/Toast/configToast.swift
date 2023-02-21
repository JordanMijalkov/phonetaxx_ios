//
//  configToast.swift
//  fetish
//
//  Created by Anupriya on 13/04/20.
//  Copyright © 2020 ShubhamSharma. All rights reserved.
//

import Foundation
import UIKit

 
func configToast(){
    var style = ToastStyle()
    style.messageColor = UIColor.white
    style.backgroundColor = UIColor.black
    ToastManager.shared.style = style
}
