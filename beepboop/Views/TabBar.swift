//
//  TabBar.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/25/21.
//

import UIKit

class TabBar: UITabBar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var cachedSafeAreaInsets = UIEdgeInsets.zero

    let keyWindow = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .filter { $0.isKeyWindow }
        .first
    
    override var safeAreaInsets: UIEdgeInsets {
        if let insets = keyWindow?.safeAreaInsets {
            if insets.bottom < bounds.height {
                cachedSafeAreaInsets = insets
            }
        }
        return cachedSafeAreaInsets
    }

}
