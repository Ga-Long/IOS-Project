//
//  SignUpViewController.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/11.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var githubIDTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func gotoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        // 1. email , password, githubID 값 받아옴
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let githubID = githubIDTextField.text, !githubID.isEmpty else {
            // 필수 입력 필드가 비어있는 경우 처리할 코드
            // 경고문
            let alertController = UIAlertController(title: "경고", message: "email, password, githubID 다 입력하세요", preferredStyle: .alert)
            let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OkAction)
            present(alertController, animated: true, completion: nil)
            return
            
        }
        
        // 2. githubID 있는 id인지 check -> 함수 사용
        if isExistingGitHubID(githubID) {
            // 3. 있는 id면 firbase에 컬렉션 email 추가 , 문서 "key", field password, author 저장
            saveUserToFirebase(email: email, password: password, githubID: githubID)
            return
            
        }else{ //알림
            let alertController = UIAlertController(title: "알림", message: "존재하지 않는 GitHub ID입니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // GitHub ID가 이미 존재하는지 확인하는 함수의 구현
    func isExistingGitHubID(_ githubID: String) -> Bool {
        // 필요한 로직을 구현하여 존재 여부를 판단하고 true 또는 false를 반환
        // 예를 들어, 서버 API를 호출하여 GitHub ID의 유효성을 검사하는 등의 작업 수행
        guard let url = URL(string: "https://api.github.com/users/\(githubID)") else {
            return false
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode = 0
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        if statusCode == 200 {
            // Github ID가 존재하는 경우
            return true
        }
        
        return false
    }
    
    func saveUserToFirebase(email: String, password: String, githubID: String) {
        // Firebase에 사용자 정보를 저장하는 함수의 구현
        // 필요한 Firebase API 호출 및 데이터 저장 작업 수행
        
        // Cloud Firestore에 "users" 컬렉션에 사용자 데이터 저장
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(email)
        
        userDocument.setData([
            "email": email,
            "password": password,
            "githubID": githubID
        ]) { error in
            if let error = error {
                // 데이터 저장 중에 오류가 발생한 경우 처리할 코드
                // 필요한 알림 또는 사용자 경고를 표시하거나, 오류 메시지를 표시하는 등
                print("Cloud Firestore 데이터 저장 실패: \(error.localizedDescription)")
            } else {
                // 데이터 저장 성공
                print("Cloud Firestore 데이터 저장 성공")
                // 데이터 저장이 완료되면 뒤로 돌아가기
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
}
