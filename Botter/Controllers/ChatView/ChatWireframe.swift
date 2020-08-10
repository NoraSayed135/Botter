//
//  ChatWireframe.swift
//  Botter
//
//  Created by Nora on 6/3/20.
//  Copyright (c) 2020 BlueCrunch. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import AVKit

final class b_ChatWireframe: b_BaseWireframe {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init(botData : b_BotData) {
        let moduleViewController = b_ChatViewController.b_instantiateFromStoryBoard(appStoryBoard: .Main)
        super.init(viewController: moduleViewController)

        let interactor = b_ChatInteractor()
        let presenter = b_ChatPresenter(view: moduleViewController, interactor: interactor, wireframe: self)
        moduleViewController.presenter = presenter
        b_ChatViewController.botData = botData
        interactor.presenter = presenter
    }

}

// MARK: - Extensions -

extension b_ChatWireframe: ChatWireframeInterface {
    
    func openVideo(url: String) {
        if url.isYoutubeLink(){
            openUrl(url: url)
        }else{
            let nURL = url.replacingOccurrences(of: "http:", with: "https:")
            if let vedioURL =  URL.init(string: nURL) {
                let player = AVPlayer(url:vedioURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                let windows = UIApplication.shared.windows
                if let floatingWindow = windows.last(where:  { (window) -> Bool in
                    window is FloatingButtonWindow
                }){
                    if let currentVC = (floatingWindow as? FloatingButtonWindow)?.b_visibleViewController{
                        currentVC.present(playerViewController, animated: true) {
                            player.play()
                        }
                    }
                }
                
                
            }
        }
    }
    
    func openUrl(url: String) {
//        WebLinksViewController.openInParent(link: url, parent: self.viewController)
        if let url = URL(string: url) {
//            UIApplication.shared.open(url)
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func call(number: String) {
        self.viewController.b_makePhoneCall(phoneNumber: number)
    }
    
    func openEndForm(form: b_Form) {
        let vc = b_EndFormViewController.b_instantiateFromStoryBoard(appStoryBoard: .Forms)
        vc.form = form
        self.viewController.present(vc, animated: true, completion: nil)
    }
}

