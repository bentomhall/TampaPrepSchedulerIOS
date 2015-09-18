//
//  pdfReportWriter.swift
//  TerpScheduler
//
//  Created by Ben Hall on 2/28/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit

enum PDFReportTypes {
  case TasksForClass
  case TasksForWeek
}

func getFileNameString(type: PDFReportTypes)->String{
  let tempDirectory = NSTemporaryDirectory()
  var filename: String
  switch(type){
  case .TasksForClass:
    filename = tempDirectory.stringByAppendingPathComponent("class_tasks.pdf")
    break
  case .TasksForWeek:
    filename = tempDirectory.stringByAppendingPathComponent("weekly_tasks.pdf")
    break
  }
  return filename
}

struct PDFDataConvertable {
  var metaData: [String: String] //key-value dictionary, same for all pages
  var headerData: String // String to write at the top of the document
  var bodyData: [String: [String]]  //dictionary of constant information (class, date): list of variable data (tasks)]
}

class PDFReporter {
  init(data: PDFDataConvertable, ofType type:PDFReportTypes){
    self.data = data
    self.type = type
  }
  
  private var data: PDFDataConvertable
  private let frame = CGRectMake(72, 72, 468, 648) //72 point margins
  private let type: PDFReportTypes
  
  private func formatHeader()->String {
    return data.headerData+"\n"+"-----------------------------"+"\n"
  }
  
  private func formatBody()->String {
    var output = [String]()
    for (date, tasks) in data.bodyData {
      output.append(date)
      for task in tasks {
        output.append(task)
      }
    }
    return output.joinWithSeparator("\n\n")
  }
  
  private func getText()->CFAttributedStringRef {
    let header = formatHeader()
    let body = formatBody()
    let complete = [header,body].joinWithSeparator("\n")
    return CFAttributedStringCreate(nil, complete, nil)
  }
  
  private func renderFrame(textRange currentRange: CFRange ,andFormatter formatter: CTFramesetterRef)->CFRange{
    var range = currentRange
    let currentContext = UIGraphicsGetCurrentContext()
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
    let framePath = CGPathCreateMutable()
    CGPathAddRect(framePath, nil, frame)
    
    let frameRef = CTFramesetterCreateFrame(formatter, currentRange, framePath, nil)
    //invert the context so it draws from top-left down (instead up bottom-left up)
    CGContextTranslateCTM(currentContext, 0, 792)
    CGContextScaleCTM(currentContext, 1.0, -1.0)
    //draw the current frame
    CTFrameDraw(frameRef, currentContext)
    
    range = CTFrameGetVisibleStringRange(frameRef)
    range.location += range.length
    range.length = 0
    return range
  }
  
  func render()->NSURL?{
    let filename = getFileNameString(type)
    let text = getText()
    let l = CFAttributedStringGetLength(text)
    let framesetter = CTFramesetterCreateWithAttributedString(text)
    UIGraphicsBeginPDFContextToFile(filename, CGRectZero, data.metaData)
    var range = CFRangeMake(0, 0)
    var page = 0
    var done = false
    
    repeat {
      UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil)
      page += 1
      range = renderFrame(textRange: range, andFormatter: framesetter)
      if range.location == CFAttributedStringGetLength(text) {
        done = true
      }
    } while(!done)
    
    UIGraphicsEndPDFContext()
    let url = NSURL(fileURLWithPath: filename)
    return url
  }
}