import Foundation
import Alamofire
import SwiftYFinance

struct GetStockFromYFService{
    static let shared = GetStockFromYFService()
    
    func getStockDataFromYF(stockCode: String) -> [[Date: Double]]{
        
        let symbol = stockCode + ".KS" // 삼성전자 종목 심볼, ".KS"는 한국 주식 시장을 나타냅니다.
        var stockData = [[Date: Double]]()
        
        // 시작 및 종료 날짜 설정
        let dateFormatter_onlyDate = DateFormatter()
        dateFormatter_onlyDate.dateFormat = "yyyy-MM-dd"
        
        let dateFormatter_DateAndTime = DateFormatter()
        dateFormatter_DateAndTime.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
        
        let startDate = dateFormatter_onlyDate.date(from: "2020-01-01")
        let endDate = Date()
        
        let calendar = Calendar.current
        
        // 종가 데이터 가져오기
        SwiftYFinance.chartDataBy(identifier: symbol, start: startDate!, end: endDate, interval: .oneday){
            data, error in
            if let chartData = data{
                let transformedData: [[Date: Double]] = chartData.compactMap { data in
                    guard let date = data.date, let close = data.close else {
                        return [Date: Double]() // 날짜나 종가 데이터가 없으면 무시
                    }
                    return [date: Double(close)]
                }
                stockData = transformedData
//                print("transformedData = \(transformedData)")
            }
        }
        return stockData
    }
    
    
    
    
}

/*
struct GetStockDataService{
    static let shared = GetStockDataService()
    
    //종목의 1년치 종가 받아오기
    func getStockData(stockCode: String, completion: @escaping (NetworkResult<Any>) -> (Void)){
        // Yahoo Finance API URL
        let url = "https://query1.finance.yahoo.com/v8/finance/chart/\(stockCode).KS?interval=1d&range=1y"
        print("printURL: \(url)")
        
        
        //되는 url
        //let url = "https://query1.finance.yahoo.com/v8/finance/chart/005930.KS?interval=1d&range=1y"
        
        print("========GetStockDataService getStockData In========")
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                // 데이터 처리 로직
                print("========GetStockDataService response.success In========")
                
                //파싱 한 값을 전달
                completion(parsingData(data: response.data!))
                
            case .failure(let error):
                completion(.networkFail)

            }
        }
    }
    
    func parsingData(data: Data) -> NetworkResult<Any>{
        print("======== parsingData In========")
        var decodedData = ""

        //점검 코드
        
        print("isJSON : \(isJSONValid(data: data))")
        print(" type : \(type(of: data))")
        
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

        do {
            let decodedData = try decoder.decode(StockChartResponse.self, from: data)
            print("디코딩 성공")
            return .success(decodedData.chart.result[0].indicators.quote[0].close)
        } catch {
            print("Error:", error)
        }
    
        print("====Decoding 실패=====")
        
        return .networkFail
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

*/

