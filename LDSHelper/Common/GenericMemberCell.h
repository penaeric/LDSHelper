//
//  GenericMemberCell.h
//  LDSHelper
//
//  Created by Eric Pena on 9/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface GenericMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;

@end
