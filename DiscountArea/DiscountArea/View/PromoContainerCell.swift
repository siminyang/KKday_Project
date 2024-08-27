

import UIKit

struct testProduct {
    let imgUrl: String
    let discount: Int
    let name: String
    let ratingStar: Double
    let ratingCount: Int
    let originalPrice: String
    let price: String
}

class PromoContainerCell: UITableViewCell {

    var collectionView: UICollectionView!
    var configDetail: Detail?
    
    var tabs: [String] = []
    var products: [testProduct] = []
    var selectedTabIndex = 0
    
    private var layout: PromoLayoutType = .grid
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
        setupTestProductsData()
    }
    
    func setupTestProductsData() {
        let product = testProduct(
            imgUrl: "photo",
            discount: 50,
            name: "【花蓮豐濱景點】磯崎大石鼻山步道 整修重新開放！",
            ratingStar: 4.6,
            ratingCount: 20,
            originalPrice: "1000",
            price: "999"
        )
        
        // Create 8 identical products
        products = Array(repeating: product, count: 8)
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
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        
//        self.tabs = configDetail?.tabs ?? []
//        self.products = configDetail?.products ?? []
        
        collectionView.reloadData()
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
            if section == 0 {
                return configDetail?.tabs?.count ?? 0
            } else {
                return configDetail?.tabs?[0].products.count ?? 0
            }
        } else {
            return min(configDetail?.products?.count ?? 0, 8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if layout == .tabGrid || layout == .tabRow {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! PromoTabCell
                cell.configure(with: tabs[indexPath.item], isSelected: indexPath.item == selectedTabIndex)
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
                cell.configure(with: products[indexPath.item])
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
            cell.configure(with: products[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PromoContainerCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if layout == .tabGrid || layout == .tabRow {
            if indexPath.section == 0 {
                cell.alpha = 0
                
                UIView.animate(withDuration: 0.5, delay: 0.05, options: .curveEaseInOut, animations: {
                    cell.alpha = 1
                })
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Handle selection
    }
}

