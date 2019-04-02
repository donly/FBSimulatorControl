/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <FBControlCore/FBFuture.h>
#import <FBControlCore/FBTask.h>

NS_ASSUME_NONNULL_BEGIN

@class FBProcessInput;

/**
 Enumerations for possible header magic numbers in files & data.
 */
typedef enum {
  FBFileHeaderMagicUnknown = 0,
  FBFileHeaderMagicTAR = 1,
  FBFileHeaderMagicIPA = 2,
} FBFileHeaderMagic;

/**
 Operations of Zip/Tar Archives
 */
@interface FBArchiveOperations : NSObject

/**
 Extracts a zip archive to a directory.

 @param path the path of the zip archive.
 @param extractPath the extraction path.
 @param queue the queue to do work on.
 @param logger the logger to log to.
 @return a Future wrapping the extracted zip destination.
 */
+ (FBFuture<NSString *> *)extractZipArchiveAtPath:(NSString *)path toPath:(NSString *)extractPath queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Extracts a tar archive to a directory.

 @param path the path of the tar archive
 @param extractPath the extraction path.
 @param queue the queue to do work on.
 @param logger the logger to log to.
 @return a Future wrapping the extracted tar destination.
 */
+ (FBFuture<NSString *> *)extractTarArchiveAtPath:(NSString *)path toPath:(NSString *)extractPath queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Extracts an archive to a directory.
 Will determine which command to use to perform the extraction.

 @param path the path of the archive.
 @param extractPath the extraction path.
 @param queue the queue to do work on.
 @param logger the logger to log to.
 @return a Future wrapping the extracted zip/tar destination.
 */
+ (FBFuture<NSString *> *)extractArchiveAtPath:(NSString *)path toPath:(NSString *)extractPath queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Extracts a tar archive to a directory.

 @param stream the stream of the tar archive.
 @param extractPath the extraction path
 @param queue the queue to do work on
 @param logger the logger to log to
 @return a Future wrapping the extracted tar destination.
 */
+ (FBFuture<NSString *> *)extractTarArchiveFromStream:(FBProcessInput *)stream toPath:(NSString *)extractPath queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Creates a gzips archive, returning an task that has an NSInputStream attached to stdout.
 Read the input stream to obtain all of the gzip output of the file.

 @param path the path to archive.
 @param queue the queue to do work on
 @param logger the logger to log to.
 @return a A Future containing a task with an NSInputStream attached to stdout.
 */
+ (FBFuture<FBTask<NSNull *, NSInputStream *, id<FBControlCoreLogger>> *> *)gzipPath:(NSString *)path queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Creates a tar archive, returning an task that has an NSInputStream attached to stdout.
 Read the input stream to obtain all of the tar output of the file.
 The output is not gzipped.

 @param path the path to archive.
 @param queue the queue to do work on
 @param logger the logger to log to.
 @return a A Future containing a task with an NSInputStream attached to stdout.
 */
+ (FBFuture<FBTask<NSNull *, NSInputStream *, id<FBControlCoreLogger>> *> *)createTarForPath:(NSString *)path queue:(dispatch_queue_t)queue logger:(id<FBControlCoreLogger>)logger;

/**
 Get the header magic from some data.

 @param data the data to check.
 @return the header magic if one could be deduced.
 */
+ (FBFileHeaderMagic)headerMagicForData:(NSData *)data;

/**
 Get the header magic from a file

 @param path the file to checked
 @return the header magic if one could be deduced.
 */
+ (FBFileHeaderMagic)headerMagicForFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
