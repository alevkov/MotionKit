//
//  MotionKit.swift
//  TrackSense
//
//  Created by lexlevi17 on 8/25/17.
//  Copyright © 2017 lexlevi17. All rights reserved.
//

import Foundation
import CoreMotion

public enum MKSensorType {
  case Accelerometer
  case Gyroscope
  case Magnetometer
  case Altimeter
  case DeviceMotion
}

public enum MKError: Error {
  case AccelerometerNotAvailable
  case GyroscopeNotAvailable
  case MagnetometerNotAvailable
  case DeviceMotionNotAvailable
  case AltimeterNotAvailable
  case UknownSensorType
  case SensorIntervalNotSet
}

public protocol MotionKitProtocol {
  /**
   Subcribe to a parrticular motion sensor.
   
   - parameter to: the sensor to which we are subscribing.
   - parameter handler: the sensor event handler.
   
   - throws: MKError.
   
   - returns: the current MotionKit instance.
  */
  func subcribe(_ to: MKSensorType, handler: @escaping (_ event: CMLogItem?, _ error: Error?) -> ()) throws -> MotionKit
  
  /**
   Unsubscribe from a parrticular motion sensor.
   
   - parameter from: the sensor from which we are unsubscribing.
   
   - throws: MKError.
   
   - returns: the current MotionKit instance.
   */
  func unsubscribe(_ from: MKSensorType) throws -> MotionKit
  
  /**
   Set the sampling period for a sensor. Will have no effect on the Altimeter sampling period.
   
   - parameter sensor: the sensor for which we are setting the sampling period.
   - parameter every: the sampling TimeInterval in seconds.
   
   - returns: the current MotionKit instance.
   */
  func update(_ sensor: MKSensorType, every: TimeInterval) -> MotionKit
  
  /**
   Set the sampling period for all motion sensors (except Altimeter).
   
   - parameter every: the sampling TimeInterval in seconds.
   
   - returns: the current MotionKit instance.
   */
  func updateAll(every: TimeInterval) -> MotionKit
  
  /**
   Set the sampling period for all motion sensors (except the provided list of sensors, and Altimeter).
   
   - parameter every: the sampling TimeInterval in seconds.
   - parameter except: the list of sensors for which the TimeInterval will not be set.
   
   - returns: the current MotionKit instance.
   */
  func updateAll(except: [MKSensorType], every: TimeInterval) -> MotionKit
}

public final class MotionKit: MotionKitProtocol {
  
  internal var intervalDict: Dictionary<MKSensorType, TimeInterval>
  internal let altimeter = CMAltimeter()
  internal let motionManager = CMMotionManager()
  internal let strictlyMotionSensors = [MKSensorType.Accelerometer,
                                       MKSensorType.Gyroscope,
                                       MKSensorType.Magnetometer,
                                       MKSensorType.DeviceMotion]
  
  public init() {
    self.intervalDict = Dictionary<MKSensorType, TimeInterval>()
  }
  
  public func update(_ sensor: MKSensorType, every: TimeInterval) -> MotionKit  {
    guard self.strictlyMotionSensors.contains(sensor) else {
      return self
    }
    self.intervalDict[sensor] = every
    return self
  }
  
  public func updateAll(every: TimeInterval) -> MotionKit {
    for key in self.intervalDict.keys {
      if self.strictlyMotionSensors.contains(key) {
        self.intervalDict[key] = every
      }
    }
    return self
  }
  
  public func updateAll(except: [MKSensorType], every: TimeInterval) -> MotionKit {
    for key in self.intervalDict.keys {
      if self.strictlyMotionSensors.contains(key) && !except.contains(key) {
        self.intervalDict[key] = every
      }
    }
    return self
  }
  
  public func subcribe(_ to: MKSensorType,
                       handler: @escaping (CMLogItem?, Error?) -> ()) throws -> MotionKit {
    
    switch to {
    case .Accelerometer:
      guard self.motionManager.isAccelerometerAvailable else {
        throw MKError.AccelerometerNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MKError.SensorIntervalNotSet
      }
      
      self.motionManager.accelerometerUpdateInterval = interval
      self.motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        handler(data, nil)
      })
      
      break
      
    case .Gyroscope:
      guard self.motionManager.isGyroAvailable else {
        throw MKError.GyroscopeNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MKError.SensorIntervalNotSet
      }
      
      self.motionManager.gyroUpdateInterval = interval
      self.motionManager.startGyroUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        handler(data, nil)
      })
      
      break
      
    case .Magnetometer:
      guard self.motionManager.isMagnetometerAvailable else {
        throw MKError.MagnetometerNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MKError.SensorIntervalNotSet
      }
      
      self.motionManager.magnetometerUpdateInterval = interval
      self.motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        handler(data, nil)
      })
      
      break
      
    case .DeviceMotion:
      guard self.motionManager.isDeviceMotionAvailable else {
        throw MKError.DeviceMotionNotAvailable
      }
      
      guard let interval = self.intervalDict[to] else {
        throw MKError.SensorIntervalNotSet
      }
      
      self.motionManager.deviceMotionUpdateInterval = interval
      self.motionManager.startDeviceMotionUpdates(to: OperationQueue(), withHandler: { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        handler(data, nil)
      })
      
      break
      
    case .Altimeter:
      guard CMAltimeter.isRelativeAltitudeAvailable() else {
        throw MKError.AltimeterNotAvailable
      }
      
      altimeter.startRelativeAltitudeUpdates(to: OperationQueue()) { (data, error) in
        guard error == nil else {
          handler(nil, error)
          return
        }
        handler(data, nil)
      }
      
      break
    }
    
    return self
  }
  
  public func unsubscribe(_ from: MKSensorType) throws -> MotionKit {
    
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
}
