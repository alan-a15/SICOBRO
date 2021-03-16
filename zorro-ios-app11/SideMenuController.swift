//
//  SideMenuController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 22/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class SideMenuController : UIViewController {
    
    enum SideMenuState {
        case collapsed
        case leftPanelExpanded
    }
    
    enum SiderMenuType : String {
        case BANNERS_VIEW = "BannerViewController"
        case SICOBRO_VIEW = "SiCobroViewController"
        case COMUNIDAD_RED_VIEW = "ComunidadRedViewController"
    }
    
    var centerViewController: CenterMenuViewController!
    var leftMenuViewController: LeftMenuViewController?
    let centerPanelExpandedOffset: CGFloat = 90
    var siderViewType : SiderMenuType = .BANNERS_VIEW

    
    var currentState: SideMenuState = .collapsed {
      didSet {
        let shouldShowShadow = currentState != .collapsed
        showShadowForCenterViewController(shouldShowShadow)
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.centerViewController(type: siderViewType)
        centerViewController.delegate = self
        view.addSubview(centerViewController.view)
        addChild(centerViewController)
        centerViewController.didMove(toParent: self)
    }
    
    convenience init(type : SiderMenuType) {
        self.init()
        self.siderViewType = type
    }
}

private extension UIStoryboard {
  static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> LeftMenuViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? LeftMenuViewController
  }

    static func centerViewController(type : SideMenuController.SiderMenuType) -> CenterMenuViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: type.rawValue) as? CenterMenuViewController
  }
}

extension SideMenuController: CenterMenuViewControllerDelegate {
  func toggleLeftPanel() {
    print("On toggleLeftPanel")
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)

    print("notAlreadyExpanded: \(notAlreadyExpanded)")
    if notAlreadyExpanded {
      addLeftPanelViewController()
    }

    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
    
    func addLeftPanelViewController() {
      print("On addLeftPanelViewController")
      guard leftMenuViewController == nil else { return }

      if let vc = UIStoryboard.leftViewController() {
        if let menuHandler = centerViewController.menuHandler {
            vc.menuType = menuHandler.getMenuType()
        }
        vc.centerController = centerViewController
        addChildSidePanelController(vc)
        leftMenuViewController = vc
      }
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
      if shouldExpand {
        currentState = .leftPanelExpanded
        animateCenterPanelXPosition(
          targetPosition: centerViewController.view.frame.width - centerPanelExpandedOffset)
      } else {
        animateCenterPanelXPosition(targetPosition: 0) { _ in
            self.currentState = .collapsed
          self.leftMenuViewController?.view.removeFromSuperview()
          self.leftMenuViewController = nil
        }
      }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
      UIView.animate(withDuration: 0.5,
                     delay: 0,
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 0,
                     options: .curveEaseInOut, animations: {
                       self.centerViewController.view.frame.origin.x = targetPosition
      }, completion: completion)
    }
    
    func addChildSidePanelController(_ sidePanelController: LeftMenuViewController) {
      print("On addChildSidePanelController")
      sidePanelController.delegate = centerViewController
      view.insertSubview(sidePanelController.view, at: 0)
      addChild(sidePanelController)
      sidePanelController.didMove(toParent: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
      if shouldShowShadow {
        centerViewController.view.layer.shadowOpacity = 0.8
      } else {
        centerViewController.view.layer.shadowOpacity = 0.0
      }
    }

  func collapseSidePanels() {
    switch currentState {
        case .leftPanelExpanded:
          toggleLeftPanel()
        default:
          break
    }
  }
}
