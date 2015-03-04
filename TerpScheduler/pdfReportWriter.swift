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

protocol PDFDataConvertable {
  var metaData: [String: String] { get } //key-value dictionary, same for all pages
  var headerData: String { get } // String to write at the top of the document
  var bodyData: [String: [String]] { get } //dictionary of constant information (class, date): list of variable data (tasks)]
}

class PDFReporter {
  init(data: PDFDataConvertable, ofType type:PDFReportTypes){
    self.data = data
    self.type = type
  }
  
  private var data: PDFDataConvertable
  private let frame = CGRectMake(72, 72, 468, 468) //72 point margins
  private let type: PDFReportTypes
  
  private func formatHeader()->String {
    return data.headerData
  }
  
  private func formatBody()->String {
    var output = [String]()
    for (date, tasks) in data.bodyData {
      output.append(date)
      for task in tasks {
        output.append(task)
      }
    }
    return "\n".join(output)
  }
  
  private func getText()->CFAttributedStringRef {
    let header = formatHeader()
    let body = formatBody()
    let complete = "\n".join([header,body])
    return CFAttributedStringCreate(nil, complete, nil)
  }
  
  private func renderFrame(textRange currentRange: CFRange ,andFormatter formatter: CTFramesetterRef)->CFRange{
    var range = currentRange
    let currentContext = UIGraphicsGetCurrentContext()
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
    var framePath = CGPathCreateMutable()
    CGPathAddRect(framePath, nil, frame)
    
    let frameRef = CTFramesetterCreateFrame(formatter, currentRange, framePath, nil)
    //invert the context so it draws from top-left down (instead up bottom-left up)
    CGContextTranslateCTM(currentContext, 0, 792)
    CGContextScaleCTM(currentContext, 1.0, -1.0)
    //draw the current frame
    CTFrameDraw(frameRef, currentContext)
    range.location += currentRange.length
    range.length = 0
    return range
  }
  
  func render()->NSURL?{
    let filename = getFileNameString(type)
    let text = getText()
    var framesetter = CTFramesetterCreateWithAttributedString(text)
    UIGraphicsBeginPDFContextToFile(filename, CGRectZero, data.metaData)
    var range = CFRangeMake(0, 0)
    var page = 0
    var done = false
    
    do {
      UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil)
      page += 1
      range = renderFrame(textRange: range, andFormatter: framesetter)
      if range.location == CFAttributedStringGetLength(text) {
        done = true
      }
    } while(!done)
    
    UIGraphicsEndPDFContext()
    return NSURL(fileURLWithPath: filename)
  }
}