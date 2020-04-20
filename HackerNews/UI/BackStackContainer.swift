/*
 * Copyright 2019 Square Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import WorkflowUI

public final class BackStackContainer: ScreenViewController<BackStackScreen>, UINavigationControllerDelegate {
  private let navController: UINavigationController
  
  public required init(screen: BackStackScreen, environment: ViewEnvironment) {
    self.navController = UINavigationController()
    
    super.init(screen: screen, environment: environment)
    
    update(with: screen)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    navController.delegate = self
    addChild(navController)
    view.addSubview(navController.view)
    navController.didMove(toParent: self)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    navController.view.frame = view.bounds
  }
  
  public override func screenDidChange(from previousScreen: BackStackScreen, previousEnvironment: ViewEnvironment) {
    update(with: screen)
  }
  
  // MARK: - UINavigationControllerDelegate
  
  public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    setNavigationBarVisibility(with: screen, animated: animated)
  }
  
  // MARK: - Private Methods
  
  private func update(with screen: BackStackScreen) {
    var existingViewControllers: [ScreenWrapperViewController] = self.navController.viewControllers as! [ScreenWrapperViewController]
    var updatedViewControllers: [ScreenWrapperViewController] = []
    
    for item in screen.items {
      if let idx = existingViewControllers.firstIndex(where: { viewController -> Bool in
        viewController.matches(item: item)
      }) {
        let existingViewController = existingViewControllers.remove(at: idx)
        existingViewController.update(item: item, environment: environment)
        updatedViewControllers.append(existingViewController)
      } else {
        updatedViewControllers.append(ScreenWrapperViewController(item: item, environment: environment))
      }
      
    }
    
    navController.setViewControllers(updatedViewControllers, animated: true)
  }
  
  private func setNavigationBarVisibility(with screen: BackStackScreen, animated: Bool) {
    guard let topScreen = screen.items.last else {
      return
    }
    
    let hidden: Bool
    
    switch topScreen.barVisibility {
    case .hidden:
      hidden = true
      
    case .visible:
      hidden = false
    }
    navController.setNavigationBarHidden(hidden, animated: animated)
    navController.navigationBar.barTintColor = UIColor(red:1.00, green:0.40, blue:0.00, alpha:1.00)
    navController.navigationBar.isTranslucent = false
    navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Verdana-Bold", size: 18)!]
  }
}
