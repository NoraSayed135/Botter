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
    }
    
    func sendMessage(text : String){
        if SocketManager.shared.isConnected{
            SocketManager.shared.sendMessage(text: text)
            let Message = BasicMessage()
            Message.type = "message"
            Message.isBotMsg = false
            Message.text = text
            self.presenter.clearTextBox()
            self.presenter.messageReceived(message: Message)
        }else{
            SocketManager.shared.connect()
            self.presenter.showError(errorMsg: "Failed to send,\nPlease check your internet connection")
        }
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
            SocketManager.shared.sendPostBack(value: action.value)
            break
        default:
            break
        }
    }
}
