//
//  StartViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/11.
//

import UIKit

// LoginViewController에서 데이터를 받음

class StartViewController: UIViewController, LoginViewControllerDelegate{
    func didLoginSuccessfully(withGithubID githubID: String) {
        print("StartViewController : didLoginSuccessfully() 호출")
        // 로그인 성공 후의 처리 로직
        UserDefaults.standard.set(githubID, forKey: "githubID")
        performSegue(withIdentifier: "TabBarController", sender: nil)
        
    }
    
 
    var githubID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 만약 "owner"에 값이 존재하면
        if Owner.getOwner() != "" {
            // Plan Group View Controller Scene으로 전환
            performSegue(withIdentifier: "TabBarController", sender: nil)

        }
        
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
    }
    
    @IBAction func loginButton(_ sender: Any) {
    }
    
    func didLoginWithGitHubID(_ githubID: String) {
        // 전달받은 GitHub ID를 활용하여 작업 수행
        print("didLoginWithGitHubID 함수 실행")
        Owner.owner = githubID
        UserDefaults.standard.set(githubID, forKey: "owner")
        
        // PlanGroupViewController로 전환
        showPlanGroupViewController()
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSignUp"{
            let signUpViewController = segue.destination as! SignUpViewController
            
        }
        
        if segue.identifier == "showLogin"{
            if let loginViewController = segue.destination as? LoginViewController {
                loginViewController.delegate = self
            }

        }
    }
    
    func saveGitHubIDToUserDefaults() {
        print("saveGitHubIDToUserDefaults() 실행")
        if let githubID = githubID {
            Owner.owner = githubID
            UserDefaults.standard.set(githubID, forKey: "owner")
        }
    }

    func showPlanGroupViewController() {
        print("showPlanGroupViewController() 실행")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let planGroupViewController = storyboard.instantiateViewController(withIdentifier: "PlanGroupViewController") as? PlanGroupViewController else {
            return
        }
        navigationController?.pushViewController(planGroupViewController, animated: true)
    }
    
}

//extension StartViewController: LoginViewControllerDelegate {
//    func didLoginWithGithubID(_ githubID: String) {
//        self.githubID = githubID
//        saveGitHubIDToUserDefaults()
//        performSegue(withIdentifier: "PlanGroupSegue", sender: nil)
//    }
//}
