//
//  CompanionshipCell.h
//  LDSHelper
//
//  Created by Eric Pena on 9/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface CompanionshipCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageLeft;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageRight;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabelLeft;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabelRight;
@property (weak, nonatomic) IBOutlet UILabel *nameLabelLeft;
@property (weak, nonatomic) IBOutlet UILabel *nameLableRight;

@end
