//
//  StartFormInteractor.swift
//  Botter
//
//  Created by Nora on 7/15/20.
//  Copyright (c) 2020 BlueCrunch. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import UIKit

final class StartFormInteractor {
     var presenter: StartFormPresenterInterface!
}

// MARK: - Extensions -

extension StartFormInteractor: StartFormInteractorInterface {
    func loadFaqs(searchText: String) {
        self.presenter.showLoader()
        let dataSource = BotterDataSource()
        dataSource.getFAQsData(searchText: searchText) { (status, response) in
            self.presenter.hideLoader()
            switch status {
            case .sucess :
                 self.presenter.fetchedFaqsSuccessfully(faqsResponse: response as? [b_FaqData] ?? [])
                break
            case .error , .networkError :
                self.presenter.faqsError(error: response as? String ?? "Some thing went wrong")
                
            }
             
               
               }
    }
    
    func loadForms() {
        self.presenter.showLoader()
        let dataSource = BotterDataSource()
        dataSource.getBotterData { (status, response) in
            self.presenter.hideLoader()
            self.presenter.botData = response as? b_BotData ?? b_BotData()
            self.presenter.getCells()
        }
    }
    
    func validateForm(){
        var isValid = true
        for cell in self.presenter.dataCells{
            if let mCell = cell as? BasicFormTableViewCell{
                isValid = mCell.validateFormInput() && isValid
            }
        }
        
        if isValid {
            submitForm()
        }
    }
    
    func submitForm(){
        var attributes = [[String : Any]]()
        for cell in self.presenter.dataCells{
            if let mCell = cell as? BasicFormTableViewCell{
                var tAttribute = [String : Any]()
                tAttribute["attribute"] = mCell.input.key
                tAttribute["value"] = mCell.getAnswer()
                attributes.append(tAttribute)
            }
        }
        if attributes.count > 0{
            B_SocketManager.shared.attributes = attributes
        }
        self.presenter.openChat()
        
    }
}
