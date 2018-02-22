//
//  MKTypes.swift
//  MotionKit
//
//  Created by lexlevi17 on 2/21/18.
//  Copyright © 2018 lexlevi17. All rights reserved.
//

import Foundation
import CoreMotion

public class Motion {
  
  public var timestamp: Date

  public init(_ timestamp: Date) {
    self.timestamp = timestamp
  }
}

public class Inertial: Motion {
  
  public var x: Double
  public var y: Double
  public var z: Double
  
  public init (_ timestamp: TimeInterval, _ x: Double, _ y: Double, _ z: Double) {
    self.x = x
    self.y = y
    self.z = z
    super.init(Date(timeIntervalSinceReferenceDate: timestamp))
  }
}

public class Acceleration: Inertial {
  
  public override init(_ timestamp: TimeInterval, _ x: Double, _ y: Double, _ z: Double) {
    super.init(timestamp, x, y, z)
  }
}

public class Rotation: Inertial {
  
  public override init(_ timestamp: TimeInterval, _ x: Double, _ y: Double, _ z: Double) {
    super.init(timestamp, x, y, z)
  }
}

public class MagneticField: Inertial {
  
  public override init(_ timestamp: TimeInterval, _ x: Double, _ y: Double, _ z: Double) {
    super.init(timestamp, x, y, z)
  }
}

public class DeviceMotion: Motion {
  
  public var motion: CMDeviceMotion
  
  public init(_ motion: CMDeviceMotion) {
    self.motion = motion
    super.init(Date(timeIntervalSinceReferenceDate: motion.timestamp))
  }
}

public class Altitude: Motion {
  
  public var relativeAltitude: NSNumber
  public var pressure: NSNumber
  
  public init(_ timestamp: TimeInterval, _ relalt: NSNumber, _ pressure: NSNumber) {
    self.relativeAltitude = relalt
    self.pressure = pressure
    super.init(Date(timeIntervalSinceReferenceDate: timestamp))
  }
}
