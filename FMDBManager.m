//
//  FMDBManager.m
//  FMDBDemo
//
//  Created by 刘俊彰 on 2020/5/16.
//  Copyright © 2020 AlvinLeon. All rights reserved.
//

#import "FMDBManager.h"
#import "FMDB.h"

#define FMDatabaseName_Primary @"FMDBIM.sqlite"

@interface FMDBManager (){
}
@end

@implementation FMDBManager

static FMDBManager *_shareSingleton;
static FMDatabase *_fmdb;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareSingleton = [[super allocWithZone:NULL]init];
        NSString * documentsPath=[[NSString alloc]init];
        documentsPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//获取沙河地址
        NSLog(@"DocumentsPath ===>>> %@",documentsPath);
        NSString * fileName=[documentsPath stringByAppendingPathComponent:FMDatabaseName_Primary];//设置数据库名称
        FMDatabase *fmdb=[FMDatabase databaseWithPath:fileName];//创建并获取数据库信息
        _fmdb = fmdb;
        
    });
    return _shareSingleton;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [FMDBManager shareInstance];
}
-(id)copyWithZone:(NSZone *)zone
{
    return [FMDBManager shareInstance];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [FMDBManager shareInstance];
}
- (FMDatabase *)getDatabase{
//    NSString * docPath=[[NSString alloc]init];
//    docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//获取沙河地址
//    NSString * fileName=[docPath stringByAppendingPathComponent:FMDatabaseName_Primary];//设置数据库名称
//    FMDatabase *fmdb=[FMDatabase databaseWithPath:fileName];//创建并获取数据库信息
    if (_fmdb == nil) {
        return nil;
    }
    return _fmdb;
    
}

- (FMDatabase *)getAndOpenDatabase{
//    NSString * docPath=[[NSString alloc]init];
//    docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//获取沙河地址
//    NSString * fileName=[docPath stringByAppendingPathComponent:FMDatabaseName_Primary];//设置数据库名称
//    FMDatabase *fmdb=[FMDatabase databaseWithPath:fileName];//创建并获取数据库信息
    if (_fmdb == nil) {
        return nil;
    }
    [_fmdb open];
    return _fmdb;
}

/**
 tableName:表名
 keys:建表时初始化的字段
 notNullCount:不能为空的字段的个数，即默认前notNullCount个字段设置为不能为空
 */
- (BOOL)createTableWith:(NSString *)tableName andKeys:(NSArray *)keys andNotNullCount:(NSInteger)notNullCount{
    NSMutableString *sqlStr = [[NSMutableString alloc]init];
    
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        if (i<notNullCount) {
            [sqlStr appendFormat:@" %@ text NOT NULL",key];
        }else{
            [sqlStr appendFormat:@" %@ text",key];
        }
        if (i<keys.count - 1) {
            [sqlStr appendString:@","];
        }
    }
    NSLog(@"sqlStr ===>>> %@",sqlStr);
    
    NSString *createTableSqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer NOT NULL PRIMARY KEY AUTOINCREMENT,%@);",tableName,sqlStr];
    return [[self getAndOpenDatabase] executeUpdate:createTableSqlString];
    
}

- (BOOL)updateTable:(NSString *)tableName withKey:(NSString *)key andValue:(NSString *)value forTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue{
    //@"update t_student set name = '齐天大圣'  where id = ?"
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@'  where %@ = ?;",tableName,key,value,targetKey];
//    NSInteger idStrInteger = [targetValue integerValue];
    return [[self getAndOpenDatabase] executeUpdate:sql, targetValue];
}

/**
 keys:插入记录的关键词，用逗号隔开
 values:插入记录的值，用逗号隔开
 */
- (BOOL)insertTable:(NSString *)tableName withKeys:(NSArray *)keys andValues:(NSArray *)values{
    //@"insert into t_student (name, age) values (?, ?)"
    
    if (keys.count != values.count) {
        return NO;
    }
    
    NSMutableString *keysStr = [[NSMutableString alloc]init];
    NSMutableString *valuesStr = [[NSMutableString alloc]init];
    
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        [keysStr appendFormat:@" %@",key];
        [valuesStr appendString:@" ?"];
        if (i<keys.count - 1) {
            [keysStr appendString:@","];
            [valuesStr appendString:@","];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@);",tableName,keysStr,valuesStr];
    
    return [[self getAndOpenDatabase] executeUpdate:sql withArgumentsInArray:values];
}

/**
 根据id删除表中的记录
 tableName:表名
 idCode:目标记录的id
 */
- (BOOL)deleteTable:(NSString *)tableName withID:(NSNumber *)idCode{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id = ?;",tableName];
    return [[self getAndOpenDatabase] executeUpdate:sql,idCode];
}

/**
 根据targetKey删除表中记录
 tableName:表名
 targetKey:目标记录的字段
 targetValue:目标记录的值
 */
- (BOOL)deleteTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue{
    //@"delete from t_student where id = ?";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?;",tableName,targetKey];
    return [[self getAndOpenDatabase] executeUpdate:sql, targetValue];
}

- (FMResultSet *)selectTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andtargetValue:(NSString *)targetValue{
    
//    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE '%@' = '%@';",tableName,targetKey,targetValue];
//    FMResultSet *resultSet = [[self getDatabase] executeQuery:sql];
    return [self selectTable:tableName withSelectKeys:@[@"*"] andTargetKey:targetKey andtargetValue:targetValue];;
}

- (FMResultSet *)selectTable:(NSString *)tableName withSelectKeys:(NSArray *)keys andTargetKey:(NSString *)targetKey andtargetValue:(NSString *)targetValue{
    
    NSMutableString *keysStr = [[NSMutableString alloc]init];
    
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        [keysStr appendFormat:@" %@",key];
        if (i<keys.count - 1) {
            [keysStr appendString:@","];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE '%@' = '%@';",keysStr,tableName,targetKey,targetValue];
    FMResultSet *resultSet = [[self getAndOpenDatabase] executeQuery:sql];
    return resultSet;
}

- (FMResultSet *)selectLikeTable:(NSString *)tableName withTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue{
    //    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE '%@' LIKE '%%%@%%';",tableName,targetKey,targetValue];
    return [self selectLikeTable:tableName withSelectKeys:@[@"*"] andTargetKey:targetKey andTargetValue:targetValue];
}

- (FMResultSet *)selectLikeTable:(NSString *)tableName withSelectKeys:(NSArray *)keys andTargetKey:(NSString *)targetKey andTargetValue:(NSString *)targetValue{
    
    NSMutableString *keysStr = [[NSMutableString alloc]init];
    
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        [keysStr appendFormat:@" %@",key];
        if (i<keys.count - 1) {
            [keysStr appendString:@","];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE '%@' LIKE '%%%@%%';",keysStr,tableName,targetKey,targetValue];
    FMResultSet *resultSet = [[self getAndOpenDatabase] executeQuery:sql];
    return resultSet;
}


/**
 查询符合条件的记录条数：@"SELECT COUNT( * ) FROM 'TABLE' WHERE name = '123' and age = '20' or address = 'beijing';
 查询按照id正序且符合条件的跳过前10条之后的50条：@"select * from 'TABLE' where name = '123' ORDER BY id ASC LIMIT 10, 50";   (ASC:正序；DESC:倒序)
 */



@end
