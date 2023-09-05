import UIKit
import Charts

enum ChartDataType: String{
    case sentimentalPredict = "감성분석"
    case presentPrice = "현재주가"
    case predict5day = "5일 예측"
    case predict10day = "10일 예측"
    case KOSPI = "KOSPI"
    case KOSDAQ = "KOSDAQ"
    case KOSPI200 = "KOSPI200"
    
}


class MainViewContoller: UIViewController {
    
    //label, textField
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var stockNameLabel: UILabel!
    @IBOutlet var stockCodeLabel: UILabel!
    
    @IBOutlet var presentPriceLabel: UILabel!
    @IBOutlet var presentPriceLabel2: UILabel!
    @IBOutlet var changePriceLabel: UILabel!
    @IBOutlet var krwLabel: UILabel!
    
    
    
    @IBOutlet var changePriceLabel2: UILabel!
    
    @IBOutlet var indexViewTypeLabel: UILabel!
    @IBOutlet var predictViewTypeLabel: UILabel!
    
    //button
    @IBOutlet var presentPriceButton: UIButton!
    @IBOutlet var LSTMButton: UIButton!
    @IBOutlet var sentimentalButton: UIButton!
    
    @IBOutlet var kospiButton: UIButton!
    @IBOutlet var kosdaqButton: UIButton!
    @IBOutlet var kospi200Button: UIButton!
    
    
    //chartView를 띄울 UIView
    @IBOutlet var predicePriceView: UIView!
    @IBOutlet var indexView: UIView!
    
    //ChartView
    var predictLineChartView: LineChartView!
    var indexLineChartView: LineChartView!
//    predictLineChartView.delegate = self
//    indexLineChartView.delegate = self
    
    
    //뉴스 뷰
    @IBOutlet var everyDayEconomyView: UIView!
    @IBOutlet var hankyungBusinessView: UIView!
    @IBOutlet var economistView: UIView!
    
    //data
    var searchStockData: Stock?
    var presentStockData: Stock?
    var indexDatas: IndexData?
    
    
    //Dummy data
    var gradientColor = UIColor.stockInsightBlue
    var datasetName: String = "5d_predict_SE00"
    var searchStockData_Dummy: Stock_Dummy?
    var presentStockData_Dummy: Stock_Dummy?
    
    var test: String = ""



    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //data 가져오기
        //self.getIndexWithAPI() //지수 가져오기
        
        
        
//        self.getPresentStockWithAPI(stockName: "하이브") //현재 보여질 주식에 대한 값 가져오기
//        let kospiData = self.downloadCSVFile(indexURL: URL(string: "https://cf51-39-118-146-59.ngrok-free.app/download/KOSPI_data.csv")!)
     
        //지수 가져오기 테스트
//        if let csvData = try? Data(contentsOf: URL(string: "https://cf51-39-118-146-59.ngrok-free.app/download/KOSPI_data.csv")!){
//            guard let csvString = String(data: csvData, encoding: .utf8) else {return}
//            self.test = csvString
//            print("kospiData = \(csvData)")
//        }
        
        //주가 과거 데이터 가져오기 연습1
        
        GetStockDataService.shared.getStockData(completion: { (networkResult) in
            switch networkResult{
            case .success(let data):
                print(type(of: data))
                print("주식 과거 데이터: \(data)")
            default:
                print("주식 과거 데이터 가져오기 오류")
            }
        })
        
        //주가 과거 데이터 가져오기 연습2
//        GetStockDataService.shared.getCloseValue_Test()
        
       
        
        //Dummy Data 가져오기
        self.getPresentStock_Dummy()
        self.getIndex_Dummy()
        
        //더미 유저 UserManager에 저장
        self.setUser_dummy()
        //유저 정보 갖고오기
//        self.getUser()
        
        
        //뷰 세팅
        self.settingView()
        
        //제스쳐 세팅
        self.gestureSetting()
        
