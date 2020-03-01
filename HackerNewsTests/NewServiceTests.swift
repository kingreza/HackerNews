//
//  HackerNewsTests.swift
//  HackerNewsTests
//
//  Created by Reza Shirazian on 4/16/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import XCTest
import Workflow
import WorkflowUI
import WorkflowTesting

@testable import HackerNews

class NewServiceTests: XCTestCase {
  
  static var mockNetworkService: NetworkProvider!
  static var mockNewsService: NewsProvider!
  
  override class func setUp() {
    mockNetworkService = MockNetworkService()
    mockNewsService = NewsService(networkProvider: mockNetworkService)
  }
  
  // News Service Tests
  
  func test_getNewsList_test() throws {
    NewServiceTests.mockNewsService.getNewsList { result in
      switch result {
      case .success(let newsList):
        XCTAssertEqual(newsList.count, 356)
        XCTAssertEqual(newsList, [22893323, 22889778, 22894608, 22892401, 22892015, 22894785, 22892633, 22889195, 22891497, 22894407, 22890016, 22890801, 22891591, 22892494, 22891770, 22890604, 22892030, 22894117, 22889496, 22890724, 22890595, 22892946, 22888318, 22892035, 22893035, 22888488, 22890808, 22890695, 22889634, 22888239, 22893265, 22887346, 22888943, 22894038, 22876408, 22890191, 22875090, 22878515, 22888604, 22892267, 22891857, 22888734, 22888170, 22876961, 22892441, 22894004, 22878136, 22889242, 22883429, 22891986, 22892205, 22885864, 22893520, 22887349, 22892639, 22894434, 22880898, 22894012, 22893121, 22885819, 22882260, 22892434, 22886988, 22892310, 22891799, 22884061, 22875094, 22892190, 22888807, 22884510, 22892548, 22889495, 22878400, 22890081, 22881808, 22893905, 22890272, 22892711, 22887226, 22879771, 22886889, 22881130, 22886647, 22891439, 22886187, 22893419, 22884586, 22888157, 22871331, 22892159, 22875106, 22891510, 22873298, 22885527, 22871124, 22892397, 22876554, 22885346, 22890955, 22884998, 22869909, 22871417, 22883280, 22884299, 22893083, 22888914, 22884375, 22879448, 22875465, 22870105, 22884993, 22876440, 22872711, 22871180, 22892284, 22892469, 22879347, 22892132, 22879678, 22882148, 22880335, 22888640, 22878399, 22870667, 22886621, 22879361, 22874701, 22887903, 22876755, 22880931, 22872301, 22891555, 22870180, 22891843, 22877355, 22871158, 22878146, 22879651, 22888961, 22870905, 22876241, 22881384, 22876108, 22885117, 22892349, 22884898, 22869787, 22870273, 22885621, 22888665, 22886559, 22883240, 22883242, 22879185, 22879425, 22883550, 22873578, 22880320, 22885892, 22876187, 22884652, 22882590, 22874621, 22892135, 22884736, 22888379, 22878197, 22887008, 22882482, 22884831, 22870912, 22892513, 22877104, 22886064, 22890612, 22888912, 22885689, 22883595, 22874863, 22877890, 22877126, 22879567, 22881574, 22875166, 22889135, 22875937, 22883502, 22882655, 22883114, 22873722, 22889313, 22886177, 22878331, 22889182, 22874176, 22882133, 22875347, 22873169, 22884841, 22889341, 22883071, 22887175, 22871502, 22886932, 22879376, 22877711, 22881364, 22878636, 22878611, 22885862, 22877228, 22877788, 22883824, 22885433, 22879262, 22881879, 22881786, 22881726, 22885283, 22886000, 22887117, 22874717, 22884833, 22874631, 22886823, 22888453, 22876351, 22874476, 22878024, 22872543, 22879463, 22875048, 22881104, 22874662, 22873431, 22880686, 22882688, 22873403, 22875234, 22889491, 22875170, 22888705, 22873808, 22884072, 22876273, 22883838, 22886854, 22881483, 22883546, 22871261, 22880870, 22880762, 22888646, 22871566, 22882767, 22872420, 22885123, 22882421, 22876422, 22873187, 22889602, 22891507, 22874675, 22883270, 22881150, 22872491, 22880501, 22880496, 22883503, 22879703, 22877320, 22879275, 22878186, 22870073, 22874259, 22886164, 22872608, 22882769, 22884738, 22881687, 22880989, 22884419, 22870990, 22876096, 22875701, 22886108, 22874346, 22882936, 22877961, 22873368, 22875064, 22873687, 22879334, 22873236, 22872955, 22881051, 22872743, 22871382, 22885329, 22872103, 22872392, 22881768, 22877629, 22869667, 22870719, 22884869, 22878823, 22872494, 22881460, 22875167, 22875264, 22883582, 22880305, 22870270, 22870030, 22882634, 22883477, 22873852, 22885972, 22882460, 22877561, 22881508, 22877174, 22874099, 22871488, 22875163, 22876485, 22882348, 22870754, 22869805, 22870225, 22874894, 22870388, 22876581, 22876556, 22882328, 22871421, 22873042, 22872473, 22875345, 22871003, 22870722, 22870618, 22869639, 22875708, 22870969, 22874243, 22871065, 22891435, 22874266, 22872626, 22870726, 22878506, 22876558, 22878524, 22870975])
      case .failure(_):
        XCTFail("getting news list should not fail")
      }
    }
  }
  
