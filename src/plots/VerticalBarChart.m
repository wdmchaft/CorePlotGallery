//
//  SimpleBarGraph.m
//  CPTestGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//


#import "VerticalBarChart.h"

@implementation VerticalBarChart

+ (void)load
{
	[super registerPlotItem:self];
}

- (id)init
{
	self = [super init];
	
	title = @"Vertical Bar Chart";

	return self;
}


- (void)killGraph
{
	if ([graphs count])
	{		
		CPGraph* graph = [graphs objectAtIndex:0];
		
		if (symbolTextAnnotation)
		{
			[graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
			[symbolTextAnnotation release];
			symbolTextAnnotation = nil;
		}
	}
	
	[super killGraph];
}


- (void)generateData
{
	
}


- (void)renderInLayer:(CPLayerHostingView *)layerHostingView withTheme:(CPTheme*)theme
{
	// Core-Plot view
	CPGraph* graph = [[CPXYGraph alloc] initWithFrame:layerHostingView.bounds];
	[graphs addObject:graph];

	[self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPDarkGradientTheme]];
	
	layerHostingView.hostedLayer = graph;
	graph.title = title;
    CPTextStyle *textStyle = [CPTextStyle textStyle];
    textStyle.color = [CPColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 18.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
    graph.titlePlotAreaFrameAnchor = CPRectAnchorTop;
	
    // Graph padding
    graph.paddingLeft = 60.0;
    graph.paddingTop = 60.0;
    graph.paddingRight = 60.0;
    graph.paddingBottom = 60.0;
	
    // Add plot space for horizontal bar charts
    CPXYPlotSpace *barPlotSpace = [[CPXYPlotSpace alloc] init];
    barPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0f) length:CPDecimalFromFloat(9.0f)];
    barPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-20.0f) length:CPDecimalFromFloat(100.0f)];
	[graph addPlotSpace:barPlotSpace];
    [barPlotSpace release];
    
    // First bar plot
    CPBarPlot *barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor cyanColor] horizontalBars:NO];
	//    barPlot.baseValue = CPDecimalFromString(@"20");
    barPlot.dataSource = self;
    barPlot.barOffset = -0.25f;
    barPlot.identifier = @"Bar Plot 1";
	barPlot.barWidth = 40.0f;
	barPlot.plotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(7.0)];
    CPTextStyle *whiteTextStyle = [CPTextStyle textStyle];
    whiteTextStyle.color = [CPColor whiteColor];
    barPlot.barLabelTextStyle = whiteTextStyle;
	barPlot.delegate = self;
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
}

- (void)dealloc
{
	[plotData release];
	
	[super dealloc];
}

-(CPFill *)barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSUInteger)index
{
	return nil;
}

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index 
{
	return nil;
	
	if ( [(NSString *)plot.identifier isEqualToString:@"Bar Plot 1"]) 
        return (id)[NSNull null];
    else
		return nil; // Use default label style
}


#pragma mark CPBarPlot delegate method

-(void)barPlot:(CPBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
	NSNumber* value = [self numberForPlot:plot field:0 recordIndex:index];
	
	NSLog(@"bar was selected at index %d. Value = %f", (int)index, [value floatValue]);

	CPGraph* graph = [graphs objectAtIndex:0];

	if ( symbolTextAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTextStyle *hitAnnotationTextStyle = [CPTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPColor cyanColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
	
    NSNumber *x = [NSNumber numberWithInt:index];
	NSNumber *y = [NSNumber numberWithInt:-2]; //[self numberForPlot:plot field:0 recordIndex:index];
	NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:value];
    
	
    // Now add the annotation to the plot area
    CPTextLayer *textLayer = [[[CPTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace
															 anchorPlotPoint:anchorPoint];
	symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 0.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}


#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
	return 8;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSNumber* num = [NSDecimalNumber numberWithInt:(index+1)*(index+1)];
    return num;
}

@end