//
//  resizeImage.swift
//  Kingfisher
//
//  Created by amit on 21/04/16.
//  Copyright © 2016 Wei Wang. All rights reserved.
//

import Foundation

func resizeImage(image:UIImage) -> UIImage
{
    var actualHeight:Float = Float(image.size.height)
    var actualWidth:Float = Float(image.size.width)
    
    var maxHeight:Float!
    var maxWidth:Float!
    
    
    
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad
    {
        maxHeight = 1024;
        maxWidth = 768;
    }
    else if (UIScreen.mainScreen().bounds.size.height == 568.0)
    {
        maxHeight = 568;
        maxWidth = 320;
    }
        
    else if (UIScreen.mainScreen().bounds.size.height == 736.0)
    {
        maxHeight = 736;
        maxWidth = 414;
        
    }
    else if (UIScreen.mainScreen().bounds.size.height == 667.0)
    {
        maxHeight = 667;
        maxWidth = 375;
    }
    else
    {
        maxHeight = 480;
        maxWidth = 320;
    }
    
    var imgRatio:Float = actualWidth/actualHeight
    let maxRatio:Float = maxWidth/maxHeight
    
    if (actualHeight > maxHeight) || (actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    let rect:CGRect = CGRectMake(0.0, 0.0, CGFloat(actualWidth) , CGFloat(actualHeight) )
    UIGraphicsBeginImageContext(rect.size)
    image.drawInRect(rect)
    
    let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
    let imageData:NSData = UIImageJPEGRepresentation(img, 1.0)!
    UIGraphicsEndImageContext()
    
    return UIImage(data: imageData)!
    
}


func data_request()
{
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url_to_request)
    request.HTTPMethod = "POST"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    let paramString = "category_id="+category_id
    request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
    let task = session.dataTaskWithRequest(request)
        {(
            
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            do
            {
                self.A_Images_Link = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSMutableDictionary
                print(self.A_Images_Link)
                for var i = 0 ; i < self.A_Images_Link.objectForKey("result")!.count ; i++
                {
                    self.element1.addObject(self.A_Images_Link.objectForKey("result")?.objectAtIndex(i).objectForKey("image1")as! String)
                    
                }
                self.collectionView.reloadData()
            }
            catch
            {}
            self.collectionView.reloadData()
    }
    task.resume()
}

