import Foundation
import Alamofire

struct LogInService{
    static let shared = LogInService()
    
    func logIn(email: String, password: String, completion: @escaping (NetworkResult<Any>) -> Void){
        let url = APIConstants.logInURL
        print("======LogInService.LogIn In=========")
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let parameter: Parameters = [
            "user_id": email,
            "pw": password
        ]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: parameter,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData(completionHandler: {response in
            switch response.result{
            case .success:
                print("======LogiIn Success=========")
                guard let status = response.response?.statusCode else {return}
                guard let data = response.value else {return}
                completion(doLogIn(status: status, data: data, url: URL(string: url)!))
            case .failure(let error):
                print(error)
                completion(.networkFail)
            }
        })
    }
    
    
    func doLogIn(status: Int, data: Data, url: URL) -> NetworkResult<Any>{
        print("======doLogIn In=========")
        
        let failLogIn = "로그인에 실패하였습니다"
        let noID = "존재하지 않는 아이디 입니다"
        let noPW = "비밀번호가 일치하지 않습니다"
        let successLogIn = "로그인에 성공하였습니다"
        
        //jsonString 디코딩
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON String: \(jsonString)")
            if jsonString == "<script> alert('존재하지 않는 아이디입니다.'); location.href='/login';</script>"{
                return .requestErr(noID)
            }else if jsonString == "<script> alert('비밀번호가 일치하지 않습니다.'); location.href='/login';</script>" {
                return .requestErr(noPW)
            }
        } else {
            print("Raw Data: \(data)")
        }
        
    
        switch status {
        case 200: // 로그인 성공
            //토큰 저장
            print("=====Status200 성공!=========")
            let decoder = JSONDecoder()
            guard let decodedData = try? decoder.decode(User.self, from: data) else {return .pathErr}
            print("======Decoding 성공=========")
            print(decodedData)
            
            UserManager.shared.setUser(decodedData) //UserManager에 user저장
            print("User 저장. user = \(decodedData)")
            
//            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
//
//                print("======Decoding 시도=========")
//
//                print(type(of: data))
//                guard let decodedData = try? decoder.decode(User.self, from: data) else {return .pathErr}
//                print("======Decoding 성공=========")
//                print(decodedData)
//
//                for cookie in cookies {
//                    if cookie.name == "access_token" {
////                        print("Received access token:", cookie.value)
//                        UserDefaults.standard.removeObject(forKey: cookie.name)
//                        UserDefaults.standard.set(cookie.value, forKey: cookie.name)
//
//                        let encoder = PropertyListEncoder()
//                        if let encodedData = try? encoder.encode(decodedData) { //유저를 직렬화 해서 UserDefaults애 저장
//                            let userDefaults = UserDefaults.standard
//                            userDefaults.set(encodedData, forKey: decodedData.user_id) //key = user_id
//                        }
//
//                        UserManager.shared.setUser(decodedData) //UserManager에 user저장
//                        print("User 저장. user = \(decodedData)")
//
//                    }
//                    else if cookie.name == "refresh_token"{
////                        print("Received refresh token:", cookie.value)
////                        UserDefaults.standard.set(cookie.value, forKey: cookie.name)
//                    }
//                }
//                return .success(decodedData)
//            }
            return .success(successLogIn)
        case 404:
            print("=====Status404 실패=========")
            // 존재하지 않는 회원
            print("400")
            return .requestErr(noID)
        case 400:
            // 에러
            print("500")
            return .serverErr
        default:
            print("default")
            return .networkFail
            
        }
    }
}



