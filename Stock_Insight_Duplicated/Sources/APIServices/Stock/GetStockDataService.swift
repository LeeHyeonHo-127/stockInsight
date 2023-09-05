import Foundation
import Alamofire


struct GetStockDataService{
    static let shared = GetStockDataService()
    
    func getStockData(completion: @escaping (NetworkResult<Any>) -> (Void)){
        // Yahoo Finance API URL
        
        let url = "https://query1.finance.yahoo.com/v8/finance/chart/005930.KS"

        print("========GetStockDataService getStockData In========")
        AF.request(url).responseJSON { response in
            
            
            switch response.result {
            case .success(let value):
                // 데이터 처리 로직
                print("========GetStockDataService response.success In========")
                
                //JSON 값 확인
                /*
                if let jsonString = String(data: response.data!, encoding: .utf8) {
                    // Print the JSON string to check the format
                    print("judgeSearchStock in JSON String: \(jsonString)")
                } else {
                    // If converting to a string fails, print the raw data
                    print("Raw Data: \(response)")
                }
                */
                
                //파싱 한 값을 전달
                completion(parsingData(data: response.data!))
                
                // JSON 데이터 디코딩
//                if let jsonData = response.data!(using: .utf8) {
//                    do {
//                        let decoder = JSONDecoder()
//                        let stockData = try decoder.decode(StockData.self, from: jsonData)
//
//                        // "close" 값을 가져옵니다.
//                        let closeValues = stockData.chart.result[0].indicators.close
//                        print(closeValues) // 이제 close 값을 사용할 수 있습니다.
//                    } catch {
//                        print("JSON 디코딩 에러: \(error.localizedDescription)")
//                    }
//                } else {
//                    print("JSON 데이터를 변환하는데 실패했습니다.")
//                }
                
                
                
                
//                completion(parsingData(jsonString: value as! String))
//                print(value)
                
                // 여기서부터 value 변수에 담긴 데이터를 원하는 형태로 가공하거나 활용할 수 있습니다.
                
            case .failure(let error):
                completion(.networkFail)
            
            }
        }
    }
    
    func parsingData(data: Data) -> NetworkResult<Any>{
        print("======== parsingData In========")
        // JSON 문자열을 Data로 변환
        
        //JSON 값 확인
        if let jsonString = String(data: data, encoding: .utf8) {
            // Print the JSON string to check the format
            print("parsingData in JSON String: \(jsonString)")
        } else {
            // If converting to a string fails, print the raw data
            print("Raw Data: \(data)")
        }
        
        print("====Decoding 시작=====")
        
  
        
        let decoder = JSONDecoder()
        guard let stockDataResponse = try? decoder.decode(StockDataResponse.self, from: data) else {return .pathErr}
        
        print("====Decoding 성공=====")
        
        // "close" 값을 추출하여 반환
        let closeValues = stockDataResponse.chart.indicators.quote.close
        return .success(closeValues)
    }
    
    func getCloseValue_Test(){
        print("=======getCloseValue_test In======")
        
        // Yahoo Finance API URL
        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/005930.KS")!
        
        print("=======getCloseValue_test In 2======")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    // JSON 데이터 파싱
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let chartResult = json["chart"] as? [String: Any],
                       let resultArray = chartResult["result"] as? [[String: Any]],
                       let firstResult = resultArray.first,
                       let indicators = firstResult["indicators"] as? [String: Any],
                       let quoteDataArray = indicators["quote"] as? [[String: Any]],
                       let firstQuoteData = quoteDataArray.first,
                       let closeValues = firstQuoteData["close"] as? [Double] {
                        // close 값 출력
                        print("종가 출력")
                        print(closeValues)
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
        }
        print("=======task.resume======")
        task.resume()
    }
        
}



