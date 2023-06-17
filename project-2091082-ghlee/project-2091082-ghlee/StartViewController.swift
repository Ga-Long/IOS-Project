//
//  StartViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/11.
//

import UIKit

// LoginViewController에서 데이터를 받음

class StartViewController: UIViewController, LoginViewControllerDelegate{
    
    func didLoginSuccessfully(withGithubID githubID: String, withEmail email: String) {
        print("StartViewController : didLoginSuccessfully() 호출")
        // 로그인 성공 후의 처리 로직
        Owner.setOwner(githubID: githubID)
        Owner.setEmail(email: email)
        
        dismiss(animated: true) { [weak self] in
            // PlanGroupViewController 화면 전환
            self?.showPlanGroupViewController()
        }
    }
    
    
    var githubID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("start: ", Owner.getOwner())
        // owner, email 값 이미 있으면 PlanGroupViewController 화면으로
        let ownerLoaded = Owner.loadOwner(sender: self)
        if ownerLoaded {
            dismiss(animated: true) { [weak self] in
                // PlanGroupViewController 화면 전환
                self?.showPlanGroupViewController()
            }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
        
    }
    
}

