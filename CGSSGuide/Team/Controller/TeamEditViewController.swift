//
//  TeamEditViewController.swift
//  CGSSGuide
//
//  Created by zzk on 16/7/30.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit

protocol TeamEditViewControllerDelegate: class {
    func save(_ team: CGSSTeam)
}

class TeamEditViewController: BaseTableViewController {
    
    weak var delegate: TeamEditViewControllerDelegate?
    var leader: CGSSTeamMember?
    // 因为设置时可能存在不按1234的顺序设置的情况 故此处设置队员为int下标的字典
    var subs = [Int: CGSSTeamMember]()
    var friendLeader: CGSSTeamMember?
    var backValue: Int?
    var manualValue: Int?
    var hv = UIView()
    var lastIndex = 0
    var lastScrollViewOffset: CGPoint?
    var keyBoardHeigt: CGFloat = 258
    var cells = [TeamMemberTableViewCell]()
    /*override func viewWillAppear(animated: Bool) {
     super.viewWillAppear(animated)
     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setKeyboardHeight), name: UIKeyboardWillShowNotification, object: nil)
     }

     override func viewDidDisappear(animated: Bool) {
     super.viewWillDisappear(animated)
     NSNotificationCenter.defaultCenter().removeObserver(self)
     }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveTeam))
        
        hv.frame = CGRect(x: 0, y: 0, width: CGSSGlobal.width, height: 100)
        for i in 0...5 {
            let cell = TeamMemberTableViewCell()
            cell.iconView.delegate = self
            if i == 0 {
                cell.title.text = "队长"
                if let leader = self.leader {
                    cell.initWith(leader, type: .leader)
                }
            } else if i < 5 {
                cell.title.text = "队员\(i)"
                if let sub = subs[i - 1] {
                    cell.initWith(sub, type: .sub)
                }
            } else {
                cell.title.text = "好友"
                if let fLeader = self.friendLeader {
                    cell.initWith(fLeader, type: .friend)
                }
            }
            cell.tag = 100 + i
            cell.delegate = self
            cells.append(cell)
        }
        
        // 暂时去除header
        // tv.tableHeaderView = hv
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        } else {
            // Fallback on earlier versions
        }
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(cancel))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initWith(_ team: CGSSTeam) {
        self.leader = team.leader
        self.friendLeader = team.friendLeader
        for i in 0...3 {
            self.subs[i] = team.subs[i]
        }
        self.backValue = team.backSupportValue
        self.manualValue = team.manualValue
    }
    
    func getMemberByIndex(_ index: Int) -> CGSSTeamMember? {
        if index == 0 {
            return leader
        } else if index < 5 {
            return subs[index - 1]
        } else {
            return friendLeader
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // print(indexPath.row, cells[indexPath.row].contentView.fheight)
        // 如果此处不加上一个1pixel的分割线的宽度 每次reloadData会自动将contentView的高度减少1pixel高度
        return max(cells[(indexPath as NSIndexPath).row].contentView.fheight, 96) + 1 / UIScreen.main.scale
    }
    
    func saveTeam() {
        if let leader = self.leader, let friendLeader = self.friendLeader , subs.count == 4 {
            let team = CGSSTeam.init(leader: leader, subs: [CGSSTeamMember].init(subs.values), backSupportValue: backValue ?? CGSSGlobal.presetBackValue, friendLeader: friendLeader)
            team.manualValue = manualValue ?? 0
            delegate?.save(team)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func cancel() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[(indexPath as NSIndexPath).row]
        return cell
    }
    
    var teamCardVC: TeamCardSelectTableViewController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastIndex = (indexPath as NSIndexPath).row
        if teamCardVC == nil {
            teamCardVC = TeamCardSelectTableViewController()
            teamCardVC!.delegate = self
        }
        self.navigationController?.pushViewController(teamCardVC!, animated: true)
        
        /* // 使用自定义动画效果
         let transition = CATransition()
         transition.duration = 0.3
         transition.type = kCATransitionFade
         // transition.subtype = kCATransitionFromRight
         navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
         navigationController?.pushViewController(teamCardVC!, animated: false)*/
        
        // 让tableview的选中状态快速消失 而不会影响之后的颜色设置
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension TeamEditViewController: TeamMemberTableViewCellDelegate {
    
    func skillLevelDidChange(_ cell: TeamMemberTableViewCell, lv: String) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.contentOffset = self.lastScrollViewOffset ?? CGPoint(x: 0, y: -64)
        })
        let member = getMemberByIndex(cell.tag - 100)
        var newLevel = Int(lv) ?? 10
        if newLevel > 10 || newLevel < 1 {
            newLevel = 10
        }
        member?.skillLevel = newLevel
        cell.setupSkillViewWith((getMemberByIndex(cell.tag - 100)?.cardRef?.skill)!, skillLevel: getMemberByIndex(cell.tag - 100)?.skillLevel)
    }
    
    func skillLevelDidBeginEditing(_ cell: TeamMemberTableViewCell) {
        lastScrollViewOffset = tableView.contentOffset
        if cell.tag - 100 >= 2 {
            var height: CGFloat = 0
            for i in 0...cell.tag - 100 {
                height += cells[i].contentView.fheight + 1 / UIScreen.main.scale
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: max(self.keyBoardHeigt + height - CGSSGlobal.height, -64))
            })
            
        }
    }
}

extension TeamEditViewController: BaseCardTableViewControllerDelegate {
    func selectCard(_ card: CGSSCard) {
        let cell = cells[lastIndex]
        if lastIndex == 0 {
            self.leader = CGSSTeamMember.init(id: card.id!, skillLevel: 10)
            cell.initWith(leader!, type: .leader)
            if self.friendLeader == nil {
                self.friendLeader = CGSSTeamMember.init(id: card.id!, skillLevel: 10)
                cells.last!.initWith(friendLeader!, type: .friend)
            }
        } else if lastIndex < 5 {
            self.subs[lastIndex - 1] = CGSSTeamMember.init(id: card.id!, skillLevel: 10)
            cell.initWith(subs[lastIndex - 1]!, type: .sub)
        } else {
            self.friendLeader = CGSSTeamMember.init(id: card.id!, skillLevel: 10)
            cell.initWith(friendLeader!, type: .friend)
        }
        tableView.reloadData()
    }
}

//MARK: UIScrollView代理方法
extension TeamEditViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
}

//MARK: CGSSIconViewDelegate
extension TeamEditViewController: CGSSIconViewDelegate {
    func iconClick(_ iv: CGSSIconView) {
        let cardIcon = iv as! CGSSCardIconView
        if let id = cardIcon.cardId {
            if let card = CGSSDAO.sharedDAO.findCardById(id) {
                let cardDVC = CardDetailViewController()
                cardDVC.card = card
                navigationController?.pushViewController(cardDVC, animated: true)
            }
        }
    }
}
