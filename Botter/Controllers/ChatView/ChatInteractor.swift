//
//  ChatInteractor.swift
//  Botter
//
//  Created by Nora on 6/3/20.
//  Copyright (c) 2020 BlueCrunch. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation

final class ChatInteractor {
    var presenter: ChatPresenterInterface!
}

// MARK: - Extensions -

extension ChatInteractor: ChatInteractorInterface {
    
    func openSocket() {
        SocketManager.shared.connect()
        SocketManager.shared.messageRecieved = { msg in
            self.presenter.messageReceived(message: msg)
        }
        SocketManager.shared.historyLoaded = { list in
            var mList = list
            mList.removeAll(where: {$0.slug.lowercased() == ""})
//            mList.removeAll(where: {$0.type.lowercased() == "welcome_back"})
//            mList.removeAll(where: {$0.type.lowercased() == "set_attributes"})
            if mList.count > 0 {
                self.presenter.historyLoaded(list: mList)
            }
            
        }
    }
    
    func resend(msg: BasicMessage , completion:@escaping((Bool)->()))  {
        
        if SocketManager.shared.isConnected && ReachabilityManager.shared.isNetworkAvailable{
            if msg.blockValue != ""{
                SocketManager.shared.sendMessage(text: msg.blockValue) { (isSent) in
                    completion(isSent)
                }
            }else{
                SocketManager.shared.sendMessage(text: msg.text){ (isSent) in
                    completion(isSent)
                }
            }
             
        }else{
            SocketManager.shared.connect()
            completion(false)
        }
    }
    
    func sendMessage(text : String , completion:@escaping((BasicMessage)->())){
        let Message = BasicMessage()
        Message.type = "message"
        Message.isBotMsg = false
        Message.text = text
        Message.slug = "message"
        Message.msgType = .userMsg
        Message.sender.senderType = .user
        self.presenter.clearTextBox()
        
        if SocketManager.shared.isConnected{
            SocketManager.shared.sendMessage(text: text){ isSent in
                completion(Message)
            }
        }else{
            SocketManager.shared.connect()
            Message.msgSent = false
            completion(Message)
        }
        
    }
    
    func triviaMessage(action : Action , completion:@escaping((BasicMessage)->())){
        let Message = BasicMessage()
        Message.type = "message"
        Message.slug = "message"
        Message.isBotMsg = false
        Message.text = action.title
        Message.msgType = .userMsg
        Message.sender.senderType = .user
        if SocketManager.shared.isConnected{
            if action.action == .date{
                SocketManager.shared.sendMessage(text: action.title) { (isSent) in
                    completion(Message)
                }
            }else{
                SocketManager.shared.sendPostBack(value: action.value , title: action.title){ isSent in
                    completion(Message)
                }
            }
//            return true
        }else{
            SocketManager.shared.connect()
            Message.msgSent = false
//            return false
            Message.blockValue = action.value
            completion(Message)
        }
//        self.presenter.messageReceived(message: Message)
   
    }
    
    func actionClicked(action: Action) {
        switch action.action {
        case .call:
            presenter.call(number: action.value)
            break
        case .openUrl:
            presenter.openUrl(url: action.value)
            break
        case .postBack:
            SocketManager.shared.sendPostBack(value: action.value , title: action.title , completion: { isSent in
//                completion(isSent)
            })
            break
        default:
            break
        }
    }
    
    func sendAttachment(file: AttachedFile, completion:@escaping((BasicMessage)->())) {
        let Message = BasicMessage()
        Message.type = "attachment"
        Message.isBotMsg = false
        Message.mediaUrl = file.url
        Message.type = file.type
        Message.slug = file.type == "image" ? "image_attachment" : "attachment"
        Message.sender.senderType = .user
        Message.msgType = MessageType.init(rawValue: Message.slug) ?? .attachment
        
        if SocketManager.shared.isConnected{
            SocketManager.shared.sendAttachment(file: file, completion: { (isSent) in
                completion(Message)
            })
        }else{
            SocketManager.shared.connect()
            Message.msgSent = false
            completion(Message)
        }
    }
    
    func sendMenuAction(action : MenuItem ,completion:@escaping((BasicMessage)->())){
        let Message = BasicMessage()
        Message.type = "message"
        Message.slug = "message"
        Message.isBotMsg = false
        Message.text = action.title
        Message.msgType = .userMsg
        Message.sender.senderType = .user
        if SocketManager.shared.isConnected{
            SocketManager.shared.sendPostBack(value: action.payload , title: action.title){ isSent in
                completion(Message)
            }
        }else{
            SocketManager.shared.connect()
            Message.msgSent = false
            //            return false
            Message.blockValue = action.payload
            completion(Message)
        }
    }
}
