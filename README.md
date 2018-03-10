# MotionKit

A lightweight wrapper around some CoreMotion utilities for subscribing to motion sensor data.

> How do I use it?

```Swift
do {
  let _ = try MotionKit()
    .update(.Accelerometer, every: 0.3, .Seconds)
    .update(.Gyroscope, every: 0.3, .Seconds)
    .update(.Magnetometer, every: 0.3, .Seconds)
    .update(.DeviceMotion, every: 1, .Seconds)
    .subcribe(.Accelerometer) { (motion, error) in
      guard let data = motion as? Acceleration else { return }
      //..do stuff with data
    }
    .subcribe(.Gyroscope, handler: { (motion, error) in
      guard let data = motion as? Rotation else { return }
      //..do stuff with data
    })
} catch let error as MotionKitError {
  print("Error: \(error)")
} catch { }
```
