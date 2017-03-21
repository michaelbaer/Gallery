import UIKit
import Photos

class GridView: UIView {

  // MARK: - Initialization

  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
  lazy var arrowButton: ArrowButton = self.makeArrowButton()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var closeButton: UIButton = self.makeCloseButton()
    lazy var closeBarButton: UIBarButtonItem = self.makeCloseBarButton()
    lazy var navigationItem: UINavigationItem = self.makeNavigationItem()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var emptyView: UIView = self.makeEmptyView()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)

    [collectionView, bottomView, topView, emptyView].forEach {
      addSubview($0)
    }

    switch Config.Grid.TopView.isNavigationBar {
    case true:
        (topView as? UINavigationBar)?.pushItem(navigationItem, animated: false)
        arrowButton.g_pin(height: 40)
    case false:
        [closeButton, arrowButton].forEach {
            topView.addSubview($0)
        }
        closeButton.g_pin(on: .top)
        closeButton.g_pin(on: .left)
        closeButton.g_pin(size: CGSize(width: 40, height: 40))
        
        arrowButton.g_pinCenter()
        arrowButton.g_pin(height: 40)
    }
    
    [bottomBlurView, doneButton].forEach {
      bottomView.addSubview($0 as! UIView)
    }

    topView.g_pinUpward()
    topView.g_pin(height: Config.Grid.TopView.height)
    bottomView.g_pinDownward()
    bottomView.g_pin(height: 80)

    emptyView.g_pinEdges(view: collectionView)
    collectionView.g_pin(on: .left)
    collectionView.g_pin(on: .right)
    collectionView.g_pin(on: .bottom)
    collectionView.g_pin(on: .top, view: topView, on: .bottom, constant: 1)

    bottomBlurView.g_pinEdges()

    doneButton.g_pin(on: .centerY)
    doneButton.g_pin(on: .right, constant: -38)
  }

  // MARK: - Controls

  func makeTopView() -> UIView {
    let view: UIView
    switch Config.Grid.TopView.isNavigationBar {
    case true:
        let bar = UINavigationBar()
        bar.tintColor = Config.Grid.NavigationBar.tintColor
        view = bar
    case false:
        view = UIView()
    }
    view.backgroundColor = Config.Grid.TopView.backgroundColor
    return view
  }

  func makeBottomView() -> UIView {
    let view = UIView()

    return view
  }

  func makeBottomBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    return view
  }

  func makeArrowButton() -> ArrowButton {
    let button = ArrowButton()
    button.layoutSubviews()

    return button
  }

  func makeGridView() -> GridView {
    let view = GridView()

    return view
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(Bundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }
    
    func makeNavigationItem() -> UINavigationItem {
        let navItem = UINavigationItem(title: "")
        navItem.leftBarButtonItem = closeBarButton
        navItem.titleView = arrowButton
        return navItem
    }
    
    func makeCloseBarButton() -> UIBarButtonItem {
        if let title = Config.Grid.NavigationBar.CloseBarButton.title {
            return UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        }
        
    }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("Gallery.Done".g_localize(fallback: "Done"), for: UIControlState())
    
    return button
  }

  func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.white

    return view
  }

  func makeEmptyView() -> EmptyView {
    let view = EmptyView()
    view.isHidden = true

    return view
  }
}
