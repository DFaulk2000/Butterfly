//import XCTest
//@testable import Butterfly
//
//import Foundation
//import Photos
//import SwiftUI
//import CoreData
//
//
//class MockPHAssetCollectionWrapper: PHAssetCollectionWrapper {
//  convenience init() {
//    
//  }
//}
//
//class MockManagedObjectContext: NSManagedObjectContext {
//  convenience init() {
//    
//  }
//}
//
//class MockFetchResult: NSObject {
//  
//}
//
//class MockFetchedResults: FetchedResults<MockFetchResult> {
//  
//}
//
//class ButterflyEffectTests: XCTestCase {
//  let dateFormatter = DateFormatter()
//  let currentYear = Calendar.current.component(.year, from: Date())
//  
//  override func setUpWithError() throws {
//    dateFormatter.locale = Locale(identifier: "en_GB")
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//  }
//
//  override func tearDownWithError() throws {}
//
//  func testSanityGetYearsRange() throws {
//    let mockCollectionWrapper = MockPHAssetCollectionWrapper()
//    let mockObjectContext = MockManagedObjectContext()
//    
//    let butterflyEffect = TheButterFlyEffect(
//      collectionWrapper: mockCollectionWrapper,
//      butterflyAssets: FetchedResults<ButterflyAsset>,
//      managedObjectContext: mockObjectContext
//    )
//
//    // Will default to 1901 for the earliest year
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: true), Array(1901...currentYear - 2))
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: false), Array(1960...currentYear))
//  }
//}
