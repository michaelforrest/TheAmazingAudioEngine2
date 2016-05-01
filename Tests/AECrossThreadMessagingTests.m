//
//  AECrossThreadMessagingTests.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AEMainThreadEndpoint.h"
#import "AEAudioThreadEndpoint.h"
#import "AEMessageQueue.h"

@interface AECrossThreadMessagingTests : XCTestCase
@end

@implementation AECrossThreadMessagingTests

- (void)testMainThreadEndpointMessaging {
    NSMutableArray * messages = [NSMutableArray array];
    AEMainThreadEndpoint * endpoint = [[AEMainThreadEndpoint alloc] initWithHandler:^(const void *data, size_t length) {
        [messages addObject:[NSData dataWithBytes:data length:length]];
    }];
    
    [endpoint startPolling];
    
    AEMainThreadEndpointSend(endpoint, NULL, 0);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:endpoint.pollInterval]];
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:NULL length:0]]));
    [messages removeAllObjects];
    
    int value1 = 1;
    int value2 = 2;
    double value3 = 3;
    AEMainThreadEndpointSend(endpoint, &value1, sizeof(value1));
    AEMainThreadEndpointSend(endpoint, &value2, sizeof(value2));
    AEMainThreadEndpointSend(endpoint, &value3, sizeof(value3));
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:endpoint.pollInterval]];
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:&value1 length:sizeof(value1)], [NSData dataWithBytes:&value2 length:sizeof(value2)], [NSData dataWithBytes:&value3 length:sizeof(value3)]]));
    [messages removeAllObjects];
    
    endpoint.bufferCapacity = 1024;
    AEMainThreadEndpointSend(endpoint, &value1, sizeof(value1));
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:endpoint.pollInterval]];
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:&value1 length:sizeof(value1)]]));
    [messages removeAllObjects];
    
    [endpoint endPolling];
    
    XCTAssertFalse(AEMainThreadEndpointSend(endpoint, NULL, 0));
    
    __weak AEMainThreadEndpoint * weakEndpoint = endpoint;
    endpoint = nil;
    
    XCTAssertNil(weakEndpoint);
}

- (void)testAudioThreadEndpointMessaging {
    NSMutableArray * messages = [NSMutableArray array];
    AEAudioThreadEndpoint * endpoint = [[AEAudioThreadEndpoint alloc] initWithHandler:^(const void *data, size_t length) {
        [messages addObject:[NSData dataWithBytes:data length:length]];
    }];
    
    [endpoint sendBytes:NULL length:0];
    AEAudioThreadEndpointPoll(endpoint);
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:NULL length:0]]));
    [messages removeAllObjects];
    
    int value1 = 1;
    int value2 = 2;
    double value3 = 3;
    [endpoint sendBytes:&value1 length:sizeof(value1)];
    [endpoint sendBytes:&value2 length:sizeof(value2)];
    [endpoint sendBytes:&value3 length:sizeof(value3)];
    AEAudioThreadEndpointPoll(endpoint);
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:&value1 length:sizeof(value1)], [NSData dataWithBytes:&value2 length:sizeof(value2)], [NSData dataWithBytes:&value3 length:sizeof(value3)]]));
    [messages removeAllObjects];
    
    [endpoint beginMessageGroup];
    [endpoint sendBytes:&value1 length:sizeof(value1)];
    [endpoint sendBytes:&value2 length:sizeof(value2)];
    
    AEAudioThreadEndpointPoll(endpoint);
    XCTAssertEqualObjects(messages, (@[]));
    
    [endpoint sendBytes:&value3 length:sizeof(value3)];
    
    [endpoint endMessageGroup];
    
    AEAudioThreadEndpointPoll(endpoint);
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:&value1 length:sizeof(value1)], [NSData dataWithBytes:&value2 length:sizeof(value2)], [NSData dataWithBytes:&value3 length:sizeof(value3)]]));
    [messages removeAllObjects];
    
    
    endpoint.bufferCapacity = 1024;
    [endpoint sendBytes:&value1 length:sizeof(value1)];
    AEAudioThreadEndpointPoll(endpoint);
    
    XCTAssertEqualObjects(messages, (@[[NSData dataWithBytes:&value1 length:sizeof(value1)]]));
    [messages removeAllObjects];
}

- (void)testMessageQueue {
    AEMessageQueue * queue = [AEMessageQueue new];
    [queue startPolling];
    
    __block BOOL hitBlock = NO;
    __block BOOL hitCompletionBlock = NO;
    id object = [NSObject new];
    @autoreleasepool {
        [queue performBlockOnAudioThread:^{
            hitBlock = YES;
            (void)object;
        } completionBlock:^{
            hitCompletionBlock = YES;
            (void)object;
        }];
    }
    __weak id weakObject = object;
    object = nil;
    
    XCTAssertNotNil(weakObject);
    
    AEMessageQueuePoll(queue);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:queue.pollInterval]];
    
    XCTAssertTrue(hitBlock);
    XCTAssertTrue(hitCompletionBlock);
    
    XCTAssertNil(weakObject);
    
    __weak id weakQueue = queue;
    queue = nil;
    
    XCTAssertNil(weakQueue);
}

@end