//
//  NSTimeInterval.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import Foundation


public extension NSTimeInterval {
    
    static var day: NSTimeInterval { return self.hour * 24 }
    static var hour: NSTimeInterval { return self.minute * 60 }
    static var minute: NSTimeInterval { return 60 }
    
    var formattedTimeOfDay: String {
        
        var time = self
        
        if time > NSTimeInterval.day {
            let days = (time / NSTimeInterval.day).floor()
            time -= (days * NSTimeInterval.day)
        }
        
        var suffix = "am"
        
        let pmTime = NSTimeInterval.day / 2
        
        if time > pmTime {
            suffix = "pm"
            time -= pmTime
        }
        
        var hoursMinusMinutes = time.hours.floor()
        let minutesMinusHours = time.minutes.floor() - (hoursMinusMinutes * 60)
        
        if hoursMinusMinutes == 0 {
            hoursMinusMinutes = 12
        }
        
        return hoursMinusMinutes.format(1, fractionDigits: 0) + ":" + minutesMinusHours.format(2, fractionDigits: 0) + suffix
    }
    
    var days: Double { return self / NSTimeInterval.day }
    
    var hours : Double { return self / NSTimeInterval.hour }
    
    var minutes : Double { return self / NSTimeInterval.minute }
    
    var shortRoundedString : String {
        
        let durationInSeconds = lround(self);
        var hours = durationInSeconds / 3600;
        let minutes = (durationInSeconds % 3600) / 60;
        let seconds = durationInSeconds % 60;
        
        if hours > 0 {
            
            if hours < 10 {
                return "\(hours).\(minutes%10)h"
            }
            
            if minutes >= 30 {
                hours += 1;
            }
            
            return "\(hours)h"
        }
        else
        {
            if (minutes == 0)
            {
                return "\(seconds)s"
            }
            
            return "\(minutes)m"
        }
    }
    
    var formattedHourMinuteSeconds: String {
        
        if (self < 0) {
            return "00:00";
        }
        
        let durationInSeconds = self.round()
        let hours = Int(durationInSeconds / 3600)
        let minutes = Int((durationInSeconds % 3600) / 60)
        let seconds = Int(durationInSeconds % 60)
        
        let minutesAndSeconds = minutes.format(2) + ":" + seconds.format(2)
        
        if hours > 0 {
            return hours.format(2) + ":" + minutesAndSeconds
        }
        
        return minutesAndSeconds
    }
    
}

/*

    + (NSString *)formattedStringForTimeWithMs:(NSTimeInterval)duration
{
    if (duration < 0)
    {
        return @"00:00.00";
    }
    
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    float milliseconds = duration - floor(duration);
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        //        if (minutes == 0) {
        //            return [NSString stringWithFormat:@":%02d", seconds];
        //        }
        float sec = seconds + milliseconds;
        NSNumberFormatter *numFormatter = [NSNumberFormatter new];
        [numFormatter setMaximumFractionDigits:2];
        [numFormatter setMinimumIntegerDigits:2];
        [numFormatter setMinimumFractionDigits:2];
        return [NSString stringWithFormat:@"%02ld:%@", (long)minutes, [numFormatter stringFromNumber:@(sec)]];
    }
    }
    
    + (NSString *)formattedStringForDuration:(NSTimeInterval)duration
{
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    
    if (hours > 0)
    {
        if (minutes == 0)
        {
            return [NSString stringWithFormat:@"%lih", (long)hours];
        }
        return [NSString stringWithFormat:@"%lih %limin", (long)hours, (long)minutes];
    }
    else
    {
        if (minutes == 0)
        {
            return [NSString stringWithFormat:@"%lisec", (long)seconds];
        }
        
        return [NSString stringWithFormat:@"%limin", (long)minutes];
    }
    }
    
    + (NSString *)formattedDescriptiveStringForDuration:(NSTimeInterval)duration
{
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    
    NSString *hourString = @"hours";
    if (hours == 1)
    {
        hourString = @"hour";
    }
    NSString *minutesString = @"minutes";
    if (minutes == 1)
    {
        minutesString = @"minute";
    }
    NSString *secondsString = @"seconds";
    if (seconds == 1)
    {
        secondsString = @"second";
    }
    
    if (hours > 0)
    {
        if (minutes == 0)
        {
            return [NSString stringWithFormat:@"%li %@", (long)hours, hourString];
        }
        return [NSString stringWithFormat:@"%li %@ %li %@", (long)hours, hourString, (long)minutes, minutesString];
    }
    else
    {
        if (minutes == 0)
        {
            return [NSString stringWithFormat:@"%li %@", (long)seconds, secondsString];
        }
        
        return [NSString stringWithFormat:@"%li %@", (long)minutes, minutesString];
    }
}

*/