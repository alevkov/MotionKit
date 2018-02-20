//
//  MotionKitTests.swift
//  MotionKitTests
//
//  Created by sphota on 2/16/18.
//  Copyright © 2018 lexlevi17. All rights reserved.
//

import XCTest
@testable import MotionKit
import CoreMotion

class MotionKitTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    do {
      let _ = try MotionKit()
        .update(.Accelerometer, every: 0.3)
        .update(.Gyroscope, every: 0.3)
        .update(.Magnetometer, every: 0.3)
        .update(.DeviceMotion, every: 1)
        .subcribe(.Accelerometer) { (event, error) in
          guard let data = event as? CMAccelerometerData  else {
            XCTFail()
            return
          }
          print(data)
      }
    } catch {
      
    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testExample() {
    let kit = MotionKit()
        .update(.Accelerometer, every: 0.3)
        .update(.Gyroscope, every: 0.3)
        .update(.Magnetometer, every: 0.3)
        .update(.DeviceMotion, every: 1)

    XCTAssert(kit.intervalDict[.Accelerometer] == 0.3)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.3)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.3)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 1)
    
    let _ = kit.updateAll(every: 0.5)
    
    XCTAssert(kit.intervalDict[.Accelerometer] == 0.5)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.5)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.5)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 0.5)
    
    let _ = kit.updateAll(except: [.Accelerometer], every: 0.7)
    
    XCTAssert(kit.intervalDict[.Accelerometer] == 0.5)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.7)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.7)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 0.7)
  }
  
  func testPerformanceExample() {
    self.measure {
      
    }
  }
  
}
