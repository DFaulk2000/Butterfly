//import XCTest
//@testable import Butterfly
//
//import Foundation
//import Photos
//
//
//class UIUtilsTests: XCTestCase {
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
//    let allYears = Array(1958...currentYear)
//
//    // Will default to 1901 for the earliest year
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: true), Array(1901...currentYear - 2))
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: false), Array(1960...currentYear))
//  }
//  
//  func testGetYearsRangeDefaultsToCurrentYear() throws {
//    let allYears: [Int] = []
//
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: true), Array(1901...currentYear - 2))
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: false), Array(1903...currentYear))
//  }
//
//  func testSanityGetYearsRangeWithEarliestYear() throws {
//    let allYears = Array(1958...currentYear)
//
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: true, earliestYear: 1958), Array(1958...currentYear - 2))
//    XCTAssertEqual(UIUtils.getYearsRange(allYears: allYears, isStartOfRange: false, earliestYear: 1958), Array(1960...currentYear))
//  }
//
//  func getGridItems(_ dates: [Date?]) -> [AssetGridItem] {
//    var gridItems: [AssetGridItem] = []
//    for i in 0..<dates.count {
//      gridItems.append(
//        AssetGridItem(asset: PHAsset(), creationDate: dates[i])
//      )
//    }
//
//    return gridItems
//  }
//
//  func testAdjustDatesSanity() throws {
//    let dates = [
//      dateFormatter.date(from: "2020-10-26 12:00:00"),
//      dateFormatter.date(from: "2020-10-27 12:00:00"),
//      dateFormatter.date(from: "2020-10-28 12:00:00"),
//      dateFormatter.date(from: "2020-10-29 12:00:00"),
//    ]
//
//    let gridItems = getGridItems(dates)
//    let beforeGridItems = gridItems.map({ item in item.copy() }) as! [AssetGridItem]
//    UIUtils.adjustDatesForGridItems(gridItems, dragging: gridItems[1])
//
//    // items are unchanged, dates are already in order
//    XCTAssertEqual(gridItems, beforeGridItems)
//  }
//
//  func testAdjustDatesDraggingFirst() throws {
//    let dates = [
//      dateFormatter.date(from: "2020-10-27 12:00:00"),
//      dateFormatter.date(from: "2020-10-26 12:00:00"),
//      dateFormatter.date(from: "2020-10-28 12:00:00"),
//      dateFormatter.date(from: "2020-10-29 12:00:00"),
//    ]
//
//    let gridItems = getGridItems(dates)
//    let beforeGridItems = gridItems.map({ item in item.copy() }) as! [AssetGridItem]
//    UIUtils.adjustDatesForGridItems(gridItems, dragging: gridItems[0])
//
//    // first item was dragged therefore its date will change
//    XCTAssertNotEqual(gridItems[0], beforeGridItems[0])
//    XCTAssertEqual(gridItems[0].newCreationDate, dateFormatter.date(from: "2020-10-26 11:59:59"))
//    XCTAssertEqual(gridItems[1], beforeGridItems[1])
//    XCTAssertEqual(gridItems[2], beforeGridItems[2])
//    XCTAssertEqual(gridItems[3], beforeGridItems[3])
//  }
//
//  func testAdjustDatesDraggingSecond() throws {
//    let dates = [
//      dateFormatter.date(from: "2020-10-27 12:00:00"),
//      dateFormatter.date(from: "2020-10-26 12:00:00"),
//      dateFormatter.date(from: "2020-10-28 12:00:00"),
//      dateFormatter.date(from: "2020-10-29 12:00:00"),
//    ]
//
//    let gridItems = getGridItems(dates)
//    let beforeGridItems = gridItems.map({ item in item.copy() }) as! [AssetGridItem]
//    UIUtils.adjustDatesForGridItems(gridItems, dragging: gridItems[1])
//
//    XCTAssertEqual(gridItems[0], beforeGridItems[0])
//    // second item was dragged therefore its date will change
//    XCTAssertNotEqual(gridItems[1], beforeGridItems[1])
//    XCTAssertEqual(gridItems[1].newCreationDate, dateFormatter.date(from: "2020-10-27 12:00:01"))
//    XCTAssertEqual(gridItems[2], beforeGridItems[2])
//    XCTAssertEqual(gridItems[3], beforeGridItems[3])
//  }
//
//  func testAdjustDatesShuffleAll() throws {
//    let dates = [
//      dateFormatter.date(from: "2020-10-27 12:00:00"),
//      dateFormatter.date(from: "2020-10-28 12:00:00"),
//      dateFormatter.date(from: "2020-10-26 12:00:00"),
//      dateFormatter.date(from: "2020-10-29 12:00:00"),
//    ]
//
//    let gridItems = getGridItems(dates)
//    let beforeGridItems = gridItems.map({ item in item.copy() }) as! [AssetGridItem]
//    UIUtils.adjustDatesForGridItems(gridItems, dragging: gridItems[1])
//
//    XCTAssertEqual(gridItems[0], beforeGridItems[0])
//    // second item was dragged therefore its date will change
//    XCTAssertNotEqual(gridItems[1], beforeGridItems[1])
//    XCTAssertEqual(gridItems[1].newCreationDate, dateFormatter.date(from: "2020-10-27 12:00:01"))
//
//    XCTAssertNotEqual(gridItems[2], beforeGridItems[2])
//    XCTAssertEqual(gridItems[2].newCreationDate, dateFormatter.date(from: "2020-10-27 12:00:02"))
//
//    // date already satifies conditions and will remain unchanged
//    XCTAssertEqual(gridItems[3], beforeGridItems[3])
//  }
//}
