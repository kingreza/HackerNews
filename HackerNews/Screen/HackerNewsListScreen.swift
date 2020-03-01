//  
//  HackerNewsListScreen.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/7/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls
import Listable
import Workflow
import WorkflowUI

struct HackerNewsListScreen: Screen {

  var list: Element?
  
  func viewControllerDescription(environment: ViewEnvironment) -> ViewControllerDescription {
    return HackerNewsListViewController.description(for: self, environment: environment)
  }
}


final class HackerNewsListViewController: ScreenViewController<HackerNewsListScreen> {
  
  private var blueprintView: BlueprintView?
  
  required init(screen: HackerNewsListScreen, environment: ViewEnvironment) {
    super.init(screen: screen, environment: environment)
    update(with: screen, environment: environment)
  }
  
  override func viewDidLoad() {
    self.view = self.blueprintView
  }
  
  override func screenDidChange(from previousScreen: HackerNewsListScreen, previousEnvironment: ViewEnvironment) {
    update(with: screen, environment: environment)
  }

  private func generateBlueprintView(with screen: HackerNewsListScreen) -> BlueprintView {
    return BlueprintView(element: screen.list)
  }
  
  private func update(with screen: HackerNewsListScreen, environment: ViewEnvironment) {
    if let blueprintView = self.blueprintView {
      blueprintView.element = screen.list
    } else {
      self.blueprintView = generateBlueprintView(with: screen)
    }
  }
}