//받는 JSON 형태
/*

{"chart":{"result":[{"meta":{"currency":"KRW","symbol":"005930.KS","exchangeName":"KSC","instrumentType":"EQUITY","firstTradeDate":946944000,"regularMarketTime":1693549821,"gmtoffset":32400,"timezone":"KST","exchangeTimezoneName":"Asia/Seoul","regularMarketPrice":71000.0,"chartPreviousClose":66900.0,"previousClose":66900.0,"scale":3,"priceHint":2,"currentTradingPeriod":{"pre":{"timezone":"KST","start":1693521000,"end":1693526400,"gmtoffset":32400},"regular":{"timezone":"KST","start":1693526400,"end":1693548000,"gmtoffset":32400},"post":{"timezone":"KST","start":1693548000,"end":1693558800,"gmtoffset":32400}},"tradingPeriods":[[{"timezone":"KST","start":1693526400,"end":1693548000,"gmtoffset":32400}]],"dataGranularity":"1m","range":"1d","validRanges":["1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"]},"timestamp":[3980,1693544040,1693544100,1693544160,1693544220,1693544280,1693544340,1693544400,1693544460,1693544520,1693544580,1693544640,1693544700,1693544760,1693544820,1693544880,1693544940,1693545000,1693545060,1693545120,1693545180,1693545240,1693545300,1693545360,1693545420,1693545480,1693545540,1693545600,1693545660,1693545720,1693545780,1693545840,1693545900,1693545960,1693546020,1693546080,1693546140,1693546200,1693546260,1693546320,1693546380,1693546440,1693546500,1693546560,1693546620,1693546680,1693546740,1693546800,1693546860,1693546920,1693546980,1693547040,1693547100,1693547160,1693547220,1693547280,1693547340,1693547400,1693547460,1693547520,1693547580,1693547640,1693547700,1693547760,1693547820,1693547880,1693547940,1693548000],"indicators":{"quote":[{"open":[66800.0,66700.0,67100.0,67100.0,67300.0,67500.0,67300.0,67400.0,67400.0,67300.0,67300.0,67400.0,67400.0,67400.0,67300.0,67400.0,67400.0,67500.0,67700.0,67600.00,70200.0,70200.0,70100.0,70200.0,70400.0,70500.0,70500.0,70400.0,70400.0,70400.0,70400.0,70500.0,70500.0,70500.0,70700.0,70600.0,70700.0,70800.0,70900.0,71000.0,70800.0,70700.0,70700.0,70700.0,70600.0,70700.0,70700.0,70800.0,70700.0,70700.0,70800.0,70700.0,70700.0,70700.0,70700.0,70700.0,70600.0,70600.0,70800.0,70800.0,70800.0,70900.0,71000.0,71000.0,70900.0,70900.0,70900.0,70900.0,70800.0,70800.0,70900.0,70700.0,70800.0,71000.0],"low":[66700.0,66700.0,67000.0,67100.0,67200.0,67300.0,67300.0,67300.0,67200.0,67300.0,67300.0,67300.0,67300.0,67300.0,67300.0,67300.0,67400.0,67500.0,67600.0,679100.0,69100800.0,70800.0,70700.0,70700.0,70700.0,71000.0],"high":[66800.0,67100.0,67200.0,67300.0,67600.0,67600.0,67500.0,67400.0,67400.0,67500.0,67500.0,67500.0,67400.0,67400.0,67400.0,67500.0,67600.0,67800.0,67800.0,67900.0,68000.0,68100.0,68200.0,68400.0,68500.0,68400.0,68400.0,68500.0,68500.0,68600.0,68500.0,68600.0,68700.0,68700.0,68700.0,68700.0,68800.0,68900.0,68900.0,69100.0,69000.0,690000.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69300.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,null,69400.0,69400.0,69400.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69600.0,69600.0,69600.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,697000.0,70700.0,70700.0,70700.0,70700.0,70800.0,70800.0,70800.0,70800.0,70800.0,70700.0,70700.0,70700.0,70700.0,70700.0,70700.0,70800.0,70800.0,70800.0,70900.0,71000.0,71000.0,71000.0,71000.0,71000.0,71000.0,71000.0,70900.0,70900.0,70900.0,70900.0,70800.0,71000.0],"close":[66700.0,67100.0,67200.0,67300.0,67500.0,67300.0,67400.0,67300.0,67300.0,67300.0,67500.0,67300.0,67300.0,67400.0,67300.0,67400.0,67600.0,67700.0,67600.0,67700.0,68000.0,68000.0,0,69100.0,69100.0,69200.0,69200.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69200.0,69100.0,69200.0,69200.0,69200.0,69100.0,69200.0,69200.0,69100.0,69200.0,69200.0,69200.0,69200.0,69100.0,69100.0,69200.070500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70600.0,70600.0,70600.0,70600.0,70700.0,70700.0,70900.0,71000.0,70900.0,70700.0,70700.0,70600.0,70600.0,70600.0,70600.0,70800.0,70700.0,70700.0,70800.0,70600.0,70600.0,70600.0,70700.0,70700.0,70700.0,70600.0,70800.0,70800.0,70700.0,70800.0,70900.0,71000.0,71000.0,70900.0,70900.0,70900.0,70800.0,70900.0,70800.0,70700.0,70800.0,70800.0,71000.0],"volume":[0,251018,162913,186008,328545,220072,169849,107401,70810,149911,46739,132798,18092,16028,15031,206410,281492,279860,181353,200351,243150,280303,102098,431717,,2157159,42733,0]}]}}],"error":null}}
*/

