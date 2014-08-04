//
//  GXFacebook.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXFacebook.h"

@implementation GXFacebook

+ (GXFacebook *)sharedManager
{
    static GXFacebook *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[GXFacebook alloc] initSharedInstance];
    });
    
    return sharedSingleton;
    

}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        //init
        self.facebook = [[Facebook alloc] initWithAppId:@"559613677480642" andDelegate:self];
    }
    
    return self;
}

- (void)getUserInfo
{
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

#pragma mark FBDelegate
- (void)requestLoading:(FBRequest *)request
{
    
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@", result);
    self.facebook_id = [result objectForKey:@"id"];

}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    
}

@end