  func test_getNews() {
    NewServiceTests.mockNewsService.getNews(id: 22889778) { result in
      switch result {
      case .success(let news):
        XCTAssertEqual(news, News(
          id: 22889778,
          title: "Stripe raises $600M at nearly $36B valuation",
          by: "hhs",
          urlString: "https://www.axios.com/stripe-fundraising-600-million-1f1f38b6-fde6-4316-b111-2f3b0e868ab7.html",
          score: 559,
          timeIntervalSince1970: 1587047742,
          descendants: 327,
          kids: [22890523, 22893204, 22890386, 22889999, 22890410, 22894692, 22892547, 22892718, 22891785, 22889908, 22890015, 22891151, 22894036, 22889926, 22890397, 22890201, 22890675, 22892834, 22891012, 22893934, 22890349, 22890964, 22891549, 22892167, 22891996, 22892584, 22891042, 22889964, 22890327, 22890293, 22892313, 22890125, 22890230, 22890328, 22889880, 22891050, 22891315, 22891065, 22890222, 22891199, 22891889, 22890190, 22890309]
          )
        )
      case .failure(_):
        XCTFail("getting news should not fail")
      }
    }
  }
  
  func test_getComment() {
    NewServiceTests.mockNewsService.getComment(id: 22890523) { result in
      switch result {
        
      case .success(let comment):
        XCTAssertEqual(comment, Comment(
          id: 22890523,
          by: "pc",
          parent: 22889778,
          kids: [22891191, 22892038, 22892061, 22894687, 22890979, 22890684, 22894551, 22893523, 22891593, 22892981, 22893425, 22893665, 22891797, 22893502, 22893808, 22893570, 22892999, 22891711, 22892643, 22890634, 22892025, 22890622, 22890672, 22891405, 22891409, 22891638, 22890831, 22892871, 22891279, 22894106, 22891995],
          text: "Stripe cofounder here. This isn&#x27;t really new -- it&#x27;s an extension of our last round (<a href=\"https:&#x2F;&#x2F;www.cnbc.com&#x2F;2019&#x2F;09&#x2F;19&#x2F;fintech-start-up-stripe-notches-35-billion-valuation-in-funding-round.html\" rel=\"nofollow\">https:&#x2F;&#x2F;www.cnbc.com&#x2F;2019&#x2F;09&#x2F;19&#x2F;fintech-start-up-stripe-notc...</a>).<p>That said, we&#x27;ve seen a big spike in signups over the past few weeks. If any HN readers have integrated recently and have feedback, we&#x27;re always eager to hear it. Feel free to email me at patrick@stripe.com and I&#x27;ll route to the right team(s).<p>As always, thank you to the many HNers who are also active Stripe users!",
          timeIntervalSince1970: 1587051681
          )
        )
      case .failure(_):
        XCTFail("getting comment should not fail")
      }
    }
  }
  
