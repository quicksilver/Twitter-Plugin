//
//  TwitterUtil.h
//  QSTwit
//
//  Created by Masato Igarashi on 11/05/07.
//  Copyright 2011 @migrs. All rights reserved.
//

#import <Foundation/Foundation.h>

void TwitterNotify(NSString *message);
NSDictionary *AccessTokenRequest(NSString *username, NSString *password);
NSDictionary *Tweet(NSString *message, NSString *token, NSString *secret);
