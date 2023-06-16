//
//  LoginViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/11.
//

import UIKit
import FirebaseFirestore

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully(withGithubID githubID: String, withEmail email: String )
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var githubID: String?
    weak var delegate: LoginViewControllerDelegate?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func gotoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func loginButton(_ sender: UIButton) {
        // 1. email , password 값 받아옴
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // 필수 입력 필드가 비어있는 경우 처리할 코드
            // 경고문
            showloginmalformattedAlert()
            return
            
        }
        
        
        // 2. email 있는 email인지 check -> 함수 사용
        checkEmailExists(email: email, password: password) { emailExists in
            if emailExists {
                print("emailExists")
                
                // 1. Users의 해당 이메일의 githubID 주소 가지고 와서 Delegate
                self.getGitHubIDFromEmailCollection(email: email) { [weak self] githubID in
                    if let githubID = githubID {
                        self?.delegate?.didLoginSuccessfully(withGithubID: githubID, withEmail: email)
                    } else {
                        print("No githubID")
                    }
                    self?.dismiss(animated: true, completion: nil)
                }

            } else {
                // Email 컬렉션에 문서가 존재하지 않는 경우
                self.showLoginAlert()
            }
        }


    }
    
    //후행 클로저 사용 -> 비동기적으로 처리
    func checkEmailExists(email: String, password: String, completion: @escaping (Bool) -> Void) {
        print("email \(email), password \(password)")
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        
        collectionRef.whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(false) // 오류 발생 시 false 반환
            } else if querySnapshot?.isEmpty == false {
                // 이메일이 일치하는 문서가 존재하는 경우
                if let document = querySnapshot?.documents.first, let passwordFromFirestore = document.data()["password"] as? String {
                    if password == passwordFromFirestore {
                        // 비밀번호도 일치하는 경우
                        print("password equal")
                        completion(true) // 이메일과 비밀번호 일치하여 true 반환
                    } else {
                        completion(false) // 비밀번호 불일치 시 false 반환
                    }
                }
            } else {
                completion(false) // 이메일이 일치하는 문서 없을 시 false 반환
            }
        }
    }
    
    func getGitHubIDFromEmailCollection(email: String, completion: @escaping (String?) -> Void) {
        // 해당 "users" 컬렉션의 email 문서의 "githubID" 값을 가져오는 로직을 구현
        // 필요한 Firebase Firestore API 호출 및 데이터 조회 작업 수행

        // 예시: Firebase Firestore에서 해당 문서 가져오기
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(email)

        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 문서가 존재하는 경우
                let data = document.data()
                let githubID = data?["githubID"] as? String
                completion(githubID)
            } else {
                completion(nil)
            }
        }
    }
    
     //textField 다 안채움 알림
    func showloginmalformattedAlert(){
        let alertController = UIAlertController(title: "경고", message: "email, password 다 입력하세요", preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OkAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // email, password 실패 알림
    func showLoginAlert() {
        let alert = UIAlertController(title: "로그인 실패", message: "유효하지 않은 이메일이거나 없는 비밀번호입니다. 다시 로그인해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}