  func test_getComments() {
    NewServiceTests.mockNewsService.getComments(ids: [22890523, 22893204, 22890386]) { result in
      switch result {
      case .success(let comments):
        XCTAssertEqual(comments.count, 3)
        XCTAssertEqual(comments, [
          Comment(
            id: 22890523,
            by: "pc",
            parent: 22889778,
            kids: [22891191, 22892038, 22892061, 22894687, 22890979, 22890684, 22894551, 22893523, 22891593, 22892981, 22893425, 22893665, 22891797, 22893502, 22893808, 22893570, 22892999, 22891711, 22892643, 22890634, 22892025, 22890622, 22890672, 22891405, 22891409, 22891638, 22890831, 22892871, 22891279, 22894106, 22891995],
            text: "Stripe cofounder here. This isn&#x27;t really new -- it&#x27;s an extension of our last round (<a href=\"https:&#x2F;&#x2F;www.cnbc.com&#x2F;2019&#x2F;09&#x2F;19&#x2F;fintech-start-up-stripe-notches-35-billion-valuation-in-funding-round.html\" rel=\"nofollow\">https:&#x2F;&#x2F;www.cnbc.com&#x2F;2019&#x2F;09&#x2F;19&#x2F;fintech-start-up-stripe-notc...</a>).<p>That said, we&#x27;ve seen a big spike in signups over the past few weeks. If any HN readers have integrated recently and have feedback, we&#x27;re always eager to hear it. Feel free to email me at patrick@stripe.com and I&#x27;ll route to the right team(s).<p>As always, thank you to the many HNers who are also active Stripe users!",
            timeIntervalSince1970: 1587051681
          ), Comment(
            id: 22893204,
            by: "pianoben",
            parent: 22889778,
            kids: [22894432, 22893880],
            text: "Jeez, just go public already!  You&#x27;ve had employees waiting for nigh on a decade to realize the value of what they&#x27;ve built, but instead it appears that those gains are just going to VCs (and whoever is privileged enough to take money off the table during these raises).<p>Perhaps I&#x27;m being too cynical, and perhaps Stripe is taking a more enlightened view than I&#x27;m giving it credit for, but my goodness this trend of large businesses just raising money forever (and long after they cease being startups) is frustrating.  At least at Google I know I can actually spend all of my paycheck at some point in the decade after I&#x27;ve earned it.",
            timeIntervalSince1970: 1587068974
          ), Comment(
            id: 22890386,
            by: "fbelzile",
            parent: 22889778,
            kids: [22890465, 22890527, 22890745, 22890493, 22893596, 22890701, 22890423, 22892139, 22890600],
            text: "I&#x27;m very happy with Stripe and for their success, but I plan on switching all my payments to go through PayPal again. I did some math and PayPal offers a better deal for Canadian businesses after Stripe bumps me off of their grandfathered conversion fees in a couple months.<p>I love the slick interface, but it&#x27;s simply not worth the thousands per year I&#x27;ll be saving with the switch.<p>For me the main selling point for any payment processor is the minimization of fees. Sure, the API&#x27;s are nice, but I already use a payment gateway for that.<p>I&#x27;m a few clicks away from saving thousands. Am I missing anything?",
            timeIntervalSince1970: 1587050904
          )
          ]
        )
      case .failure(_):
        XCTFail("getting comment should not fail")
      }
    }
  }
}


