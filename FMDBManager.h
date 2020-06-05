//
//  FMDBManager.h
//  FMDBDemo
//
//  Created by 刘俊彰 on 2020/5/16.
//  Copyright © 2020 AlvinLeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"


@class FMResultSet;

#define Default_Database_Name @"FMDBIM.sqlite"
#define t_Table_Messages_Name @"t_messages"
#define t_Table_Session_Name @"t_session"
#define t_Table_UserInfo_Name @"t_userinfo"


NS_ASSUME_NONNULL_BEGIN

@interface FMDBManager : NSObject
/**
 获取FMDBManager单例
 */
+ (instancetype)shareInstance;

- (FMDatabase *)getDatabase;
- (FMDatabase *)getAndOpenDatabase;

/**
 根据表名tableName，在默认数据库中创建表，设置前notNullCount个字段不为空
 tableName：表名
 keys：初始化字段名，类型是NSArray数组
 notNullCount：不为空字段的个数，即前notNullCount个字段不为空
 */
- (BOOL)createTableWith:(NSString *)tableName andKeys:(NSArray *)keys andNotNullCount:(NSInteger)notNullCount;

/**
 根据关键字更新表记录
 tableName：表名
 key：需要更新的字段
 value：需要更新的值
 targetKey：目标记录的字段
 targetValue：目标记录的值
 */
- (BOOL)updateTable:(NSString *)tableName withKey:(NSString *)key andValue:(NSString *)value forTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue;

/**
 插入一条数据
 tableName：表名
 keys：插入的字段名
 value：插入记录的值
 */
- (BOOL)insertTable:(NSString *)tableName withKeys:(NSArray *)keys andValues:(NSArray *)values;

/**
 根据idCode从tableName表中删除一条id为idCode的数据
 */
- (BOOL)deleteTable:(NSString *)tableName withID:(NSNumber *)idCode;

/**
 根据targetKey和TtargetValue从tableName表中删除一条数据
 */
- (BOOL)deleteTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue;

/** 精确查询
 根据targetKey和targetValue在表tableName中查询一条完整记录
 */
- (FMResultSet *)selectTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andtargetValue:(NSString *)targetValue;

/** 精确查询
根据targetKey和targetValue在表tableName中查询一条只含有keys字段的记录
*/
- (FMResultSet *)selectTable:(NSString *)tableName withSelectKeys:(NSArray *)keys andTargetKey:(NSString *)targetKey andtargetValue:(NSString *)targetValue;

/** 模糊查询
 根据targetKey和targetValue在表tableName中查询一条完整字段的记录
 */
- (FMResultSet *)selectLikeTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue;

/** 模糊查询
根据targetKey和targetValue在表tableName中查询一条只含有keys字段的记录
*/
- (FMResultSet *)selectLikeTable:(NSString *)tableName withSelectKeys:(NSArray *)keys andTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue;

@end

NS_ASSUME_NONNULL_END
