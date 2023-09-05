import Foundation
import Alamofire

struct BookmarkService{
    static let shared = BookmarkService()
    
    //즐겨찾기 추가하기
    func addBookmark(title: String, code: String, completion: @escaping (NetworkResult<Any>) -> Void){
        let url = APIConstants.addBookmark
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let parameter: Parameters = [
            "title": title,
            "code": code
        ]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: parameter,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData(completionHandler: {response in
            switch response.result{
            case .success:
                guard let status = response.response?.statusCode else {return}
                guard let data = response.value else {return}
                completion(judgeAddBookmark(status: status, data: data))
            case .failure(let error):
                print(error)
                completion(.networkFail)
            }
        })
    }
    
    
    func judgeAddBookmark(status: Int, data: Data) -> NetworkResult<Any>{
        switch status {
        case 200:
            //즐겨찾기 추가 성공
            return .success(data)
        case 400:
            // 에러
            print("400")
            return .requestErr(data)
        default:
            print("default")
            return .networkFail
            
        }
    }
}
