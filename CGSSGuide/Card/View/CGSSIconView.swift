//
//  CGSSIconView.swift
//  CGSSGuide
//
//  Created by zzk on 16/8/14.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit
import ZKCornerRadiusView

protocol CGSSIconViewDelegate: class {
    func iconClick(_ iv: CGSSIconView)
}

class CGSSIconView: ZKCornerRadiusView {
    
    var tap: UITapGestureRecognizer?
    var action: Selector?
    weak var target: AnyObject?
    weak var delegate: CGSSIconViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    func prepare() {
        isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(onClick))
        addGestureRecognizer(tap!)
    }
    
    func setIconImage(_ urlStr: String) {
        sd_setImage(with: URL.init(string: urlStr)!, placeholderImage: #imageLiteral(resourceName: "icon_placeholder").withRenderingMode(.alwaysTemplate))
    }
    
    func setAction(_ target: AnyObject, action: Selector) {
        self.action = action
        self.target = target
    }
    
    func onClick() {
        delegate?.iconClick(self)
        if action != nil {
            _ = self.target?.perform(action!, with: self)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        zk_cornerRadius = self.fheight / 8
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
}
