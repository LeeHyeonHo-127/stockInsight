//
//  MyPageViewController.swift
//  stock Insight
//
//  Created by 이현호 on 2023/05/15.
//

import UIKit

class MyPageViewController: UIViewController {
    
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: 화면 이동 버튼 함수
    
    //비밀번호 수정 화면 이동
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard let viewContrller = self.storyboard?.instantiateViewController(identifier: "ResetPasswordViewController") as? ResetPasswordViewController else {return}
        self.navigationController?.pushViewController(viewContrller, animated: true)
    }
    
    
    //로그아웃 버튼
    @IBAction func logOutButtonTapped(_ sender: Any) {
//        self.logOutWithAPI()
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BeginNavigationController") as? BeginNavigationController else {return}
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)
    }
    
    //회원탈퇴 버튼
    @IBAction func deleteUserButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DeleteUserViewController") as? DeleteUserViewController else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    //MARK: 로그아웃 함수
    
    //로그아웃 함수
    func logOutWithAPI(){
        guard let user_id = UserManager.shared.getUser()?.user_id else {return}
        LogOutService.shared.logOut(user_id: user_id, completion: {networkResult in
            switch networkResult{
            case .success(_):
                
                UserDefaults.standard.removeObject(forKey: "refresh_token")
                UserDefaults.standard.removeObject(forKey: "access_token")

                // 로그인 화면으로 이동합니다.
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BeginNavigationController") as? BeginNavigationController else {return}
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)
            case .requestErr(let msg):
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in logOutWithAPI")
            case .serverErr:
                print("serverErr in logOutWithAPI")
            case .networkFail:
                print("networkFail in logOutWithAPI")
            default:
                print("networkFail in logOutWithAPI")
            }
        })
    }
    
    //urlSeesion Version Logout
    func logOutURLSessionVersion(email: String, password: String) {
        let urlString = "https://watch.ngrok.app/logout"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.showAlert(title: "url 객체 변환 실패")
            }
            return
        }


        // URLRequest 생성
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        
        
        // URLSession을 사용하여 요청 보내기
        let task = URLSession.shared.dataTask(with: request) { [weak self](data, response, error) in
            guard let self = self else {return}
            
            if let error = error{
                let code = (error as NSError).code
                switch code{
                case 17007: //아이디 및 비밀버호가 다를 때
                    DispatchQueue.main.async {
                        self.showAlert(title: "아이디/비밀번호를 확인해 주세요")
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        self.showAlert(title: "로그인 에러", message: "\(error.localizedDescription)")
                    }
                    return
                }
            }
            
            //httpResponse 응답 처리
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TapBarController") as? UITabBarController else {return}
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "로그인에 실패했습니다")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    //MARK: 기타 함수
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
}
