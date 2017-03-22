import UIKit
import Photos

public class Image: Equatable {

  public let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
}

// MARK: - Equatable

public func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

