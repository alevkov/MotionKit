//
//  MotionKitTests.swift
//  MotionKitTests
//
//  Created by sphota on 2/16/18.
//  Copyright © 2018 lexlevi17. All rights reserved.
//

import XCTest
import CoreMotion
@testable import MotionKit

class MotionKitTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    do {
      let _ = try MotionKit()
        .update(.Accelerometer, every: 0.3, .Seconds)
        .update(.Gyroscope, every: 0.3, .Seconds)
        .update(.Magnetometer, every: 0.3, .Seconds)
        .update(.DeviceMotion, every: 1, .Seconds)
        .subcribe(.Accelerometer) { (motion, error) in
          guard let data = motion as? Acceleration else {
            XCTFail()
            return
          }
          print(data)
        }
        .subcribe(.Gyroscope, handler: { (motion, error) in
          guard let data = motion as? Rotation else {
            XCTFail()
            return
          }
          print(data)
        })
    } catch let error as MKError {
      print("Error: \(error)")
    } catch {
      XCTFail()
    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testExample() {
    let kit = MotionKit()
        .update(.Accelerometer, every: 0.3, .Seconds)
        .update(.Gyroscope, every: 0.3, .Seconds)
        .update(.Magnetometer, every: 0.3, .Seconds)
        .update(.DeviceMotion, every: 1, .Seconds)

    XCTAssert(kit.intervalDict[.Accelerometer] == 0.3)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.3)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.3)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 1)
    
    let _ = kit.updateAll(every: 0.5, .Seconds)
    
    XCTAssert(kit.intervalDict[.Accelerometer] == 0.5)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.5)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.5)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 0.5)
    
    let _ = kit.updateAll(except: [.Accelerometer], every: 0.7, .Seconds)
    
    XCTAssert(kit.intervalDict[.Accelerometer] == 0.5)
    XCTAssert(kit.intervalDict[.Gyroscope] == 0.7)
    XCTAssert(kit.intervalDict[.Magnetometer] == 0.7)
    XCTAssert(kit.intervalDict[.DeviceMotion] == 0.7)
  }
  
}
