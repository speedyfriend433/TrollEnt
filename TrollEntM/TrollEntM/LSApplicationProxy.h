//
//  LSApplicationProxy.h
//  TrollEntM
//
//  Created by speedy on 2/26/25.
//

#import <Foundation/Foundation.h>

@interface LSApplicationProxy : NSObject

+ (instancetype)applicationProxyForIdentifier:(NSString *)identifier;
+ (NSArray<LSApplicationProxy *> *)installedApplications;

@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *bundleIdentifier;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *bundleVersion;
@property (nonatomic, readonly) NSString *bundleExecutable;
@property (nonatomic, readonly) NSURL *bundleURL;
@property (nonatomic, readonly) NSURL *bundleContainerURL;
@property (nonatomic, readonly) NSURL *dataContainerURL;
@property (nonatomic, readonly) NSArray *deviceFamily;
@property (nonatomic, readonly) NSDictionary *entitlements;

@end
