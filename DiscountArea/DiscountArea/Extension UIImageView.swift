

import UIKit

extension UIImageView {
    
    func loadImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
        
        //self.image = UIImage(systemName: "photo")?.withTintColor(.gray)
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self, let data = data, error == nil else {
                print("Error fetching image: \(String(describing: error))")
                return
            }
            
            if let downloadedImage = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    self.image = downloadedImage
                    completion?(downloadedImage)
                }
            }
        }
        task.resume()
    }
}
