//
//  GXFacebook.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXFacebook.h"
#import "GXBucketManager.h"

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
    }
    
    return self;
}

- (void)getUserFacebookID
{
    //GraphAPIを叩いて、ユーザのfb_idを取得(プロフィール写真表示のため)
    NSDictionary *dict = [KiiSocialConnect getAccessTokenDictionaryForNetwork:kiiSCNFacebook];
    
    NSLog(@"%@",dict);

    //AFnetworkingでユーザの情報をとってくる
    NSString *api_url = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",[dict objectForKey:@"access_token"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:api_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //成功
        NSLog(@"%@",responseObject);
        NSString *user_id = [responseObject objectForKey:@"id"];
        
        //GalaxUserBucketからuserをフェッチして
        //パラムを追加
        KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
        NSError *error = nil;
        KiiClause *clause = [KiiClause equals:@"uri" value:[KiiUser currentUser].objectURI];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        NSMutableArray *allResult = [NSMutableArray new];
        KiiQuery *nextQuery;
        
        NSArray *results = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
        
        KiiObject *current_userObject = results.firstObject;
        [current_userObject setObject:user_id forKey:@"facebook_id"];
        [current_userObject saveSynchronous:&error];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",error);
    }];
    
 
}



@end
