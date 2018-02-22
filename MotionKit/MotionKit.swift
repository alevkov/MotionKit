//
//  MotionKit.swift
//  TrackSense
//
//  Created by lexlevi17 on 8/25/17.
//  Copyright © 2017 lexlevi17. All rights reserved.
//

import Foundation
import CoreMotion

public final class MotionKit: MotionKitProtocol {
  
  internal var intervalDict: Dictionary<MotionSensor, TimeInterval>
  internal let altimeter = CMAltimeter()
  internal let motionManager = CMMotionManager()
  internal let strictlyMotionSensors = [MotionSensor.Accelerometer,
                                       MotionSensor.Gyroscope,
                                       MotionSensor.Magnetometer,
                                       MotionSensor.DeviceMotion]
  
  public init() {
    self.intervalDict = Dictionary<MotionSensor, TimeInterval>()
  }
  
  public func update(_ sensor: MotionSensor, every: TimeInterval, _ timeUnit: TimeUnit) -> MotionKit  {
    guard self.strictlyMotionSensors.contains(sensor) else {
      return self
    }
    let timeInterval: TimeInterval = self.convertToSeconds(every, timeUnit)
    self.intervalDict[sensor] = timeInterval
    return self
  }
  
  public func updateAll(every: TimeInterval, _ timeUnit: TimeUnit) -> MotionKit {
    for key in self.intervalDict.keys {
      if self.strictlyMotionSensors.contains(key) {
        let timeInterval: TimeInterval = self.convertToSeconds(every, timeUnit)
        self.intervalDict[key] = timeInterval
      }
    }
    return self
  }
  
  public func updateAll(except: [MotionSensor], every: TimeInterval, _ timeUnit: TimeUnit) -> MotionKit {
    for key in self.intervalDict.keys {
      if self.strictlyMotionSensors.contains(key) && !except.contains(key) {
        let timeInterval: TimeInterval = self.convertToSeconds(every, timeUnit)
        self.intervalDict[key] = timeInterval
      }
    }
    return self
  }
  
  public func subcribe(_ to: MotionSensor,
                       handler: @escaping (Motion?, Error?) -> ()) throws -> MotionKit {
    
    switch to {
    case .Accelerometer:
      guard self.motionManager.isAccelerometerAvailable else {
        throw MotionKitError.AccelerometerNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MotionKitError.SensorIntervalNotSet
      }
      
      self.motionManager.accelerometerUpdateInterval = interval
      self.motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        guard let d = data else { handler(nil, MotionKitError.AccelerometerNotAvailable); return }
        let acceleration = Acceleration(d.timestamp, d.acceleration.x, d.acceleration.y, d.acceleration.z)
        handler(acceleration, nil)
      })
      
      break
      
    case .Gyroscope:
      guard self.motionManager.isGyroAvailable else {
        throw MotionKitError.GyroscopeNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MotionKitError.SensorIntervalNotSet
      }
      
      self.motionManager.gyroUpdateInterval = interval
      self.motionManager.startGyroUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        guard let d = data else { handler(nil, MotionKitError.GyroscopeNotAvailable); return }
        let rotation = Rotation(d.timestamp, d.rotationRate.x, d.rotationRate.y, d.rotationRate.z)
        handler(rotation, nil)
      })
      
      break
      
    case .Magnetometer:
      guard self.motionManager.isMagnetometerAvailable else {
        throw MotionKitError.MagnetometerNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MotionKitError.SensorIntervalNotSet
      }
      
      self.motionManager.magnetometerUpdateInterval = interval
      self.motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        guard let d = data else { handler(nil, MotionKitError.MagnetometerNotAvailable); return }
        let magfield = MagneticField(d.timestamp, d.magneticField.x, d.magneticField.y, d.magneticField.z)
        handler(magfield, nil)
      })
      
      break
      
    case .DeviceMotion:
      guard self.motionManager.isDeviceMotionAvailable else {
        throw MotionKitError.DeviceMotionNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MotionKitError.SensorIntervalNotSet
      }
      
      self.motionManager.deviceMotionUpdateInterval = interval
      self.motionManager.startDeviceMotionUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        guard let d = data else { handler(nil, MotionKitError.DeviceMotionNotAvailable); return }
        let motion = DeviceMotion(d)
        handler(motion, nil)
      })
      
      break
      
    case .Altimeter:
      guard CMAltimeter.isRelativeAltitudeAvailable() else {
        throw MotionKitError.AltimeterNotAvailable
      }
      
      altimeter.startRelativeAltitudeUpdates(to: OperationQueue()) { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        guard let d = data else { handler(nil, MotionKitError.AltimeterNotAvailable); return }
        let altitude = Altitude(d.timestamp, d.relativeAltitude, d.pressure)
        handler(altitude, nil)
      }
      
      break
    }
    
    return self
  }
  
  public func unsubscribe(_ from: MotionSensor) throws -> MotionKit {
    
    switch from {
    case .Accelerometer:
      guard motionManager.isAccelerometerActive else {
        print("Unsubscribing from inactive sensor:" + String(describing: from))
        return self
      }
      motionManager.stopAccelerometerUpdates()
      
      break
      
    case .Gyroscope:
      guard motionManager.isGyroAvailable else {
        print("Unsubscribing from inactive sensor:" + String(describing: from))
        return self
      }
      motionManager.stopGyroUpdates()
      
      break
      
    case .Magnetometer:
      guard motionManager.isMagnetometerAvailable else {
        print("Unsubscribing from inactive sensor:" + String(describing: from))
        return self
      }
      motionManager.stopMagnetometerUpdates()
      
      break
      
    case .DeviceMotion:
      guard motionManager.isDeviceMotionAvailable else {
        print("Unsubscribing from inactive sensor:" + String(describing: from))
        return self
      }
      motionManager.stopDeviceMotionUpdates()
      
      break
      
    case .Altimeter:
      guard CMAltimeter.isRelativeAltitudeAvailable() else {
        print("Unsubscribing from inactive sensor:" + String(describing: from))
        return self
      }
      altimeter.stopRelativeAltitudeUpdates()
      
      break
    }
    
    return self
  }
  
  private func convertToSeconds(_ value: TimeInterval, _ interval: TimeUnit) -> TimeInterval {
    var val: TimeInterval = value
    switch interval {
    case .Nanoseconds:
      val /= 1000_000_000
      break
    case .Microseconds:
      val /= 1000_000
      break
    case .Milliseconds:
      val /= 1000
      break
    case .Seconds:
      break
    case .Minutes:
      val *= 60
      break
    }
    return val
  }
}
