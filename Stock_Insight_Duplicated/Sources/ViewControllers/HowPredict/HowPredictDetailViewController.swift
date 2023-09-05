//
import UIKit
import MarkdownKit

class HowPredictDetailViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    var markdown = """
        

        
        """
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.backgroundColor = .black
        self.displayMarkdownDocument(markdown: self.markdown, in: self.textView)
    }
    
    //viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "분석 방법"
    }
    
    //MarkDown parser 함수
    func renderMarkdownDocument(markdown: String) -> NSAttributedString? {
        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 17))
        return markdownParser.parse(markdown)
    }
    
    //markDown 값을 출력
    func displayMarkdownDocument(markdown: String, in textView: UITextView) {
        if let attributedString = renderMarkdownDocument(markdown: markdown) {
            textView.attributedText = attributedString
            textView.textColor = .white
        } else {
            textView.text = "Failed to load markdown document."
        }
    }
}
