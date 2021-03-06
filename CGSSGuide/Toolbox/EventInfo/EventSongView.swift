//
//  EventSongView.swift
//  CGSSGuide
//
//  Created by zzk on 2017/1/16.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

protocol EventSongViewDelegate: class {
    func eventSongView(_ view: EventSongView, didSelect live: CGSSLive, of difficulty: Int)
}

class EventSongView: UIView {

    weak var delegate: EventSongViewDelegate?
    var jacketImageView: UIImageView!
    var nameLabel: UILabel!
    var typeIcon: UIImageView!
    var descriptionLabel: UILabel!
    var diffViews: [SongDiffView]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        jacketImageView = UIImageView()
        jacketImageView.frame = CGRect(x: 10, y: 10, width: 66, height: 66)
        
        typeIcon = UIImageView.init(frame: CGRect(x: 86, y: 10, width: 20, height: 20))
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 111, y: 10, width: CGSSGlobal.width - 121, height: 20)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        descriptionLabel = UILabel()
        descriptionLabel.frame = CGRect(x: 86, y: 35, width: CGSSGlobal.width - 96, height: 16)
        descriptionLabel.font = CGSSGlobal.alphabetFont
        
        let width = floor((CGSSGlobal.width - 96 - 40) / 5)
        let space: CGFloat = 10
        // let fontSize: CGFloat = 16
        let height: CGFloat = 33
        let originY: CGFloat = 43
        let originX: CGFloat = 86
        
        addSubview(jacketImageView)
        addSubview(nameLabel)
        addSubview(typeIcon)
        // contentView.addSubview(descriptionLabel)
        
        let colors = [Color.debut, Color.regular, Color.pro, Color.master, Color.masterPlus]
        diffViews = [SongDiffView]()
        for i in 0...4 {
            let diffView = SongDiffView.init(frame: CGRect(x: originX + (space + width) * CGFloat(i), y: originY, width: width, height: height))
            // diffView.label.font = UIFont.init(name: "menlo", size: fontSize)
            diffView.iv.tintColor = colors[i]
            diffView.iv.image = UIImage.init(named: "icon_placeholder")?.withRenderingMode(.alwaysTemplate)
            diffView.label.textColor = UIColor.darkGray
            diffView.tag = i + 1
            diffView.addTarget(self, action: #selector(diffClick))
            diffViews.append(diffView)
            addSubview(diffView)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func diffClick(_ tap: UITapGestureRecognizer) {
        delegate?.eventSongView(self, didSelect: live, of: tap.view!.tag)
    }
    
    var live: CGSSLive!
    func setup(live: CGSSLive) {
        self.live = live
        let dao = CGSSDAO.sharedDAO
        if let song = dao.findSongById(live.musicId!) {
            self.nameLabel.text = song.title
            // self.descriptionLabel.text = "bpm:\(song?.bpm ?? 0)  composer:\(song?.composer!)  lyricist:\(song.lyricist!)"
            let descString = "bpm:\(song.bpm!)"
            // 暂时去除时长的显示
            //            if let beatmap = dao.findBeatmapById(live.id!, diffId: 1) {
            //                descString += " 时长:\(Int(beatmap.totalSeconds))秒"
            //            }
            self.descriptionLabel.text = descString
            self.nameLabel.textColor = live.getLiveColor()
            self.typeIcon.image = UIImage.init(named: live.getLiveIconName())
            
            let diffStars = [live.debut!, live.regular!, live.pro!, live.master!, live.masterPlus!]
            for i in 0...4 {
                self.diffViews[i].text = "\(diffStars[i])"
            }
            if live.masterPlus != 0 {
                self.diffViews[4].isHidden = false
            } else {
                self.diffViews[4].isHidden = true
            }
            
            let url = DataURL.Deresute + "/image/jacket_\(song.id!).png"
            self.jacketImageView.sd_setImage(with: URL.init(string: url))
        }
    }

}
