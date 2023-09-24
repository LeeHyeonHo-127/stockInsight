import UIKit

class HowPredictViewController: UIViewController {
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    //MARK: - 버튼 함수
    
    //lstm 상세화면으로 이동
    @IBAction func LSTMDetailButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HowPredictDetailViewController") as? HowPredictDetailViewController else {return}
        self.navigationController?.navigationBar.isHidden = false
        viewController.markdown =
        """
        # 분석 방법(LSTM)

        ## 예측 데이터 분석 방법 - LSTM 모델 사용

        ### <LSTM이란?>

        - 순환신경망(RNN)은 내부적으로 순환되는 구조를 이용해 이전의 데이터를 기억하여 다음 데이터에 활용하는 방법입니다. 앞뒤 문맥을 가지고 있는 데이터의 처리나 시계열 데이터와 같은 순차적인 데이터를 처리하는 데에 효과적입니다. 그러나 시간이 지날수록 데이터가 계속해서 입력 되어오면서 오래전의 데이터의 기억은 점점 사라지게 된다는 한계가 있습니다.

        - 시계열 데이터를 분석할 때 순환신경망(RNN)의 이러한 장기 의존성을 처리하지 못한다는 단점을 보완해주는 신경망 기법으로 LSTM을 사용합니다. LSTM도 순환신경망 기법중 하나이지만, 게이트 개념을 사용하여 특정데이터를 선별하고, 선별한 기억을 확보해주는 능력을 가지고 있습니다.

        - LSTM은 게이트의 열린 정도를 가중치로 조절하며, 이러한 가중치는 모델 학습을 통해 알아낼 수 있습니다.

        ### <LSTM 사용방법>

        tensorflow의 keras model 라이브러리를 사용하여 LSTM 모델을 불러온 뒤 사용하였습니다.

        - tensorflow: tensorflow는 google이 개발한 머신러닝, 딥러닝을 위한 오픈소스 라이브러리 입니다. tensorflow를 사용하면 딥러닝 모델을 구축하고 훈련시키는 데 필요한 다양한 기능을 제공받을 수 있습니다.

        - keras model 라이브러리: keras는 딥러닝 모델을 구축하고 훈련하기 위한 딥러닝 추상화 라라이브러리로 사용하기 쉬운 API를 제공하여 딥러닝 모델을 구축하고 훈련하기 쉽게 만들어줍니다. 이를 위해 다양한 레이어, 활성화 함수, 최적화 알고리즘, 손실 함수 등을 제공합니다.
        *tensorflow2.0 부터 keras가 tensorflow 메인 코드베이스에 병합되었습니다. 따라서 tensorflow와 keras 라이브러리를 혼용하여 코드를 작성할 수 있게 되었습니다.

        ### <정확도를 높이기 위해..>

        - 종가값 뿐만 아니라 주가에 영향을 주는 변수들을 찾아보고 입력데이터로 사용하였습니다.
        -yfinance 라이브러리에서 원달러환율 데이터를 가져와 가공하여 사용
        -한국은행에서 일별 금리데이터를 가져와 가공하여 사용
        -그 외 주가예측에 사용되는 중요한 지표들(PER, PBR 등)을 추출하여 계산하고 적용함

        - 정규화 기법을 사용하여 모델의 능력을 향상시켰습니다.
        -변동성이 큰 주가 데이터를 정규화시켜 데이터의 분포를 조절함으로서 일반화 능력을 향상시키고, 특정한 데이터셋에 과적합 되는 것을 방지하였습니다.

        """
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //감성분석 상세화면으로 이동
    @IBAction func sentimentAnalysisDetailButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HowPredictDetailViewController") as? HowPredictDetailViewController else {return}
        self.navigationController?.navigationBar.isHidden = false
        viewController.markdown =
        """
        ## BERT란?

        - BERT는 "Bidirectional Encoder Representations from Transformers"의 약어로, 구글에서 개발한 자연어 처리 모델이다. BERT는 Transformer라는 딥러닝 아키텍처를 기반으로 하며, **사전 훈련된 언어 모델**로 대표되는 모델 중 하나 이다.

        - 여기서 BERT 의 Bidirectional 은 **양방향(bidirectional) 학습**을 수행한다는 것을 의미하며 이는 문장을 왼쪽에서 오른쪽으로 읽는 것뿐만 아니라, 오른쪽에서 왼쪽으로 읽는 방식도 사용하여 문맥을 이해하는 데 도움을 준다. 이를 위해 BERT는 Transformer 모델의 여러 레이어를 쌓아 구성되어 있다.

        - BERT 모델은 크게 두 가지 단계로 구성된다. 첫 번째는 **사전 훈련(pre-training)** 단계로, 대규모의 텍스트 데이터를 사용하여 언어 모델을 사전 훈련한다. 이 단계에서는 문장에서 단어나 문맥의 패턴을 파악하고 임베딩 벡터로 표현하는 방법을 학습한다.

        - 두 번째는 **미세 조정(fine-tuning)** 단계로, 특정 자연어 처리 작업을 위해 사전 훈련된 BERT 모델을 사용하여 추가적인 훈련을 수행한다. 이 단계에서는 작업에 맞는 출력 레이어를 추가하고, 해당 작업에 대한 데이터셋을 사용하여 모델을 세밀하게 조정한다. **(이 프로젝트에선 수행하지 않음)**

        - BERT는 사전 훈련 단계에서 다양한 언어 모델과 텍스트 데이터를 사용하여 훈련될 수 있으며, 미세 조정 단계에서는 특정 언어나 작업에 대해 추가로 훈련될 수 있다. 이러한 특성은 BERT를 다양한 언어와 작업에 적용할 수 있도록 만들어주고, 많은 자연어 처리 과제에서 좋은 성능을 보여줄 수 있게 한다.

        ### 어떤 방식으로 수행하였는가?

        - 개요
            - 주식의 가격에는 다양한 요소들이 영향을 미치지만 그 중 뉴스에 민감하다고 판단하여 뉴스 기사의 제목을 분석하여 긍정/부정 평가를 한다.
        1. 데이터 수집
            - 최근 1일, 정확도 순서로 검색어 입력 시 그에 대한 뉴스 제목 정보를 크롤링한다.
        2. 전처리
            - konlpy의 Hannanum으로 제목에 대해서 형태소 분석을 하고 tokenize를 진행한다.
        3. 모델링
            - pre-train 된 한국식 bert 모델인 koBart 모델을 사용하여 sentiment(감성) 점수를 부여한다.
            - 제목을 수치화한 'sentiment' 값을 얻어내고 0.5 기준으로 이상이면 긍정, 미만이면 부정으로 'label' 이라고 labeling을 수행
        4. 결과
            - 두 가지 방식으로 긍/부정을 결론 짓는다.
                - 모든 뉴스의 감성 점수에 대한 평균을 기준으로 0.5 미만이면 부정/ 0.5 이상이면 긍정
                - 각각의 뉴스에 대해 미리 긍/부정을 나눈 'label'의 개수에 대해 긍정 뉴스가 많으면 긍정, 부정 뉴스가 많으면 부정으로 결론짓는다.
        """
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}


