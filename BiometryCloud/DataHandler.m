//
//  DatabaseHandler.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 05-01-11.
//  Copyright 2011 Clockwise. All rights reserved.
//

#import "DataHandler.h"
#import "BiometryCloudConfiguration.h"

#import "/usr/include/sqlite3.h"

@implementation DataHandler


- (id) init {

	if ((self = [super init])) {
        
		databaseName = @"/BiometryCloud.sqlite";
		
		// Get the path to the documents directory and append the databaseName
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		databasePath=[[documentPaths objectAtIndex:0] stringByAppendingString:databaseName];
		
		// Execute the "checkAndCreateDatabase" function
		[self checkAndCreateDatabase];
    }    
    return self;
}

- (void)dealloc {

	[databaseName release];
	[databasePath release];

    [super dealloc];
}

-(void) checkAndCreateDatabase{
	
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL dbsuccess;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[databasePath retain];
	
	// Check if the database has already been created in the users filesystem
	dbsuccess = [fileManager fileExistsAtPath:databasePath];
	
	// If database doesn´t exist, proceed to copy the database from the application to the users filesystem
	if (!dbsuccess)
	{
        // Get the path to the database in the application package
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        
        // Copy the database from the package to the users filesystem
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	}
	
	[fileManager release];//must be released
}

#pragma mark - Checking Requests Handling

- (void) storeCheckingRequest:(CheckingRequest *) request {
	
	writing = TRUE;
	
	[databasePath retain];
	
	// Setup the database object
	sqlite3 *database;
    
    NSData *face_data = [NSData dataWithData:UIImageJPEGRepresentation(request.face, 1)];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		const char *sqlStatement = "insert into CheckingRequests(face_data, lat, lng, time, legal_id) Values(?, ?, ?, ?, ?)";
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)  {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			
            sqlite3_bind_blob(compiledStatement, 1, [face_data bytes], [face_data length], NULL);
            sqlite3_bind_double(compiledStatement, 2, request.lat);
            sqlite3_bind_double(compiledStatement, 3, request.lng);
            sqlite3_bind_text(compiledStatement, 4, [request.time UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 5, [request.legal_id UTF8String], -1, SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(compiledStatement))
				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	else {
		debugLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	
	writing = FALSE;
}

- (BOOL) areCheckingRequestsQueued {
	
	if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		int count=0;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			const char *sqlStatement = "select count(*) from CheckingRequests";
			
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
					count = sqlite3_column_int(compiledStatement, 0);
				}
			}
			else {
				debugLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			debugLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return count;
		
	}
	else {
		
		[NSThread sleepForTimeInterval:0.1];
		
		return [self areCheckingRequestsQueued];
	}
}

- (NSMutableArray *) getCheckingRequests {
	
	if (!writing) {
		[databasePath retain];
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "select * from CheckingRequests";
			sqlite3_stmt *compiledStatement;
			
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
                    NSData *face_data = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 1) length:sqlite3_column_bytes(compiledStatement, 1)];
                    double lat = sqlite3_column_double(compiledStatement, 2);
                    double lng = sqlite3_column_double(compiledStatement, 3);
					NSString *time = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                    NSString *legal_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
					
					// Create a new request object with the data from the database
					CheckingRequest *request = [[[CheckingRequest alloc] initWithURL:nil] autorelease];
                    
                    request.face = [UIImage imageWithData:face_data];
                    request.lat = lat;
                    request.lng = lng;
                    request.time = time;
                    request.legal_id = legal_id;
                    
                    [array addObject:request];
                    
					[face_data release];
				}
			}
			else {
				debugLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
            
            			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			debugLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return array;//no leaks here, do not autorelease!!
	}
	else {
		[NSThread sleepForTimeInterval:0.1];
		
		return [self getCheckingRequests];
	}
	
}

- (void) deleteCheckingRequest:(CheckingRequest *) request {

    if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "delete from CheckingRequests where time = ?";
			sqlite3_stmt *compiledStatement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                sqlite3_bind_text(compiledStatement, 1, [request.time UTF8String], -1, SQLITE_TRANSIENT);
                
                if(SQLITE_DONE != sqlite3_step(compiledStatement))
                    NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
            }
            
            // Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
        }
        
        sqlite3_close(database);
    }
    else {
		[NSThread sleepForTimeInterval:0.1];
		
		[self deleteCheckingRequest:request];
	}
}

@end
