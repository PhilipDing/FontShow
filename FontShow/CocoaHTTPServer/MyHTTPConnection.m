
#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"
#import "FontShow-swift.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection

// MARK: PRIVATE METHOD
- (NSString *)documentPath {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
}

// MARK: OVERRIDE METHOD
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
  
  if ([@"POST" isEqualToString:method]) {
    return YES;
  }
  
  return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
  // Inform HTTP server that we expect a body to accompany a POST request
  
  if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"]) {
    // here we need to make sure, boundary is set in header
    NSString* contentType = [request headerField:@"Content-Type"];
    NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
    if (NSNotFound == paramsSeparator) {
      return NO;
    }
    
    if (paramsSeparator >= contentType.length - 1) {
      return NO;
    }
    
    NSString* type = [contentType substringToIndex:paramsSeparator];
    if (![type isEqualToString:@"multipart/form-data"]) {
      return NO;
    }
    
    // enumerate all params in content-type, and find boundary there
    NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
    for (NSString* param in params) {
      paramsSeparator = [param rangeOfString:@"="].location;
      if ((NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1) {
        continue;
      }
      NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator - 1)];
      NSString* paramValue = [param substringFromIndex:paramsSeparator + 1];
      
      if ([paramName isEqualToString: @"boundary"]) {
        [request setHeaderField:@"boundary" value:paramValue];
      }
    }
    // check if boundary specified
    return !(nil == [request headerField:@"boundary"]);
  }
  
  return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
  if ([method isEqualToString:@"GET"]) {
    if ([path isEqualToString:@"/"] || [path isEqualToString:@"index"]) {
      NSString *templatePath = [[config documentRoot] stringByAppendingPathComponent:@"index.html"];
      return [[HTTPFileResponse alloc] initWithFilePath:templatePath forConnection:self];
    }
  } else if ([method isEqualToString:@"POST"]) {
    
    if ([path isEqualToString:@"/loadFileNames"]) {
      NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentPath] error:NULL];
      NSMutableArray *fileNames = [[NSMutableArray alloc] init];
      for (NSString *content in contents) {
        NSString *extension = [[content pathExtension] lowercaseString];
        if ([extension isEqualToString:@"ttf"] || [extension isEqualToString:@"otf"] || [extension isEqualToString:@"ttc"]) {
          [fileNames addObject:@{@"fileName" : [content stringByDeletingPathExtension]}];
        }
      }
      
      NSData *json = [NSJSONSerialization dataWithJSONObject:fileNames options:0 error:nil];
      return [[HTTPDataResponse alloc] initWithData:json];
      
    } else if ([path isEqualToString:@"/upload"]) {

      NSDictionary *result = nil;
      if (uploadedFiles.count == 0) {
        result = @{ @"result" : @"999999" };
      } else {
        NSMutableArray *fileNames = [[NSMutableArray alloc] init];
        for (NSString *filePath in uploadedFiles) {
          [fileNames addObject:@{@"fileName": [[filePath lastPathComponent] stringByDeletingPathExtension]}];
        }
        result = @{ @"result": fileNames };
      }
      NSData *json = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
      return [[HTTPDataResponse alloc] initWithData:json];
      
    }
  }
  
  return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
  HTTPLogTrace();
  
  // set up mime parser
  NSString* boundary = [request headerField:@"boundary"];
  parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
  parser.delegate = self;
  
  uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
  HTTPLogTrace();
  // append data to the parser. It will invoke callbacks to let us handle
  // parsed data.
  [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*) header {
  // in this sample, we are not interested in parts, other then file parts.
  // check content disposition to find out filename
  
  MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
  NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
  
  if ((nil == filename) || [filename isEqualToString: @""]) {
    // it's either not a file part, or
    // an empty form sent. we won't handle it.
    return;
  }
  
//  NSString* uploadDirPath = [[self documentPath] stringByAppendingPathComponent:@"upload"];
  NSString* uploadDirPath = [self documentPath];
  
  BOOL isDir = YES;
  if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirPath isDirectory:&isDir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  NSString* filePath = [uploadDirPath stringByAppendingPathComponent:filename];
  if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
    storeFile = nil;
  }
  else {
    HTTPLogVerbose(@"Saving file to %@", filePath);
    if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
      HTTPLogError(@"Could not create file at path: %@", filePath);
    }
    storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [uploadedFiles addObject: filePath];
  }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header {
  // here we just write the output from parser to the file.
  if (storeFile) {
    [storeFile writeData:data];
  }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header {
  // as the file part is over, we close the file.
  [storeFile closeFile];
  storeFile = nil;
}

- (void)processPreambleData:(NSData*) data {
  // if we are interested in preamble data, we could process it here.
  
}

- (void) processEpilogueData:(NSData*) data {
  // if we are interested in epilogue data, we could process it here.
  
}

@end
