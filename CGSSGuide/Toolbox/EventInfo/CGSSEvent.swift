//
//  CGSSEvent.swift
//  CGSSGuide
//
//  Created by zzk on 2016/10/9.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit

extension CGSSEvent {
    var eventType: CGSSEventTypes {
        return CGSSEventTypes.init(eventType: type)
    }
    var live: CGSSLive? {
        let dao = CGSSDAO.sharedDAO
        let lives = Array(dao.validLiveDict.values)
        for live in lives {
            if live.id == liveId {
                return live
            }
        }
        return nil
    }
    
}

class CGSSEvent: CGSSBaseModel {
    var sortId: Int
    var id:Int
    var type:Int
    var startDate:String
    var endDate:String
    var name:String
    var secondHalfStartDate:String
    var liveId: Int
    
    var reward:[Reward]
    
    init(sortId:Int, id:Int, type:Int, startDate:String, endDate:String, name:String, secondHalfStartDate:String, reward:[Reward], liveId: Int) {
        self.sortId = sortId
        self.id = id
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.name = name
        self.secondHalfStartDate = secondHalfStartDate
        self.reward = reward
        self.liveId = liveId
        super.init()
        
        // 内部数据错误 特殊处理
        if id == 1004 {
            self.reward[0].cardId = 300135
            self.reward[1].cardId = 200129
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
