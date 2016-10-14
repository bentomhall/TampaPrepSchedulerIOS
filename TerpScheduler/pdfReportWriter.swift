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
  case tasksForClass
  case tasksForWeek
}

func getFileNameString(_ type: PDFReportTypes)->URL{
  let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
  var filename: URL
  switch(type){
  case .tasksForClass:
    filename = tempDirectory.appendingPathComponent("class_tasks.pdf")
    break
  case .tasksForWeek:
    filename = tempDirectory.appendingPathComponent("weekly_tasks.pdf")
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
  
  fileprivate var data: PDFDataConvertable
  fileprivate let frame = CGRect(x: 72, y: 72, width: 468, height: 648) //72 point margins
  fileprivate let type: PDFReportTypes
  
  fileprivate func formatHeader()->String {
    return data.headerData+"\n"+"-----------------------------"+"\n"
  }
  
  fileprivate func formatBody()->String {
    var output = [String]()
    for (date, tasks) in data.bodyData {
      output.append(date)
      for task in tasks {
        output.append(task)
      }
    }
    return output.joined(separator: "\n\n")
  }
  
  fileprivate func getText()->CFAttributedString {
    let header = formatHeader()
    let body = formatBody()
    let complete = [header,body].joined(separator: "\n")
    return CFAttributedStringCreate(nil, complete as CFString!, nil)
  }
  
  fileprivate func renderFrame(textRange currentRange: CFRange ,andFormatter formatter: CTFramesetter)->CFRange{
    var range = currentRange
    let currentContext = UIGraphicsGetCurrentContext()
    currentContext!.textMatrix = CGAffineTransform.identity
    let framePath = CGMutablePath()
    framePath.addRect(frame)
    
    let frameRef = CTFramesetterCreateFrame(formatter, currentRange, framePath, nil)
    //invert the context so it draws from top-left down (instead up bottom-left up)
    currentContext?.translateBy(x: 0, y: 792)
    currentContext?.scaleBy(x: 1.0, y: -1.0)
    //draw the current frame
    CTFrameDraw(frameRef, currentContext!)
    
    range = CTFrameGetVisibleStringRange(frameRef)
    range.location += range.length
    range.length = 0
    return range
  }
  
  func render()->URL?{
    let filename = getFileNameString(type)
    let text = getText()
    _ = CFAttributedStringGetLength(text)
    let framesetter = CTFramesetterCreateWithAttributedString(text)
    UIGraphicsBeginPDFContextToFile(filename.path, CGRect.zero, data.metaData)
    var range = CFRangeMake(0, 0)
    var page = 0
    var done = false
    
    repeat {
      UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil)
      page += 1
      range = renderFrame(textRange: range, andFormatter: framesetter)
      if range.location == CFAttributedStringGetLength(text) {
        done = true
      }
    } while(!done)
    
    UIGraphicsEndPDFContext()
    return filename
  }
}
