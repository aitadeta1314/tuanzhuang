//
//  CustomCollectionFlowLayout.m
//  customCollectionLayout
//
//  Created by zhang gaotang on 2018/1/10.
//  Copyright © 2018年 zhang gaotang. All rights reserved.
//

#import "CustomCollectionFlowLayout.h"
#import "DeviderLineDecorationView.h"

#define COLLECITON_CONTENT_WIDTH self.collectionView.bounds.size.width

@interface CustomCollectionFlowLayout()

@property(nonatomic,strong) NSMutableArray *layoutAttributes;

@end

@implementation CustomCollectionFlowLayout

-(instancetype)init{
    
    self = [super init];
    
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.headerAlignTop = NO;

        [self registerClass:[DeviderLineDecorationView class] forDecorationViewOfKind:NSStringFromClass([DeviderLineDecorationView class])];
    }
    
    return self;
    
}

-(void)prepareLayout{
    [super prepareLayout];
    
    self.layoutAttributes = [NSMutableArray array];
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (int i=0; i<sectionCount; i++) {
        NSInteger count = [self.collectionView numberOfItemsInSection:i];
        
        for (int j=0; j<count; j++) {
            
            //add all cell layout attributes
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.layoutAttributes addObject:attr];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        
        //add all section line layout attributes
        UICollectionViewLayoutAttributes *decorationAttr = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([DeviderLineDecorationView class]) atIndexPath:indexPath];
        
        [self.layoutAttributes addObject:decorationAttr];
        
        //add all section header layout attributes
        UICollectionViewLayoutAttributes *headerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        [self.layoutAttributes addObject:headerAttr];
    }
}

-(CGSize)collectionViewContentSize{

    NSInteger numberSection = [self.collectionView numberOfSections];
    CGFloat height = [self getTotalHeightAtSection:(numberSection-1)] + self.collectionView.contentInset.bottom;
    
    return CGSizeMake(COLLECITON_CONTENT_WIDTH, height);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

    return self.layoutAttributes;

}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect frame = attributes.frame;
    
    CGPoint originPoint = [self getCellPointAtIndexPath:indexPath];
    
    attributes.frame = CGRectMake(originPoint.x, originPoint.y, CGRectGetWidth(frame), CGRectGetHeight(frame));
    
    return attributes;
}


- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0 && elementKind == UICollectionElementKindSectionHeader) {
        UICollectionViewLayoutAttributes *attr = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
        
        CGPoint point = [self getHeaderPointAtSection:indexPath.section];
        
        attr.frame = CGRectMake(point.x, point.y, self.headerReferenceSize.width, self.headerReferenceSize.height);
        
        return attr;
    }
    
    return nil;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:NSStringFromClass([DeviderLineDecorationView class]) withIndexPath:indexPath];
        
        NSInteger lastSection = [self.collectionView numberOfSections] - 1;
        
        if (indexPath.section == lastSection) {
            attr.frame = CGRectZero;
        }else{
            CGFloat sectionPositionMaxY =  [self getTotalHeightAtSection:indexPath.section];
            
            CGFloat paddingLeft = self.sectionInset.left + self.collectionView.contentInset.left;
            CGFloat paddingRight = self.sectionInset.right + self.collectionView.contentInset.right;
            
            CGFloat width = COLLECITON_CONTENT_WIDTH - paddingLeft -paddingRight;
            
            attr.frame = CGRectMake(paddingLeft, sectionPositionMaxY, width, 1.0);
        }
        
        return attr;
    }
    
    return nil;
}


#pragma mark - Cell Location Methods

-(CGPoint)getCellPointAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger rowIndex = [self getRowIndexAtIndexPath:indexPath];
    NSInteger columnIndex = [self getColumnIndexAtIndexPath:indexPath];
    
    
    CGFloat paddingTop = self.sectionInset.top;
    
    if (indexPath.section>0) {
        paddingTop += [self getTotalHeightAtSection:(indexPath.section-1)];
    }else{
        paddingTop += self.collectionView.contentInset.top;
    }
    
    CGFloat paddingLeft = self.sectionInset.left
                            + self.collectionView.contentInset.left
                            + self.headerReferenceSize.width
                            + self.headerSpacing;
    
    CGFloat positionX = (columnIndex * self.itemSize.width) + (columnIndex * self.minimumInteritemSpacing);
    CGFloat positionY = (rowIndex * self.itemSize.height) + (rowIndex * self.minimumLineSpacing);
    
    
    return CGPointMake(positionX + paddingLeft, positionY + paddingTop);
}

/**
 * 获取CELL元素所在的显示行
 * 从0开始作为第一行
 */
-(NSInteger)getRowIndexAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSInteger columns = [self getTotalColumns];
    NSInteger row = indexPath.item / columns;
    
    return row;
}

/**
 * 获取CELL元素所在的显示列
 * 从0开始作为第一列
 */
-(NSInteger)getColumnIndexAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger columns = [self getTotalColumns];
    
    NSInteger columnIndex = indexPath.item%columns;
    
    return columnIndex;
}

/**
 * 每行可以显示的元素数
 */
-(NSInteger)getTotalColumns{
    
    CGFloat contentWidth = COLLECITON_CONTENT_WIDTH
                            - self.sectionInset.left
                            - self.sectionInset.right
                            - self.headerReferenceSize.width
                            - self.headerSpacing;
    
    CGFloat itemWidth = self.itemSize.width+self.minimumInteritemSpacing;
    
    NSInteger count = contentWidth/itemWidth;
    
    CGFloat otherWidth = contentWidth - (count*itemWidth);
    
    if (otherWidth>=self.itemSize.width) {
        count++;
    }
    
    return count;
    
}

/**
 * 获取指定section的frame的高度
 **/
-(CGFloat)getTotalHeightAtSection:(NSInteger)section{
    
    CGFloat sectionHeight = [self getSectionHeight:section];
    
    CGFloat preSectionHeight = 0.0;
    
    if (section > 0) {
        preSectionHeight = [self getTotalHeightAtSection:(section-1)];
        sectionHeight += preSectionHeight;
    }else{
        preSectionHeight = self.collectionView.contentInset.top;
    }
    
    return sectionHeight;
}

-(CGFloat)getSectionHeight:(NSInteger)section{
    
    NSInteger lastItemIndex = [self.collectionView numberOfItemsInSection:section] - 1;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:lastItemIndex inSection:section];
    
    NSInteger lastRowIndex = [self getRowIndexAtIndexPath:indexPath];
    
    CGFloat sectionHeight = (lastRowIndex+1) * self.itemSize.height
                            + self.minimumLineSpacing * lastRowIndex
                            + self.sectionInset.top
                            + self.sectionInset.bottom;
    
    return sectionHeight;
}


#pragma mark - Header View Location Methods
-(CGPoint)getHeaderPointAtSection:(NSInteger)section{
    
    CGFloat positionY = self.sectionInset.top;
    CGFloat positionX = self.collectionView.contentInset.left + self.sectionInset.left;
    
    if (section>0) {
        positionY += [self getTotalHeightAtSection:(section-1)];
    }else{
        positionY += self.collectionView.contentInset.top;
    }
    
    if (!self.headerAlignTop) {
        //header view 垂直居中对齐
        CGFloat sectionHeight = [self getSectionHeight:section];
        
        CGFloat diff = (sectionHeight - self.sectionInset.top - self.sectionInset.bottom)/2 - self.headerReferenceSize.height/2;
        
        positionY += diff;
    }
    
    return CGPointMake(positionX, positionY);
}

@end
