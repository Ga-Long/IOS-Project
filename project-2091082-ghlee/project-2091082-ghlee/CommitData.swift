//
//  CommitData.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/09.
//

import Foundation

class CommitResponse: Codable {
    let totalCount: Int
    let items: [Commit]
    
    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

class Commit: Codable {
    let message: String
    let commitDate: String
    let author: Author
    
    struct Author: Codable {
        let name: String
        // 다른 필요한 정보들도 추가할 수 있습니다.
    }
    
    private enum CodingKeys: String, CodingKey {
        case message
        case commitDate = "committer_date"
        case author
    }
}


