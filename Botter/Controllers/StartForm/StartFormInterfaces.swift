//
//  StartFormInterfaces.swift
//  Botter
//
//  Created by Nora on 7/15/20.
//  Copyright (c) 2020 BlueCrunch. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

protocol StartFormWireframeInterface: WireframeInterface {
    func openChat(data:b_BotData)
}

protocol StartFormViewInterface: b_ViewInterface {
    func showLoader()
    func hideLoader()
    func showMsg(msg : String)
    func reload()
    func setFaqsData(faqsData : [b_FaqData])
}

protocol StartFormPresenterInterface: b_PresenterInterface {
    var botData : b_BotData! { get set }
    var dataCells : [UITableViewCell]! { get set }
    func loadForms()
    func showLoader()
    func hideLoader()
    func reload()
    func getCells()
    func validateThenSubmitForm()
    func openChat()
    func getFaqsData(searchText : String)
    func fetchedFaqsSuccessfully(faqsResponse : [b_FaqData])
    func faqsError(error : String)
}

protocol StartFormInteractorInterface: b_InteractorInterface {
    func loadForms()
    func validateForm()
    func loadFaqs(searchText : String)
    
}
