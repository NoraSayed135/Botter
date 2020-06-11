//
//  ChatViewController.swift
//  Botter
//
//  Created by Nora on 6/3/20.
//  Copyright (c) 2020 BlueCrunch. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ChatViewController: UIViewController {
    
    // MARK: - Public properties -
    
    @IBOutlet weak var groupedDateLbl : PaddedUILabel!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var chatView : TextBoxFeild!
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!
    
    var presenter: ChatPresenterInterface!
    var original : CGFloat = 0
    var currentAudio = -1
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyBoardSettings()
        self.presenter.openSocket()
       
    }
    
    @IBAction func sendMesg(){
         self.view.endEditing(true)
        if chatView.getText().isEmpty{
            
        }else{
            self.presenter.sendMessage(text: self.chatView.getText())
        }
    }
    
    func clearTextBox() {
        self.chatView.setText(text: "")
    }
    
    func showError(errorMsg: String) {
        self.showMessage(errorMsg)
    }
    
}

// MARK: - Extensions -

extension ChatViewController: ChatViewInterface {
    func reload() {
        self.tableView.reloadData()
        if self.presenter.messgesList.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.presenter.messgesList.count - 1 , section: 0), at: .bottom, animated: false)
        }
    }
}


extension ChatViewController {
    func keyBoardSettings(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        original = bottomConstraint.constant
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        adjustingHeight(show: true, notification: notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        // 1
        let userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // 3
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 4
        var changeInHeight = (keyboardFrame.height)
        
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            if show{
                changeInHeight = ( changeInHeight - (bottom ?? 0) ) * (show ? 1 : -1)
            }else{
                changeInHeight = ( changeInHeight - (bottom ?? 0) ) * (show ? 1 : -1)
            }
        } else {
            changeInHeight = ( changeInHeight ) * (show ? 1 : -1)
        }
        //5
        let lastVisibleCell = tableView.indexPathsForVisibleRows?.last
        let newValue = self.bottomConstraint.constant + changeInHeight
        UIView.animate(
            withDuration: animationDurarion,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                if newValue < self.original {
                    print("Alert----------------")
                    self.bottomConstraint.constant = self.original
                }else if changeInHeight > 0 && newValue > changeInHeight + self.original{
                    self.bottomConstraint.constant = changeInHeight + self.original
                }else{
                    self.bottomConstraint.constant = newValue
                }
                self.view.layoutIfNeeded()
                if show{
                    if let lastVisibleCell = lastVisibleCell {
                        self.tableView.scrollToRow(
                            at: lastVisibleCell,
                            at: .bottom,
                            animated: false)
                    }
                }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            // TODO: Do your stuff here.
            SocketManager.shared.dissConnect()
        }
    }
    
    func removeObservers(){
        
        if self.isBeingDismissed  //presented view controller
        {
            // remove observer here
            NotificationCenter.default.removeObserver(self)
        }
    }
}
extension ChatViewController : TextBoxDelegate{
    func textBoxDidChange(textBox: TextBoxFeild) {
       
    }
    
    func shouldChangeTextInRange(textBox: TextBoxFeild) {
        
    }
    
    func textBoxDidBeginEditing(textBox: TextBoxFeild) {

    }
    
    func textBoxDidEndEditing(textBox: TextBoxFeild) {
        
    }
    
    func textBoxShouldBeginEditing(textBox: TextBoxFeild) {

    }
    
    func textBoxShouldEndEditing(textBox: TextBoxFeild) {
      
    }
    
    func checkIfLastBotInput(index : Int)->Bool{
        var isLastBotInput = false
        if presenter.messgesList.count - 1 == index{
            isLastBotInput = true
        }else{
            let nextMsg = presenter.messgesList[index + 1]
            isLastBotInput = !nextMsg.isBotMsg
        }
        
        return isLastBotInput
    }
    
}
extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.messgesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = presenter.messgesList[indexPath.row]
        if msg.isBotMsg{
            switch msg.msgType {
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageBotTableViewCell") as? ImageBotTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row))
                return cell ?? UITableViewCell()
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoBotTableViewCell") as? VideoBotTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row))
                cell?.openVideo = { url in
                    self.presenter.openVideo(url: url)
                }
                return cell ?? UITableViewCell()
            case .hero:
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeroTableViewCell") as? HeroTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row))
                cell?.actionClicked = { action in
                    self.presenter.actionClicked(action: action)
                }
                return cell ?? UITableViewCell()
            case .gallery:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GallaryTableViewCell") as? GallaryTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row))
                cell?.actionClicked = { action in
                    self.presenter.actionClicked(action: action)
                }
                return cell ?? UITableViewCell()
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AudioBotTableViewCell") as? AudioBotTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row), isCurrent: indexPath.row == currentAudio, index: indexPath.row)
                cell?.playPausePressed = { btnIndex in
                    if self.currentAudio == btnIndex{
                        self.currentAudio = -1
                    }else{
                        self.currentAudio = btnIndex
                    }
                    self.reload()
                }
                return cell ?? UITableViewCell()
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BotChatTableViewCell") as? BotChatTableViewCell
                cell?.setData(msg: msg , showIcon: checkIfLastBotInput(index: indexPath.row))
                return cell ?? UITableViewCell()
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserChatTableViewCell") as? UserChatTableViewCell
           
            cell?.setData(msg: msg )
            
            return cell ?? UITableViewCell()
        }
      
//        return UITableViewCell()
    }
}

