//
//  Owner.swift
//  ch10-leejaemoon-stackView
//
//  Created by jmlee on 2023/04/27.
//

import UIKit
class Owner{
    static var owner: String?
    static var email: String?
    
    static func loadOwner(sender: UIViewController) -> Bool{ // sender은 present함수를 위해서 필요하다
        if let owner = UserDefaults.standard.string(forKey: "owner"),
           let email = UserDefaults.standard.string(forKey: "email"){ // preferences에 이미 있다면
            Owner.owner = owner
            Owner.email = email; return true    // 읽어서 저장하고 리턴한다
        }
        return false
    }
    static func getOwner() -> String{
        if let owner = Owner.owner{return owner } // 읽혀진게 있으면 owner을 리턴
        return ""       // 없으면 “”를 리턴
    }
    static func getEmail() -> String{
        if let email = Owner.email{return email } // 읽혀진게 있으면 owner을 리턴
        return ""       // 없으면 “”를 리턴
    }
    
    static func setOwner(githubID: String){
        if !githubID.isEmpty {
            Owner.owner = githubID
            UserDefaults.standard.set(githubID, forKey: "owner") // UserDefaults에 저장합니다.
        }
    }
    
    static func setEmail(email: String){
        if !email.isEmpty {
            Owner.email = email
            UserDefaults.standard.set(email, forKey: "email") // UserDefaults에 저장합니다.
        }
    }
}
