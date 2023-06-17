//
//  ShowCommitMessageViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/16.
//

import UIKit

class ShowCommitMessageViewController: UIViewController {
    
    @IBOutlet weak var commitMessageTableView: UITableView!
    
    var commitMessages: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commitMessageTableView.dataSource = self
    }
    
    
    
    @IBAction func okButton(_ sender: UIButton) {
        // 모달 창 닫기
        dismiss(animated: true, completion: nil)
    }
    
}

//ShowCommitMessageViewController에 content 내용 넣기
extension ShowCommitMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commitMessages.count
    }
    
    // 해당 날짜의 커밋한 message와 repo fullname 정보를 보여줌
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath)
        
        let commitMessage = commitMessages[indexPath.row]["message"] as? String
        let fullname = commitMessages[indexPath.row]["repoFullname"] as? String
        
        // 커밋 메시지 출력
        if let messageLabel = cell.viewWithTag(1) as? UILabel {
            messageLabel.text = commitMessage
            messageLabel.textColor = UIColor(red: 38/255, green: 166/255, blue: 65/255, alpha: 1.0) // #26A641
            
        }
        // 두 번째 레이블(Tag: 2)을 가리키기 위해 viewWithTag 메서드 사용
        // repo 경로 출력
        if let fullnameLabel = cell.viewWithTag(2) as? UILabel {
            // fullnameLabel을 조작
            fullnameLabel.text = fullname
        }
        
        
        return cell
    }
}
