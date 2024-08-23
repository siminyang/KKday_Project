

import UIKit

class ViewController: UIViewController {
    
    var httpRequestManager = HTTPRequestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        httpRequestManager.fetchPageData()
        httpRequestManager.fetchProductData(productList: ["2247",
                                                          "38965",
                                                          "138901"])
    }
    
}