//받는 JSON 형태
/*

{"chart":{"result":[{"meta":{"currency":"KRW","symbol":"005930.KS","exchangeName":"KSC","instrumentType":"EQUITY","firstTradeDate":946944000,"regularMarketTime":1693549821,"gmtoffset":32400,"timezone":"KST","exchangeTimezoneName":"Asia/Seoul","regularMarketPrice":71000.0,"chartPreviousClose":66900.0,"previousClose":66900.0,"scale":3,"priceHint":2,"currentTradingPeriod":{"pre":{"timezone":"KST","start":1693521000,"end":1693526400,"gmtoffset":32400},"regular":{"timezone":"KST","start":1693526400,"end":1693548000,"gmtoffset":32400},"post":{"timezone":"KST","start":1693548000,"end":1693558800,"gmtoffset":32400}},"tradingPeriods":[[{"timezone":"KST","start":1693526400,"end":1693548000,"gmtoffset":32400}]],"dataGranularity":"1m","range":"1d","validRanges":["1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"]},"timestamp":[3980,1693544040,1693544100,1693544160,1693544220,1693544280,1693544340,1693544400,1693544460,1693544520,1693544580,1693544640,1693544700,1693544760,1693544820,1693544880,1693544940,1693545000,1693545060,1693545120,1693545180,1693545240,1693545300,1693545360,1693545420,1693545480,1693545540,1693545600,1693545660,1693545720,1693545780,1693545840,1693545900,1693545960,1693546020,1693546080,1693546140,1693546200,1693546260,1693546320,1693546380,1693546440,1693546500,1693546560,1693546620,1693546680,1693546740,1693546800,1693546860,1693546920,1693546980,1693547040,1693547100,1693547160,1693547220,1693547280,1693547340,1693547400,1693547460,1693547520,1693547580,1693547640,1693547700,1693547760,1693547820,1693547880,1693547940,1693548000],"indicators":{"quote":[{"open":[66800.0,66700.0,67100.0,67100.0,67300.0,67500.0,67300.0,67400.0,67400.0,67300.0,67300.0,67400.0,67400.0,67400.0,67300.0,67400.0,67400.0,67500.0,67700.0,67600.00,70200.0,70200.0,70100.0,70200.0,70400.0,70500.0,70500.0,70400.0,70400.0,70400.0,70400.0,70500.0,70500.0,70500.0,70700.0,70600.0,70700.0,70800.0,70900.0,71000.0,70800.0,70700.0,70700.0,70700.0,70600.0,70700.0,70700.0,70800.0,70700.0,70700.0,70800.0,70700.0,70700.0,70700.0,70700.0,70700.0,70600.0,70600.0,70800.0,70800.0,70800.0,70900.0,71000.0,71000.0,70900.0,70900.0,70900.0,70900.0,70800.0,70800.0,70900.0,70700.0,70800.0,71000.0],"low":[66700.0,66700.0,67000.0,67100.0,67200.0,67300.0,67300.0,67300.0,67200.0,67300.0,67300.0,67300.0,67300.0,67300.0,67300.0,67300.0,67400.0,67500.0,67600.0,679100.0,69100800.0,70800.0,70700.0,70700.0,70700.0,71000.0],"high":[66800.0,67100.0,67200.0,67300.0,67600.0,67600.0,67500.0,67400.0,67400.0,67500.0,67500.0,67500.0,67400.0,67400.0,67400.0,67500.0,67600.0,67800.0,67800.0,67900.0,68000.0,68100.0,68200.0,68400.0,68500.0,68400.0,68400.0,68500.0,68500.0,68600.0,68500.0,68600.0,68700.0,68700.0,68700.0,68700.0,68800.0,68900.0,68900.0,69100.0,69000.0,690000.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69200.0,69300.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,69400.0,null,69400.0,69400.0,69400.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69500.0,69600.0,69600.0,69600.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,69700.0,697000.0,70700.0,70700.0,70700.0,70700.0,70800.0,70800.0,70800.0,70800.0,70800.0,70700.0,70700.0,70700.0,70700.0,70700.0,70700.0,70800.0,70800.0,70800.0,70900.0,71000.0,71000.0,71000.0,71000.0,71000.0,71000.0,71000.0,70900.0,70900.0,70900.0,70900.0,70800.0,71000.0],"close":[66700.0,67100.0,67200.0,67300.0,67500.0,67300.0,67400.0,67300.0,67300.0,67300.0,67500.0,67300.0,67300.0,67400.0,67300.0,67400.0,67600.0,67700.0,67600.0,67700.0,68000.0,68000.0,0,69100.0,69100.0,69200.0,69200.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69100.0,69100.0,69200.0,69100.0,69200.0,69100.0,69200.0,69200.0,69100.0,69200.0,69200.0,69200.0,69100.0,69200.0,69200.0,69100.0,69200.0,69200.0,69200.0,69200.0,69100.0,69100.0,69200.070500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70500.0,70600.0,70600.0,70600.0,70600.0,70700.0,70700.0,70900.0,71000.0,70900.0,70700.0,70700.0,70600.0,70600.0,70600.0,70600.0,70800.0,70700.0,70700.0,70800.0,70600.0,70600.0,70600.0,70700.0,70700.0,70700.0,70600.0,70800.0,70800.0,70700.0,70800.0,70900.0,71000.0,71000.0,70900.0,70900.0,70900.0,70800.0,70900.0,70800.0,70700.0,70800.0,70800.0,71000.0],"volume":[0,251018,162913,186008,328545,220072,169849,107401,70810,149911,46739,132798,18092,16028,15031,206410,281492,279860,181353,200351,243150,280303,102098,431717,,2157159,42733,0]}]}}],"error":null}}
*/

