# MotionKit

A lightweight wrapper around some CoreMotion utilities for subscribing to motion sensor data.

```
do {
  let _ = try MotionKit()
    .update(.Accelerometer, every: 0.3)
    .update(.Gyroscope, every: 0.3)
    .update(.Magnetometer, every: 0.3)
    .update(.DeviceMotion, every: 1)
    .subcribe(.Accelerometer) { (event, error) in
      guard let data = event as? CMAccelerometerData  else { print("Oops?") }
      // handle sensor event...
    }
} catch MKError.AccelerometerNotAvailable {
  print("Accelerometer data not available!")
}
```
