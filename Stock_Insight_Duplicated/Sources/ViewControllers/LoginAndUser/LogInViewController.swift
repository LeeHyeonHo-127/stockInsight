import UIKit
import Foundation

class BeginNavigationController: UINavigationController{


}

//class BeginNavigationController: UINavigationController{}

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    //activityIndicatorView
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.color = .blue
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    //UserDefaults Test
    func USERDEFAULTSTEST_set(){
        UserDefaults.standard.set(1, forKey: "1")
    }

    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.USERDEFAULTSTEST_set()
        
        self.addTouchGesture_stopEditing()
        
        if(UserManager.shared.getUser() != nil){
            print("User = nil \(UserManager.shared.getUser())")
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TapBarController") as? UITabBarController else {return}
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)
        }else{
            print("User = \(UserManager.shared.getUser())")
        }
    }

    //viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    


    //MARK: setting 함수들

    //Attach ActivityIndicator
    private func attachActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
    }

    //Dettach ActivityIndicator
    private func detachActivityIndicator() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        self.activityIndicator.removeFromSuperview()
    }
    
    //화면 터치시 키보드 내리는 제스쳐 추가
    func addTouchGesture_stopEditing(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(gesture)
    }
    @objc func handleTap() {
        // 화면이 터치되면 키보드를 내리는 메서드 호출
        view.endEditing(true)
    }

    //MARK: 버튼 눌렸을 시

    //로그인 버튼
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        self.logInWithAPI(email: email, password: password)

        //임시 코드
//        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TapBarController") as? UITabBarController else {return}
//        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //회원가입 버튼
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "ResetPasswordViewController") as? ResetPasswordViewController else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    //MARK: 로그인 함수


    //로그인 함수
    func logInWithAPI(email: String, password: String){
        self.attachActivityIndicator()
        LogInService.shared.logIn(email: email, password: password, completion: {(networkResult) in
            self.detachActivityIndicator()

            switch networkResult{
            case .success(let data):
                //로그인 성공

                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TapBarController") as? UITabBarController else {return}
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)

            case .requestErr(let msg): //존재하지 않는 회원
                if let message = msg as? String {
                    print(message)
                    self.showAlert(title: message)
                }
            case .pathErr:
                self.showAlert(title: "로그인에 실패하였습니다.")
                print("pathErr in logInWithAPI")
            case .serverErr:
                print("serverErr in logInWithAPI")
            case .networkFail:
                
                print("networkFail in logInWithAPI")
            default:
                print("networkFail in logInWithAPI")
            }
        })
    }

    //MARK: 기타 함수

    //showAlert
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }


}


//토큰 저장 코드 임시
/*
func saveToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "UserToken")
    UserDefaults.standard.set(true, forKey: "I")
}
 */



//URLSession LogIn
/*
 func login(email: String, password: String) {
     let urlString = "https://watch.ngrok.app/loginProc"
     guard let url = URL(string: urlString) else {
         DispatchQueue.main.async {
             self.showAlert(title: "url 객체 변환 실패")
         }
         return
     }
//        self.showAlert(title: "url 객체 변환 성공")

     // 요청에 필요한 파라미터 설정
//        let parameter: [String: Any] = [
//            "memberEmail": email,
//            "memberPassword": password
//        ]


     //node.js parameter
     let parameter: [String: Any] = [
         "user_id": email,
         "pw": password
     ]

     // URLRequest 생성
     var request = URLRequest(url: url)
     guard let httpBody = try? JSONSerialization.data(withJSONObject: parameter) else {
         DispatchQueue.main.async {
             self.showAlert(title: "파라미터를 변환하는데 실패했습니다.")
             }
             return
     }
//        showAlert(title: "파라미터를 변환하는데 성공했습니다.")

     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     request.httpBody = httpBody

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
                     self.navigationController?.navigationBar.isHidden = true
                     self.navigationController?.pushViewController(viewController, animated: true)
                 }

//                    if let data = data {
//                        // 응답 데이터 처리
//                        do {
//                            let json = try JSONSerialization.jsonObject(with: data, options: [])
//                            if let responseDict = json as? [String: Any] {
//                                let status = responseDict["status"] as? Int
//                                let message = responseDict["message"] as? String
//                                guard let userToken = responseDict["userToken"] as? String else {return}
//                                self.saveToken(userToken)
//                                DispatchQueue.main.async {
//                                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {return}
//                                    self.navigationController?.pushViewController(viewController, animated: true)
//                                    }
//                            }
//                        } catch {
//                            DispatchQueue.main.async {
//                                self.showAlert(title: "파싱에러")
//                            }
//                        }
//                    }
             } else {
                 DispatchQueue.main.async {
                     self.showAlert(title: "로그인에 실패했습니다")
                 }
             }
         }
     }
     task.resume()
 }
 */