        //주가 그래프 뷰 세팅
        self.predictLineChartView = configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .presentPrice)
        self.indexLineChartView = configureChartView(isPredict: true, color: UIColor.systemOrange, chartDataType: .KOSPI)
        self.predicePriceView.addSubview(predictLineChartView)
        self.indexView.addSubview(indexLineChartView)
        self.predictViewLabeSetting(type: .KOSPI)
        self.predictViewLabeSetting(type: .presentPrice)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - 설정 함수
    
    //뷰 세팅
    func settingView(){
        
        guard let currentPrice = self.presentStockData_Dummy?.currentPrice else {return}
        guard let change = self.presentStockData_Dummy?.change else {return}
        let changePrice = 1600
        //주식 변동율 = ((현재 가격 – 이전 가격) / 이전 가격) x 100
        
        
        //오늘 날짜 가져오기
        let currentDate = Date()
        let calendar = Calendar.current
        let monthComponent = calendar.component(.month, from: currentDate)
        let dayComponent = calendar.component(.day, from: currentDate)
        self.dateLabel.text = "\(monthComponent)월 \(dayComponent)일"
        
      
        
        //cornerRadius 설정
        self.presentPriceButton.layer.cornerRadius = 5
        self.LSTMButton.layer.cornerRadius = 5
        self.sentimentalButton.layer.cornerRadius = 5
        self.kospiButton.layer.cornerRadius = 5
        self.kosdaqButton.layer.cornerRadius = 5
        self.kospi200Button.layer.cornerRadius = 5
        self.predicePriceView.layer.cornerRadius = 5
        self.indexView.layer.cornerRadius = 5
    }
    
    //라벨 뷰 세팅 함수
    func predictViewLabeSetting(type: ChartDataType){
        //예측 값이 얼마나 올랐는지 계산하는 코드 필요
        guard let currentPrice = self.presentStockData_Dummy?.currentPrice else {return}
        guard let change = self.presentStockData_Dummy?.change else {return}
        guard let stockName = self.presentStockData_Dummy?.stockName else {return}
        let changePrice = 1600
        
        if(type == .sentimentalPredict){ // 감성 분석일 경우
            self.presentPriceLabel.text = " "
            self.krwLabel.text = " "
            self.changePriceLabel.text = "  [\(stockName)]의 감성분석 결과가 부정적입니다"
            
        }else{
            //현재 주가 데이터 출력
            self.stockNameLabel.text = self.presentStockData_Dummy?.stockName
            self.stockCodeLabel.text = self.presentStockData_Dummy?.stockCode
            self.presentPriceLabel.text = "\(Int(currentPrice))"
            self.krwLabel.text = "KRW"
            self.changePriceLabel.text = "+\(changePrice)(\(change)%)"
            self.changePriceLabel.textColor = .systemRed
            
            
            if let lastEntry = self.indexDatas?.KOSPI.last,
               let lastValue = lastEntry.values.first {
                print("Last Value:", lastValue)
                
                print(String((Int(lastValue))))
                self.presentPriceLabel2.text = String((Int(lastValue)))
            }
            
            
        }
        self.predictViewTypeLabel.text = type.rawValue
    }
    
    //제스쳐 세팅 함수
    func gestureSetting(){
        //gesture
        let everyDayEconodyViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(everyDayEconomyHandleTap(_:)))
        let hankyungBusinessViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(hankyungBusinessHandleTap(_:)))
        let economistViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(economistHandleTap(_:)))
        
        
        self.everyDayEconomyView.addGestureRecognizer(everyDayEconodyViewTapGesture)
        self.hankyungBusinessView.addGestureRecognizer(hankyungBusinessViewTapGesture)
        self.economistView.addGestureRecognizer(economistViewTapGesture)
    }
    
    
    //chartView 생성
    func configureChartView(isPredict: Bool, color: UIColor, chartDataType: ChartDataType ) -> LineChartView{
        let gradient = fillGradient()
        let data = setDataEntry()
        let lineChartView = setLineChartView()
        lineChartView.delegate = self
        return lineChartView
        
        // 그라디언트 채우기 설정
        func fillGradient()-> CGGradient{
            let gradientColor = color
            let gradientColors = [gradientColor.cgColor, UIColor.black.cgColor] as CFArray
            let colorLocations: [CGFloat] = [1.0, 0.0]
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: gradientColors,
                                            locations: colorLocations) else {
                fatalError("그라디언트 생성 실패했습니다.")
            }
            return gradient
        }
        
        // 데이터 엔트리 생성
        func setDataEntry() -> LineChartData{
            var entries: [ChartDataEntry] = []
            var stockData: [[Date: Double]]? = []
            
            switch chartDataType{
            case .KOSPI:
                stockData = self.indexDatas?.KOSPI
            case .KOSDAQ:
                stockData = self.indexDatas?.KOSDAQ
            case .KOSPI200:
                stockData = self.indexDatas?.KOSPI200
            case .presentPrice:
                stockData = self.presentStockData_Dummy?.Prices
            case .predict5day:
                stockData = self.presentStockData_Dummy?.dayFivePrices
            case .predict10day:
                stockData = self.presentStockData_Dummy?.dayTenPrices
            default:
                stockData = parseCSVFile(datasetName: "5d_predict_SE00")
            }
            
            
            
            //x,y 값 생성
            for entry in stockData! {
                if let date = entry.keys.first, let value = entry.values.first {
                    let xValue = date.timeIntervalSince1970
                    let yValue = value
                    let dataEntry = ChartDataEntry(x: xValue, y: yValue)
                    
                    entries.append(dataEntry)
                }
            }
            
            
            // 데이터셋 생성
            let dataSet = LineChartDataSet(entries: entries, label: "data")
            dataSet.gradientPositions
            dataSet.setColor(color) // 그래프 선 색상 설정
            dataSet.lineWidth = 1.0 // 그래프 선 두께 설정
            dataSet.drawCirclesEnabled = false // 데이터 포인트에 원형 마커 표시 여부 설정
            dataSet.drawValuesEnabled = true //
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true // 채우기 활성화
            dataSet.mode = .cubicBezier
            dataSet.cubicIntensity = 0.2
            
            // 데이터 배열 설정
            let data = LineChartData(dataSet: dataSet)
            return data
        }
        
        //lineChartView 생성
        func setLineChartView()->LineChartView{
            // 차트 뷰 설정
            var lineChartView = LineChartView(frame: self.predicePriceView.bounds)
            lineChartView.translatesAutoresizingMaskIntoConstraints = false //autoLayout 지정 속성_ fals = autuLayout 사용
            lineChartView.contentMode = .scaleToFill
            
            //차트 뷰 데이터 설정
            lineChartView.data = data
            
            //차트 뷰 grid 설정
            lineChartView.xAxis.drawGridLinesEnabled = false
            lineChartView.leftAxis.drawGridLinesEnabled = false
            
            
            //차트 뷰 뷰 설정
            lineChartView.xAxis.labelPosition = .bottom // x축 레이블 위치 설정
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: []) // x축 레이블 포맷터 설정 (일단 빈 값으로 설정)
            lineChartView.rightAxis.enabled = false // 오른쪽 축 비활성화
            lineChartView.leftAxis.enabled = false
            
            lineChartView.legend.enabled = false // 범례 비활성화
            lineChartView.chartDescription.enabled = true // 차트 설명 비활성화
            lineChartView.pinchZoomEnabled = true        // 핀치 줌 기능 비활성화
            lineChartView.scaleXEnabled = true           // X축 스케일 기능 비활성화
            lineChartView.scaleYEnabled = true           // Y축 스케일 기능 비활성화
            lineChartView.doubleTapToZoomEnabled = true
            lineChartView.isUserInteractionEnabled = true
            lineChartView.noDataText = "" //데이터 없을 때 보일 문자열
            lineChartView.xAxis.valueFormatter = DateAxisValueFormatter()
            lineChartView.xAxis.labelCount = 0 // x축 레이블 개수 설정
            lineChartView.xAxis.granularity = 0 // x축 레이블 간격 설정
            lineChartView.xAxis.labelRotationAngle = 0 // x축 레이블 회전 설정
            lineChartView.xAxis.labelTextColor = .white
            
            
            
            
            
            if lineChartView.scaleX >= 2.0 && lineChartView.scaleY >= 2.0 {
                print("==============TRUE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(true) // 그래프에 값 표시 활성화
            } else {
                print("==============FALSE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(false) // 그래프에 값 표시 비활성화
            }
            
            if chartDataType == .predict5day || chartDataType == .predict10day {
                let dateString = "2023/06/07"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let date = dateFormatter.date(from: dateString)
                let doubleValue = date?.timeIntervalSince1970
                
                let limitLine = ChartLimitLine(limit: doubleValue!, label: "") // 특정 x 값에 대한 제한선 생성
                limitLine.lineWidth = 1 // 제한선의 너비 설정
                limitLine.lineColor = .systemRed // 제한선의 색상 설정
                lineChartView.xAxis.addLimitLine(limitLine) // 제한선을 왼쪽 축에 추가
                lineChartView.notifyDataSetChanged()
                lineChartView.setNeedsDisplay()
            }
            
//            //descrpitionLabel
//            descriptionLabel.font = .systemFont(ofSize: 15, weight: .bold)
//            descriptionLabel.textColor = .black
//            contentView.addSubview(descriptionLabel)
//            descriptionLabel.snp.makeConstraints {
//                $0.centerX.equalToSuperview()
//                $0.top.equalToSuperview().offset(10)
//            }
            // 터치 제스처 추가
    //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChartTap(_:)))
    //            lineChartView.addGestureRecognizer(tapGesture)
    //
            return lineChartView
        }
    }
    
    
    
    //MARK: - 버튼 함수
    
    //검색 버튼
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        var searchName = self.searchTextField.text ?? ""
        if searchName == "" {
            self.showAlert(title: "검색할 종목을 입력해주세요")
        }
        else{
            self.searchStockWithAPI(stockName: searchName)
            print("종목 상세화면으로 이동")
            //종목 상세화면으로 이동
//            guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
//            viewController.presentStockData_Dummy = self.searchStockData_Dummy
//            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //종목 상세화면 이동 버튼
    @IBAction func stockDetailButtonTapped(_ sender: Any) {
        
        //종목 상세화면으로 이동
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
        
        viewController.presentStockData_Dummy = self.presentStockData_Dummy
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    //현재 주가 버튼
    @IBAction func presentPriceButtonTapped(_ sender: Any) {
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .presentPrice)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.predictViewLabeSetting(type: .presentPrice)
        
        self.presentPriceButton.backgroundColor = .darkGray
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .black
    }
    
    
    //lstm 예측 버튼
    @IBAction func lstmPriceButtonTapped(_ sender: Any) {
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemYellow, chartDataType: .predict5day)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.predictViewLabeSetting(type: .predict5day)
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .darkGray
        self.sentimentalButton.backgroundColor = .black
    }
    
    //감성분석 예측 버튼
    @IBAction func sentimentalPriceButtonTapped(_ sender: Any) {
        self.predictLineChartView.removeFromSuperview()
        
        //감성 분석 결과에 따른 색 변화 코드 필요
        
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .presentPrice)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.predictViewLabeSetting(type: .sentimentalPredict)
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .darkGray
    }
    
    
    //kospi지수 버튼
    @IBAction func kospiIndexButtonTapped(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSPI)
        self.indexView.addSubview(self.indexLineChartView)

        self.kospiButton.backgroundColor = .darkGray
        self.kosdaqButton.backgroundColor = .black
        self.kospi200Button.backgroundColor = .black
        
    }
    
    //kosdaq지수 버튼
    @IBAction func kosdaqIndexButtonTapped(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSDAQ)
        self.indexView.addSubview(self.indexLineChartView)
        
        self.kospiButton.backgroundColor = .black
        self.kosdaqButton.backgroundColor = .darkGray
        self.kospi200Button.backgroundColor = .black
    }
    //kospi200지수 버튼
    @IBAction func kospi200IndexButtonTapped(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSPI200)
        self.indexView.addSubview(self.indexLineChartView)
        
        self.kospiButton.backgroundColor = .black
        self.kosdaqButton.backgroundColor = .black
        self.kospi200Button.backgroundColor = .darkGray
    }
    
    
    
    
    
    //MARK: - Data 관련 함수
    
    
