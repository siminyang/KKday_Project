

import UIKit


protocol PromoContainerCellDelegate: AnyObject {
    func shouldDeleteTableViewCell(_ cell: PromoContainerCell)
}

class PromoContainerCell: UITableViewCell {

    var collectionView: UICollectionView!
    
    var configDetail: Detail?
    
    var httpRequestManager = HTTPRequestManager()
    
    var tabProducts: [(tabName: String, productIds: [String])] = []
    
    var productsId: [String] = []
    
    var products: [ProductData] = []
    
    var selectedTabIndex = 0
    
    private var layout: PromoLayoutType = .grid
    
    weak var delegate: PromoContainerCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
        httpRequestManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PromoTabCell.self, forCellWithReuseIdentifier: "TabCell")
        collectionView.register(PromoProductCell.self, forCellWithReuseIdentifier: "ProductCell")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()
        let height = collectionView.contentSize.height
        return CGSize(width: targetSize.width, height: height)
    }
    
    func configure(with detail: Detail) {
        self.configDetail = detail
        
        let factory = CollectionViewFactory()
        guard let layoutType = configDetail?.layout else { return }
        
        switch layoutType {
        case "GRID":
            layout = .grid
        case "ROW":
            layout = .row
        case "TAB_GRID":
            layout = .tabGrid
        case "TAB_ROW":
            layout = .tabRow
        default:
            print("不支援的 layoutType")
            return
        }
        
        collectionView.collectionViewLayout = factory.createLayout(for: layout)
        
        if let configDetail = configDetail {
            if layout == .tabGrid || layout == .tabRow {
                
                tabProducts = []
                
                for tab in configDetail.tabs! {
                    let productIds = tab.products.map { $0.productUrlId }
                    tabProducts.append((tabName: tab.name, productIds: productIds))
                }
                
                httpRequestManager.fetchProductData(productList: tabProducts[selectedTabIndex].productIds)
                
                setupLeftGradientView()
                setupRightGradientView()
                
            } else {
                self.productsId = configDetail.products?.map{ $0.productUrlId } ?? []
                
                httpRequestManager.fetchProductData(productList: productsId)

            }
        }
        
        collectionView.reloadData()
        
    }

    func checkIfShouldDelete() {
        if products.isEmpty {
            delegate?.shouldDeleteTableViewCell(self)
        }
    }
}

// MARK: - HTTPRequestManagerDelegate
extension PromoContainerCell: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        self.products = []
        self.products = Array(productData.data.prefix(8))
        
        collectionView.reloadData()
        self.invalidateIntrinsicContentSize()
        checkIfShouldDelete()

    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }
}

// MARK: - UICollectionViewDataSource
extension PromoContainerCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if layout == .tabGrid || layout == .tabRow {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if layout == .tabGrid || layout == .tabRow {
            return section == 0 ? tabProducts.count : min(products.count, 8)
        } else {
            return min(products.count, 8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if layout == .tabGrid || layout == .tabRow {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! PromoTabCell
                cell.configure(with: tabProducts[indexPath.item].tabName, isSelected: indexPath.item == selectedTabIndex)
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
                if indexPath.item < products.count {
                    cell.configure(with: products[indexPath.item])
                }
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
            if indexPath.item < products.count {
                cell.configure(with: products[indexPath.item])
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PromoContainerCell: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if layout == .tabGrid || layout == .tabRow {
//            if indexPath.section == 0 {
//                cell.alpha = 0
//                
//                UIView.animate(withDuration: 0.5, delay: 0.05, options: .curveEaseInOut, animations: {
//                    cell.alpha = 1
//                })
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if layout == .tabGrid || layout == .tabRow {
            if indexPath.section == 0 {
                selectedTabIndex = indexPath.item
                
                httpRequestManager.fetchProductData(productList: tabProducts[indexPath.item].productIds)
                
            } else {
                // 跳出打開safari導到網頁
                let productId = tabProducts[selectedTabIndex].productIds[indexPath.item]
                print(">>>> \(productId)")
                let openUrl = "https://www.kkday.com/zh-tw/product/\(productId)"
                open(urlString: openUrl)
            }
            
        } else {
            // 跳出打開safari導到網頁
            let productId = products[indexPath.item].id
            let openUrl = "https://www.kkday.com/zh-tw/product/\(productId)"
            open(urlString: openUrl)
        }
    }
}

extension PromoContainerCell {
    func setupLeftGradientView() {
        let view = UIView()
        let layer0 = CAGradientLayer()
        
        layer0.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor, UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor]
        layer0.locations = [0.35, 1.0]
        layer0.startPoint = CGPoint(x: 0, y: 0.5)
        layer0.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer0.frame = view.bounds
        view.layer.insertSublayer(layer0, at: 0)
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.widthAnchor.constraint(equalToConstant: 50),
            view.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        contentView.bringSubviewToFront(view)
        view.layoutIfNeeded()
        layer0.frame = view.bounds
    }
    
    func setupRightGradientView() {
        let view = UIView()
        let layer0 = CAGradientLayer()
          
        layer0.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor, UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor]
        layer0.locations = [0.35, 1.0]
        layer0.startPoint = CGPoint(x: 1, y: 0.5)
        layer0.endPoint = CGPoint(x: 0, y: 0.5)
        
        layer0.frame = view.bounds
        view.layer.insertSublayer(layer0, at: 0)
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.widthAnchor.constraint(equalToConstant: 50),
            view.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        contentView.bringSubviewToFront(view)
        view.layoutIfNeeded()
        layer0.frame = view.bounds
    }
}
