import Foundation
import Alamofire

struct GetStockService{
    static let shared = GetStockService()
    
    //종목 검색
    func getStock(stockName: String,
                completion: @escaping (NetworkResult<Any>) -> (Void) ) {
        
//        print("======getStock.getStock In=========")
        
        let url = APIConstants.getStockInfo
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body: Parameters = [
            "stockName" : stockName
        ]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: body,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData(completionHandler: {(response) in
            switch response.result{
            case .success:
                print("======getStock Success=========")
                
     
                
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                guard let data = response.data else {
                    return
                }
                completion(judgeGetStock(status: statusCode, data: data))
            case .failure(let error):
                print(error)
                completion(.networkFail)
            }
        })
    }
    
    //종목 검색 여부 확인
    private func judgeGetStock(status: Int, data: Data) -> NetworkResult<Any>{
        let decoder = JSONDecoder()
//        print("======judgeGetStock In=========")
//        
//        print("isJSON : \(isJSONValid(data: data))")
//        print(" type : \(type(of: data))")
        
        /*
        if let jsonString = String(data: data, encoding: .utf8) {
            print("judgeSearchStock in JSON String: \(jsonString)")
        } else {
            // If converting to a string fails, print the raw data
            print("Raw Data: \(data)")
        }
        */
        
        
//        print("=======decoding 시작===========")
        
//        guard let decodedData = try? decoder.decode(StockInfo.self, from: data) else {return .pathErr}
        
        do {
            let decodedData = try decoder.decode(StockInfo2.self, from: data)
            return .success(decodedData)
        } catch {
            print("Error:", error)
        }
     
        
        
//        print("=======decoding 성공===========")

        switch status {
//        case 200:
//            // 성공
//            return .success(decodedData)
        case 408:
            // 주식 API 문제로 요청 시간초과
            var overTimeMessage = "주식 API 문제로 요청 시간초과"
            return .requestErr(overTimeMessage)
        case 400:
            // 잘못된 파라미터
            return .wrongParameter
        default:
            return .networkFail
        }
    }
    
    
    //JSON인지 확인하기
    func isJSONValid(data: Data) -> Bool {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return JSONSerialization.isValidJSONObject(jsonObject)
        } catch {
            print("Error checking if data is valid JSON:", error)
            return false
        }
    }
}