//    //유저 갖고오기 함수
//    func getUser() -> User{
//        let token = UserDefaults.standard.string(forKey: "access_token")
//        print("access_token = \(token)")
//
//        let user_Any = UserDefaults.standard.value(forKey: token!)
//        guard let user = user_Any as? User else {return User(user_id: "", pw: "", name: "")}
//        print("user = \(user)")
//        return(user)
//    }
    
    
    //토큰 임시 발행 및 유저 저장 함수
    func setUser_dummy(){
        //토큰 저장
        let token = "dummyToken"
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.set(token, forKey: "access_token")

        //토큰으로 유저 저장
        let user = User(user_id: "dummy", pw: "1", name: "이현호더미")
        
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "dummyToken")
        }

        UserManager.shared.setUser(user)
    }
    
    //종목 검색 함수
    func searchStockWithAPI(stockName: String){
        GetStockService.shared.getStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let searchData = data as? Stock else {return}
                self.searchStockData = searchData
                
                //종목 상세화면으로 이동 함수
                guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
                viewController.presentStockData = self.searchStockData
                self.navigationController?.pushViewController(viewController, animated: true)
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in searchStockWithAPI")
            case .serverErr:
                print("serverErr in searchStockWithAPI")
            case .networkFail:
                print("networkFail in searchStockWithAPI")
            default:
                print("networkFail in searchStockWithAPI")
            }
        })
    }
    
    //현재 주가에 대한 데이터 갖고오기 함수
    func getPresentStockWithAPI(stockName: String){
        GetStockService.shared.getStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let presentStockData = data as? Stock else {return}
                self.presentStockData = presentStockData
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in searchStockWithAPI")
            case .serverErr:
                print("serverErr in searchStockWithAPI")
            case .networkFail:
                print("networkFail in searchStockWithAPI")
            default:
                print("networkFail in searchStockWithAPI")
            }
        })
    }
    
    
    //지수 데이터 가져오기 함수
    func getIndexWithAPI(){
        GetIndexService.shared.getIndex(completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let indexURLs = data as? IndexURLs else {return}
                let kospiData = self.downloadCSVFile(indexURL: indexURLs.KOSPI)
                let kosdaqData = self.downloadCSVFile(indexURL: indexURLs.KOSDAQ)
                let kospi200Data = self.downloadCSVFile(indexURL: indexURLs.KOSPI200)
                print(kospiData)
                self.indexDatas = IndexData(KOSPI: kospiData, KOSDAQ: kosdaqData, KOSPI200: kospi200Data)
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in getIndexWithAPI")
            case .serverErr:
                print("serverErr in getIndexWithAPI")
            case .networkFail:
                print("networkFail in getIndexWithAPI")
            default:
                print("networkFail in getIndexWithAPI")
                
            }
        })
    }
    
    //현재 주가 데이터 Dummy 로 가져오기 함수
    func getPresentStock_Dummy(){
        
        var day10 = parseCSVFile(datasetName: "10d_predict_SE00")
        var day5 = parseCSVFile(datasetName: "5d_predict_SE00")
        var day0 = parseCSVFile(datasetName: "Data_SE00")
        

        self.presentStockData_Dummy = Stock_Dummy(stockName: "현대차", stockCode: "005380", currentPrice: 189100, change: 600, changePercentage: 0.69, dayFivePrices: day5, dayTenPrices: day10, Prices: day5, newsUrl: "https://www.hankyung.com/", magazineUrl: "https://www.mk.co.kr/", economistUrl: "https://economist.co.kr/article/search?searchText=%EC%82%BC%EC%84%B1%EC%A0%84%EC%9E%90")
        self.searchStockData_Dummy = Stock_Dummy(stockName: "현대차", stockCode: "005380", currentPrice: 189100, change: 600, changePercentage: 0.69, dayFivePrices: day5, dayTenPrices: day10, Prices: day5, newsUrl: "https://www.hankyung.com/", magazineUrl: "https://www.mk.co.kr/", economistUrl: "https://economist.co.kr/article/search?searchText=%EC%82%BC%EC%84%B1%EC%A0%84%EC%9E%90")
    }
    
    func getIndex_Dummy(){
        let kospiData = parseCSVFile(datasetName: "kospi")
        let kosdaqData = parseCSVFile(datasetName: "kosdaq")
        let kospi200Data = parseCSVFile(datasetName: "sp500")
        self.indexDatas = IndexData(KOSPI: kospiData, KOSDAQ: kosdaqData, KOSPI200: kospi200Data)
    }
    
    
    //MARK: - 기타 함수

    
    @objc func everyDayEconomyHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.magazineUrl else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func hankyungBusinessHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.newsUrl else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func economistHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.economistUrl else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    
    
    //CSV 다운, 파싱 함수
    func downloadCSVFile(indexURL: URL) -> [[Date: Double]] {
        var dictionaryArray: [[Date: Double]] = []

        do {
            let csvData = try Data(contentsOf: indexURL)
            guard let csvString = String(data: csvData, encoding: .utf8) else {return dictionaryArray}

            let lines = csvString.components(separatedBy: "\n")

            let trimmedLines = lines.map { line -> String in
                var trimmedLine = line
                if let commaIndex = line.firstIndex(of: ",") {
                    let startIndex = line.index(after: commaIndex)
                    trimmedLine = String(line[startIndex...])
                }
                return trimmedLine
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"

            for line in trimmedLines[1...] {
                let temp = line.components(separatedBy: ",")
                let fields = temp.map { $0.replacingOccurrences(of: "\r", with: "") }

                if let dateString = fields.first, let valueString = fields.last,
                   let date = dateFormatter.date(from: dateString),
                   let value = Double(valueString) {
                    let dictionary: [Date: Double] = [date: value]
                    dictionaryArray.append(dictionary)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        return dictionaryArray
    }
    
    //CSV 파싱 함수
    func parseCSVFile(datasetName: String) -> [[Date: Double]] {
        var dictionaryArray: [[Date: Double]] = []

        guard let path = Bundle.main.path(forResource: datasetName, ofType: "csv") else {
            return dictionaryArray
        }

        do {
            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: "\n")

            let trimmedLines = lines.map { line -> String in
                var trimmedLine = line
                if let commaIndex = line.firstIndex(of: ",") {
                    let startIndex = line.index(after: commaIndex)
                    trimmedLine = String(line[startIndex...])
                }
                return trimmedLine
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"

            for line in trimmedLines[1...] {
                let temp = line.components(separatedBy: ",")
                let fields = temp.map { $0.replacingOccurrences(of: "\r", with: "") }

                if let dateString = fields.first, let valueString = fields.last,
                   let date = dateFormatter.date(from: dateString),
                   let value = Double(valueString) {
                    let dictionary: [Date: Double] = [date: value]
                    dictionaryArray.append(dictionary)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        return dictionaryArray
    }
    
    //변동률 계산 함수
    func changeRate(today: Double, yesterDay: Double) -> Double{
        return (((today - yesterDay)/yesterDay)*100).rounded() / 10
    }
    //주식 변동율 = ((현재 가격 – 이전 가격) / 이전 가격) x 100
    
    //showAlert
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
    
    
}


extension MainViewContoller: ChartViewDelegate{
    
    
    func chartValueSelected(_ chartView_: ChartViewBase,
                            entry entry: ChartDataEntry,
                            highlight highlight: Highlight) {
        
        
        let dataSetIndex = highlight.dataSetIndex
        print("hilight = \(highlight)")
        print("y value = \(highlight.y)")
        print("dataSetIndex = \(dataSetIndex)")
        let value = chartView_.data?.dataSets[dataSetIndex].entryForIndex(Int(highlight.x))?.y
        
//        self.showAlert(title: "\(highlight.y)원 입니다")
        
        if(highlight.y > 5000){
            self.changePriceLabel.text = "\(highlight.y)"
        }else{
            self.changePriceLabel2.text = "\(highlight.y)"
        }
//        print("Selected Y Value:", value)
        
  
    
        
    }
    
    
}


