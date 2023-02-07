//
//  APIGroupsExtension.swift
//  sphinx
//
//  Created by Tomas Timinskas on 15/01/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

extension API {
    func createGroup(
        params: [String: AnyObject],
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ){
        guard let request = getURLRequest(route: "/group", params: params as NSDictionary?, method: "POST") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func editGroup(
        id: Int,
        params: [String: AnyObject],
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ){
        guard let request = getURLRequest(route: "/group/\(id)", params: params as NSDictionary?, method: "PUT") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func deleteGroup(
        id: Int,
        callback: @escaping SuccessCallback
    ) {
        guard let request = getURLRequest(route: "/chat/\(id)", method: "DELETE") else {
            callback(false)
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, success {
                        callback(true)
                        return
                    }
                }
                callback(false)
            case .failure(_):
                callback(false)
            }
        }
    }
    
    func addMembers(
        id: Int,
        params: [String: AnyObject],
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        guard let request = getURLRequest(route: "/chat/\(id)", params: params as NSDictionary?, method: "PUT") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func getTribesList(
        callback: @escaping GetAllTribesCallback,
        errorCallback: @escaping EmptyCallback,
        limit : Int = 20,
        searchTerm:String? = nil,
        page : Int = 0,
        tags : [String] = []
    ) {
        var url = API.getUrl(route: "\(API.kTribesServerBaseURL)/tribes?limit=\(limit)&sortBy=member_count&page=\(page)")
        if tags.isEmpty == false {
            url.append("&tags=")
            for tag in tags {
                url.append("\(tag),")
            }
            url.remove(at: url.index(url.endIndex, offsetBy: -1))
        }
        
        url += (searchTerm == nil) ? "" : "&search=\(searchTerm!)"
        
        guard let request = createRequest(url.percentEscaped ?? url, bodyParams: nil, method: "GET") else {
            errorCallback()
            return
        }
        
        AF.request(request).responseJSON { response in
            switch response.result {
            case .success(let data):
                callback(data as? [NSDictionary] ?? [])
            case .failure(let error):
                errorCallback()
            }
        }
    }
    
    func getTribeInfo(
        host: String,
        uuid: String,
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        let url = API.getUrl(route: "https://\(host)/tribes/\(uuid)")
        let tribeRequest : URLRequest? = createRequest(url, bodyParams: nil, method: "GET")
        
        guard let request = tribeRequest else {
            errorCallback()
            return
        }
        
        //NEEDS TO BE CHANGED
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    callback(JSON(json))
                } else {
                    errorCallback()
                }
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func joinTribe(
        params: [String: AnyObject],
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        guard let request = getURLRequest(route: "/tribe", params: params as NSDictionary?, method: "POST") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func kickMember(
        chatId: Int,
        contactId: Int,
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        guard let request = getURLRequest(route: "/kick/\(chatId)/\(contactId)", params: nil, method: "PUT") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func requestAction(
        messageId: Int,
        contactId: Int,
        action: String,
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        guard let request = getURLRequest(route: "/member/\(contactId)/\(action)/\(messageId)", params: nil, method: "PUT") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func addTribeMember(
        params: [String: AnyObject],
        callback: @escaping CreateGroupCallback,
        errorCallback: @escaping EmptyCallback
    ) {
        
        guard let request = getURLRequest(route: "/tribe_member", params: params as NSDictionary?, method: "POST") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool, let response = json["response"] as? NSDictionary, success {
                        callback(JSON(response))
                        return
                    }
                }
                errorCallback()
            case .failure(_):
                errorCallback()
            }
        }
    }
    
    func createTribeAdminBadge(
        callback: @escaping GetTribeBadgesCallback,
        errorCallback: @escaping EmptyCallback
    ){
        var params = [String:Any]()
        params["icon"] = "https://static-00.iconduck.com/assets.00/whale-icon-512x415-xtgxbil4.png"
        params["name"] = "Jim Test"
        params["amount"] = 10
        params["memo"] = "my memo"
        guard let request = getURLRequest(route: "/create_badge", params: params as? NSDictionary, method: "POST") else {
            errorCallback()
            return
        }
        
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool,
                        let response = json["response"] as? String,
                        success {
                        //callback((response))
                        return
                    }
                }
                print(response.response?.statusCode)
                errorCallback()
            case .failure(_):
                print(response.response?.statusCode)
                errorCallback()
            }
        }
    }
    
    func getTribeAdminBadgeTemplates(
        callback: @escaping GetTribeBadgesCallback,
        errorCallback: @escaping EmptyCallback
    ){
        guard let request = getURLRequest(route: "/badge_templates", params: nil, method: "GET") else {
            errorCallback()
            return
        }
        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool,
                        let response = json["response"] as? [NSDictionary],
                        success {
                        callback(response)
                        return
                    }
                }
                print(response.response?.statusCode)
                errorCallback()
            case .failure(_):
                print(response.response?.statusCode)
                errorCallback()
            }
        }
    }
    
    func getTribeAdminBadges(
        tribeID:Int?,
        callback: @escaping GetTribeBadgesCallback,
        errorCallback: @escaping EmptyCallback
    ){
        let urlString = (tribeID == nil) ? "/badges?limit=100&offset=0" : "/badge_per_tribe/\(tribeID!)?limit=100&offset=0"
        //let params : [String:Any]? = (tribeID == nil) ? nil : ["chat_id" : tribeID!]
        guard let request = getURLRequest(route: urlString, params: nil, method: "GET") else {
            errorCallback()
            return
        }

        sphinxRequest(request) { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    if let success = json["success"] as? Bool,
                        let response = json["response"] as? [NSDictionary],
                        success {
                        callback((response))
                        return
                    }
                }
                print(response.response?.statusCode)
                errorCallback()
            case .failure(_):
                print(response.response?.statusCode)
                errorCallback()
            }
        }
    }
}
