
import Foundation

// Functions that help us make and use vectors
extension CGVector {
  /// Creates a vector using an angle and length
  /// - parameter angleRadians: An angle in radians
  /// - parameter length: A vector length
  init(angleRadians: CGFloat, length: CGFloat) {
    let dx = cos(angleRadians) * length
    let dy = sin(angleRadians) * length
    self.init(dx: dx, dy: dy)
  }

  /// Creates a vector using an angle and length
  /// - parameter angleDegrees: An angle in degrees
  /// - parameter length: A vector length
  init(angleDegrees: CGFloat, length: CGFloat) {
    self.init(angleRadians: angleDegrees / 180.0 * .pi, length: length)
  }

  /// - returns: The angle of the vector in radians
  func angleRadians() -> CGFloat {
    return atan2(dy, dx)
  }

  /// - returns: The angle of the vector in degrees
  func angleDegrees() -> CGFloat {
    return angleRadians() * 180.0 / .pi
  }

  /// - returns: The length (or magnitude) of the vector
  func length() -> CGFloat {
    return sqrt(pow(dx, 2) + pow(dy, 2))
  }
}
