//
//  QMContactListCache.m
//  QMContactListCache
//
//  Created by Andrey on 06.11.14.
//
//

#import "QMContactListCache.h"
#import "ModelIncludes.h"

@implementation QMContactListCache

#pragma mark - Public methods

- (void)cachedQBUsers:(void(^)(NSArray *array))users {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *cdUsers = [CDUser MR_findAllInContext:context];
        NSArray *allUsers = (cdUsers.count == 0) ? @[] : [weakSelf qbUsersWithCDUsers:cdUsers];
        
        DO_AT_MAIN(users(allUsers));
        
    }];
}

- (void)cacheQBUsers:(NSArray *)users finish:(void(^)(void))finish {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        [weakSelf mergeQBUsers:users inContext:context finish:finish];
    }];
}

- (void)cachedQBContactListItems:(void(^)(NSArray *array))contactListItems {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *allContactListItems = [weakSelf allContactListItems:context];
        DO_AT_MAIN(contactListItems(allContactListItems));
    }];
}

- (void)cacheQBContactListItems:(NSArray *)contactListItems finish:(void(^)(void))finish {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *allContactListItems = [CDContactListItem MR_findAllInContext:context];
        
        for (CDContactListItem *toDelete in allContactListItems) {
            [toDelete MR_deleteEntityInContext:context];
        }
        
        for (QBContactListItem *toAdd in contactListItems) {
            
            CDContactListItem *listItem = [CDContactListItem MR_createEntityInContext:context];
            [listItem updateWithQBContactListItem:toAdd];
        }
        
        [weakSelf save:finish];
    }];
}

#pragma mark - Private methods

- (NSArray *)allContactListItems:(NSManagedObjectContext *)context {
    
    NSArray *contactListItems = [CDContactListItem MR_findAllInContext:context];
    NSArray *result = (contactListItems.count == 0) ? @[] : [self contactListItemsWithCDContactListItems:contactListItems];
    
    return result;
}

- (NSArray *)contactListItemsWithCDContactListItems:(NSArray *)items {
    
    NSMutableArray *qbContactListItems = [NSMutableArray arrayWithCapacity:items.count];
    
    for (CDContactListItem *item in items) {
        QBContactListItem *qbContactListItem = [item toQBContactListItem];
        [qbContactListItems addObject:qbContactListItem];
    }
    
    return qbContactListItems;
}

- (NSArray *)qbUsersWithCDUsers:(NSArray *)cdUsers {
    
    NSMutableArray *qbUsers = [NSMutableArray arrayWithCapacity:cdUsers.count];
    
    for (CDUser *user in cdUsers) {
        QBUUser *qbUser = [user toQBUUser];
        [qbUsers addObject:qbUser];
    }
    
    return qbUsers;
}

- (void)mergeQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context finish:(void(^)(void))finish {
    
    NSMutableArray *toInsert = [NSMutableArray array];
    NSMutableArray *toUpdate = [NSMutableArray array];
    
    //Update/Insert/Delete
    
    for (QBUUser *user in qbUsers) {
        
        CDUser *cdUser = [CDUser MR_findFirstWithPredicate:IS(@"id", @(user.ID)) inContext:context];
        
        if (cdUser) {
            
            QBUUser *qbUserInCache = [cdUser toQBUUser];
            if (![qbUsers containsObject:qbUserInCache]) {
                [toUpdate addObject:user];
            }
        }
        else {
            [toInsert addObject:user];
        }
    }
    
    if (toUpdate.count != 0) {
        [self updateQBUsers:toUpdate inContext:context];
    }
    
    if (toInsert.count != 0) {
        [self insertQBUsers:toInsert inContext:context];
    }
    
    if (toInsert.count + toInsert.count == 0) {
        finish();
    }
    else {
        [self save:finish];
    }
    
    NSLog(@"Users to insert %d", toInsert.count);
    NSLog(@"Users to update %d", toUpdate.count);
}

- (void)insertQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUser *user = [CDUser MR_createEntityInContext:context];
        [user updateWithQBUser:qbUser];
    }
}

- (void)deleteQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUser *userToDelete = [CDUser MR_findFirstWithPredicate:IS(@"id", @(qbUser.ID))
                                                       inContext:context];
        [userToDelete MR_deleteEntityInContext:context];
    }
}

- (void)updateQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUser *userToUpdate = [CDUser MR_findFirstWithPredicate:IS(@"id", @(qbUser.ID))
                                                       inContext:context];
        [userToUpdate updateWithQBUser:qbUser];
    }
}


@end