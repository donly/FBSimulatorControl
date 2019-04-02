/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "FBXcodeConfiguration.h"

#import <Cocoa/Cocoa.h>

#import "FBTaskBuilder.h"
#import "FBXcodeDirectory.h"
#import "FBFuture+Sync.h"

@implementation FBXcodeConfiguration

+ (NSString *)developerDirectory
{
  static dispatch_once_t onceToken;
  static NSString *directory;
  dispatch_once(&onceToken, ^{
    directory = [self findXcodeDeveloperDirectoryOrAssert];
  });
  return directory;
}

+ (nullable NSString *)appleConfiguratorApplicationPath
{
  static NSString *path = nil;
#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    path = [NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:@"com.apple.configurator.ui"];
  });
#endif
  return path;
}

+ (NSDecimalNumber *)xcodeVersionNumber
{
  static dispatch_once_t onceToken;
  static NSDecimalNumber *versionNumber;
  dispatch_once(&onceToken, ^{
    NSString *versionNumberString = [FBXcodeConfiguration
      readValueForKey:@"CFBundleShortVersionString"
      fromPlistAtPath:FBXcodeConfiguration.xcodeInfoPlistPath];
    versionNumber = [NSDecimalNumber decimalNumberWithString:versionNumberString];
  });
  return versionNumber;
}

+ (NSString *)iosSDKVersion
{
  static dispatch_once_t onceToken;
  static NSString *sdkVersion;
  dispatch_once(&onceToken, ^{
    sdkVersion = [FBXcodeConfiguration
      readValueForKey:@"Version"
      fromPlistAtPath:FBXcodeConfiguration.iPhoneSimulatorPlatformInfoPlistPath];
  });
  return sdkVersion;
}

+ (NSDecimalNumber *)iosSDKVersionNumber
{
  return [NSDecimalNumber decimalNumberWithString:self.iosSDKVersion];
}

+ (NSNumberFormatter *)iosSDKVersionNumberFormatter
{
  static dispatch_once_t onceToken;
  static NSNumberFormatter *formatter;
  dispatch_once(&onceToken, ^{
    formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 3;
  });
  return formatter;
}

+ (BOOL)isXcode7OrGreater
{
  return [FBXcodeConfiguration.xcodeVersionNumber compare:[NSDecimalNumber decimalNumberWithString:@"7.0"]] != NSOrderedAscending;
}

+ (BOOL)isXcode8OrGreater
{
  return [FBXcodeConfiguration.xcodeVersionNumber compare:[NSDecimalNumber decimalNumberWithString:@"8.0"]] != NSOrderedAscending;
}

+ (BOOL)isXcode9OrGreater
{
  return [FBXcodeConfiguration.xcodeVersionNumber compare:[NSDecimalNumber decimalNumberWithString:@"9.0"]] != NSOrderedAscending;
}

+ (BOOL)isXcode10OrGreater
{
  return [FBXcodeConfiguration.xcodeVersionNumber compare:[NSDecimalNumber decimalNumberWithString:@"10.0"]] != NSOrderedAscending;
}

+ (BOOL)supportsCustomDeviceSets
{
  // Prior to Xcode 7, 'iOS Simulator.app' calls `+[SimDeviceSet defaultSet]` directly
  // This means that the '-DeviceSetPath' won't do anything for Simulators booted with prior to Xcode 7.
  // It should be possible to fix this by injecting a shim that swizzles this method in these Xcode versions.
  return self.isXcode7OrGreater;
}

+ (NSString *)description
{
  return [NSString stringWithFormat:
    @"Developer Directory %@ | Xcode Version %@ | iOS SDK Version %@ | Supports Custom Device Sets %d",
    self.developerDirectory,
    self.xcodeVersionNumber,
    self.iosSDKVersionNumber,
    self.supportsCustomDeviceSets
  ];
}

- (NSString *)description
{
  return [FBXcodeConfiguration description];
}

#pragma mark FBJSONConversion

- (id)jsonSerializableRepresentation
{
  return @{
     @"developer_directory" : FBXcodeConfiguration.developerDirectory,
     @"xcode_version" : FBXcodeConfiguration.xcodeVersionNumber,
     @"ios_sdk_version" : FBXcodeConfiguration.iosSDKVersionNumber,
  };
}

#pragma mark Private

+ (NSString *)iPhoneSimulatorPlatformInfoPlistPath
{
  return [[self.developerDirectory
    stringByAppendingPathComponent:@"Platforms/iPhoneSimulator.platform"]
    stringByAppendingPathComponent:@"Info.plist"];
}

+ (NSString *)xcodeInfoPlistPath
{
  return [[self.developerDirectory
    stringByDeletingLastPathComponent]
    stringByAppendingPathComponent:@"Info.plist"];
}

+ (NSString *)findXcodeDeveloperDirectoryOrAssert
{
  NSError *error = nil;
  NSString *directory = [FBXcodeDirectory.xcodeSelectFromCommandLine.xcodePath await:&error];
  NSAssert(directory, error.description);
  return directory;
}

+ (nullable id)readValueForKey:(NSString *)key fromPlistAtPath:(NSString *)plistPath
{
  NSAssert([NSFileManager.defaultManager fileExistsAtPath:plistPath], @"plist does not exist at path '%@'", plistPath);
  NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  NSAssert(infoPlist, @"Could not read plist at '%@'", plistPath);
  id value = infoPlist[key];
  NSAssert(value, @"'%@' does not exist in plist '%@'", key, infoPlist.allKeys);
  return value;
}

@end
