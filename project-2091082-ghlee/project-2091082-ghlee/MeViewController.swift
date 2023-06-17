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
    @IBOutlet weak var totalGrassLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = Owner.getEmail()
        authorLabel.text = Owner.getOwner()
        
        let totalGrassText = "총 \(Owner.getMonthTotal()) 잔디를 심었어요!"
        
        let attributedText = NSMutableAttributedString(string: totalGrassText)
        let boldFont = UIFont.boldSystemFont(ofSize: totalGrassLabel.font.pointSize)
        let coloredRange = (totalGrassText as NSString).range(of: "\(Owner.getMonthTotal())")
        let blackColor = UIColor(red: 0.15, green: 0.65, blue: 0.25, alpha: 1.0) // #26a641
        let redColor = UIColor(red: 0.92, green: 0.47, blue: 0.38, alpha: 1.0) // #EA7960
        
        // Bold 설정
        attributedText.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: attributedText.length))
        
        // 색상 설정
        attributedText.addAttribute(.foregroundColor, value: blackColor, range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttribute(.foregroundColor, value: redColor, range: coloredRange)
        
        totalGrassLabel.attributedText = attributedText
        
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
