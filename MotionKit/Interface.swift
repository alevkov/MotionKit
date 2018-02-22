//
//  Interface.swift
//  MotionKit
//
//  Created by lexlevi17 on 2/21/18.
//  Copyright © 2018 lexlevi17. All rights reserved.
//

import Foundation

public enum MKSensorType {
  case Accelerometer
  case Gyroscope
  case Magnetometer
  case Altimeter
  case DeviceMotion
}

public enum MKTimeInterval {
  case Nanoseconds
  case Microseconds
  case Milliseconds
  case Seconds
  case Minutes
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

public protocol MKProtocol {
  /**
   Subcribe to a parrticular motion sensor.
   
   - parameter to: the sensor to which we are subscribing.
   - parameter handler: the sensor event handler.
   
   - throws: MKError.
   
   - returns: the current MotionKit instance.
   */
  func subcribe(_ to: MKSensorType, handler: @escaping (_ data: AbstractMotion?, _ error: Error?) -> ()) throws -> MotionKit
  
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
  func update(_ sensor: MKSensorType, every: TimeInterval, _ timeInterval: MKTimeInterval) -> MotionKit
  
  /**
   Set the sampling period for all motion sensors (except Altimeter).
   
   - parameter every: the sampling TimeInterval in seconds.
   
   - returns: the current MotionKit instance.
   */
  func updateAll(every: TimeInterval, _ timeInterval: MKTimeInterval) -> MotionKit
  
  /**
   Set the sampling period for all motion sensors (except the provided list of sensors, and Altimeter).
   
   - parameter every: the sampling TimeInterval in seconds.
   - parameter except: the list of sensors for which the TimeInterval will not be set.
   
   - returns: the current MotionKit instance.
   */
  func updateAll(except: [MKSensorType], every: TimeInterval, _ timeInterval: MKTimeInterval) -> MotionKit
}
