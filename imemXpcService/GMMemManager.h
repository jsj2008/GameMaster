//
//  GMMemManager.h
//  imem
//
//  Created by luobin on 14-7-15.
//
//

#import <Foundation/Foundation.h>

#define kMaxCount 1000000

@interface GMMemManager : NSObject {
    vm_address_t results[kMaxCount];
    int resultCount;
    int _pid;
}

@property (nonatomic, assign, readonly) uint64_t resultCount;

+ (instancetype)shareInstance;

- (BOOL)setPid:(int)pid;

- (NSArray *)search:(uint64_t)value isFirst:(bool)isFirst;

- (GMMemoryAccessObject *)getMemoryAccessObject:(vm_address_t)address;

- (BOOL)modifyMemory:(GMMemoryAccessObject *)accessObject;

- (NSArray *)getLockedList;

- (NSArray *)getStoredList;

- (BOOL)reset;

- (BOOL)isValid:(int)pid;

- (BOOL)isValid;

@end
