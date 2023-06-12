//
//  HideAPIKEY++Bundle.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/13.
//

import Foundation

extension Bundle{
    var apiKey: String{
        guard let file = self.path(forResource: "GithubInfo", ofType: "plist") else {return ""}
        
        guard let resource = NSDictionary(contentsOfFile: file) else {return ""}
        guard let key = resource["API_KEY"] as? String else { fatalError("GithubInfo.plist에 API_KEY 설정해주세요.")}
        return key
    }
}
