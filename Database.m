/********************************************************************************\
 *
 * File Name       Database.m
 *
 \********************************************************************************/

#import "Database.h"
static Database *shareDatabase =nil;

@implementation Database
#pragma mark -
#pragma mark Database


+(Database*) shareDatabase{
    
    if(!shareDatabase){
        shareDatabase = [[Database alloc] init];
    }
    
    return shareDatabase;
    
}

#pragma mark -
#pragma mark Get DataBase Path
NSString * const DataBaseName  = @"TestDB.db"; // Paas Your DataBase Name Over here

- (NSString *) GetDatabasePath{
    NSString *strDocDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) objectAtIndex:0];
    return [strDocDirPath stringByAppendingPathComponent:DataBaseName];
}

#pragma mark -
#pragma mark Create Editable Copy Of Database

-(BOOL) createDataBase{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DataBaseName];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return success;
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DataBaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!!" message:@"Failed to create writable database..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    return success;
}

#pragma mark -
#pragma mark Get All Record




-(BOOL)createtable:(NSString *)CreatetableQuery
{
//    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath];
    
    NSMutableArray *alldata;
    alldata = [[NSMutableArray alloc] init];
    bool isSuccess = YES;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        char *errMsg;
//        const char *sql_stmt = CreatetableQuery; // "create table if not exists studentsDetail (regno integer primary key, name text, department text, year text)";
        if (sqlite3_exec(databaseObj, [CreatetableQuery UTF8String], NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            isSuccess = NO;
            NSLog(@"Failed to create table");
        }
        sqlite3_close(databaseObj);
        return  isSuccess;
    }
    else
    {
        return isSuccess;
    }
    
    
}


-(NSMutableArray *)SelectAllFromTable:(NSString *)query
{
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath];
    
    NSMutableArray *alldata;
    alldata = [[NSMutableArray alloc] init];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary *currentRow = [NSMutableDictionary dictionary];
                
                int count = sqlite3_column_count(statement);
                
                for (int i=0; i < count; i++) {
                    
                    char *name = (char*) sqlite3_column_name(statement, i);
                    char *data = (char*) sqlite3_column_text(statement, i);
                    
                    NSString *columnData;
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    
                    if(data != nil){
                        columnData = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
                        columnData =[(NSString *)columnData stringByReplacingOccurrencesOfString:@"%" withString:@"#perctage#"];
                        columnData=[columnData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        columnData =[(NSString *)columnData stringByReplacingOccurrencesOfString:@"#perctage#" withString:@"%"];
                    }else {
                        columnData = @"";
                    }
                    [currentRow setObject:columnData forKey:columnName];
                    columnData = nil;
                    columnName = nil;
                }
                
                [alldata addObject:currentRow];
                currentRow = nil;
            }
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return alldata;
    
}

#pragma mark -
#pragma mark Get Record Count

-(int)getCount:(NSString *)query
{
    int m_count=0;
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath] ;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                m_count= sqlite3_column_int(statement,0);
            }
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return m_count;
}

#pragma mark -
#pragma mark Check For Record Present

-(BOOL)CheckForRecord:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath];
    int isRecordPresent = 0;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                isRecordPresent = 1;
            }
            else {
                isRecordPresent = 0;
            }
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return isRecordPresent;
}

#pragma mark -
#pragma mark Insert

- (void)Insert:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath];
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark -
#pragma mark DeleteRecord

-(void)Delete:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath] ;
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark -
#pragma mark UpdateRecord

-(void)Update:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath] ;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if(sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}
#pragma mark -
#pragma mark GetSum

-(int)GetSum:(NSString*)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self  GetDatabasePath];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
        {			
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    NSString *sum = nil;
    if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
    {			
        
        while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            sum = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 0)];
        }	
        
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on mem warning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return [sum intValue];
}

@end
