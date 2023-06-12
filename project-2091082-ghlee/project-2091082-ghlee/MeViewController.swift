//
//  MeViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/11.
//

import UIKit

class MeViewController: UIViewController {
    
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = Owner.getEmail()
        authorLabel.text = Owner.getOwner()
        
        
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            // UserDefaults에서 "owner" 값을 삭제
            UserDefaults.standard.removeObject(forKey: "owner")
            // Owner 클래스의 owner 속성도 초기화
            Owner.owner = nil
            
            // 첫 화면으로 돌아가기
            self.dismiss(animated: true) { [weak self] in
                // PlanGroupViewController 화면 전환
                self?.showStartViewController()
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func showStartViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startViewController = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        startViewController.modalPresentationStyle = .fullScreen
        self.present(startViewController, animated: true, completion: nil)
       
    }
    
    
    
}
