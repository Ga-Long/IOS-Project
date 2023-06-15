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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath)
        
        let commitMessage = commitMessages[indexPath.row]["message"] as? String
        cell.textLabel?.text = commitMessage
        
        return cell
    }
}
