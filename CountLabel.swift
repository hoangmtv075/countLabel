//
//  CountLabel.swift
//  Label Anim
//
//  Created by Thanh Hoang on 5/4/24.
//

import UIKit

class CountLabel: UILabel {
    
    //MARK: - Properties
    enum CounterAnimationType {
        case Linear
        case EaseIn
        case EaseOut
    }
    
    enum CounterType {
        case Int
        case Float
    }
    
    private let velocity: Float = 3.0
    private var startNumber: Float = 0.0
    private var endNumber: Float = 0.0
    
    private var progress: TimeInterval!
    private var duration: TimeInterval!
    private var lastUpdate: TimeInterval!
    
    private var timer: Timer?
    
    private var counterType: CounterType!
    private var animationType: CounterAnimationType!
    
    private var currentCounterValue: Float {
        if progress >= duration {
            return endNumber
        }
        
        let percentage = Float(progress/duration)
        let update = updateCounter(percentage)
        
        return startNumber + (update * (endNumber - startNumber))
    }
    
    //MARK: - Initialized
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension CountLabel {
    
    func setupCount(from: Float, to: Float, dur: TimeInterval, animType: CounterAnimationType, cType: CounterType) {
        startNumber = from
        endNumber = to
        duration = dur
        animationType = animType
        counterType = cType
        progress = 0.0
        lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        
        if dur == 0.0 {
            updateText(to)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
    }
    
    @objc private func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration {
            progress = duration
        }
        
        updateText(currentCounterValue)
    }
    
    private func updateText(_ to: Float) {
        let f = NumberFormatter()
        f.groupingSeparator = "."
        f.numberStyle = .decimal
        
        switch counterType {
        case .Int:
            text = newText(to)
            break
        case .Float:
            text = String(format: "%.2f", to)
            break
        default:
            break
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCounter(_ percentage: Float) -> Float {
        switch animationType {
        case .Linear: return percentage
        case .EaseIn: return pow(percentage, velocity)
        case .EaseOut: return 1 - pow(1-percentage, velocity)
        default: return 0.0
        }
    }
}

public func newText(_ number: Float) -> String {
    var text: String {
        if number > 9_999 && number < 999_999 {
            return String(format: "%0.1f K", locale: .current, number/1_000)
                .replacingOccurrences(of: ",0", with: "")
        }
        
        if number > 999_999 {
            return String(format: "%0.1f M", locale: .current, number/1_000_000)
                .replacingOccurrences(of: ",0", with: "")
        }
        
        return String(format: "%0.0f", locale: .current, number)
    }
    
    return text
}
