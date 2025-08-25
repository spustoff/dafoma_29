//
//  GestureType.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import Foundation
import SwiftUI

enum GestureType: String, CaseIterable, Identifiable, Codable {
    case tap = "tap"
    case doubleTap = "double_tap"
    case longPress = "long_press"
    case swipeUp = "swipe_up"
    case swipeDown = "swipe_down"
    case swipeLeft = "swipe_left"
    case swipeRight = "swipe_right"
    case pinch = "pinch"
    case rotate = "rotate"
    case drag = "drag"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tap:
            return "Tap"
        case .doubleTap:
            return "Double Tap"
        case .longPress:
            return "Long Press"
        case .swipeUp:
            return "Swipe Up"
        case .swipeDown:
            return "Swipe Down"
        case .swipeLeft:
            return "Swipe Left"
        case .swipeRight:
            return "Swipe Right"
        case .pinch:
            return "Pinch"
        case .rotate:
            return "Rotate"
        case .drag:
            return "Drag"
        }
    }
    
    var icon: String {
        switch self {
        case .tap:
            return "hand.tap"
        case .doubleTap:
            return "hand.tap.fill"
        case .longPress:
            return "hand.point.up"
        case .swipeUp:
            return "arrow.up"
        case .swipeDown:
            return "arrow.down"
        case .swipeLeft:
            return "arrow.left"
        case .swipeRight:
            return "arrow.right"
        case .pinch:
            return "hand.pinch"
        case .rotate:
            return "rotate.3d"
        case .drag:
            return "hand.draw"
        }
    }
    
    var difficulty: Int {
        switch self {
        case .tap, .doubleTap:
            return 1
        case .longPress, .swipeUp, .swipeDown, .swipeLeft, .swipeRight:
            return 2
        case .drag, .pinch:
            return 3
        case .rotate:
            return 4
        }
    }
    
    var color: Color {
        switch self {
        case .tap, .doubleTap:
            return Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
        case .longPress, .swipeUp, .swipeDown:
            return Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
        case .swipeLeft, .swipeRight:
            return Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
        case .drag, .pinch:
            return Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
        case .rotate:
            return Color(red: 0.83, green: 0.0, blue: 0.93) // #d300ee
        }
    }
}

struct GestureChallenge: Identifiable, Codable {
    let id = UUID()
    let gestureType: GestureType
    let targetCount: Int
    let timeLimit: Double
    let level: Int
    var isCompleted: Bool = false
    var completionTime: Double?
    var accuracy: Double?
    
    init(gestureType: GestureType, targetCount: Int, timeLimit: Double, level: Int) {
        self.gestureType = gestureType
        self.targetCount = targetCount
        self.timeLimit = timeLimit
        self.level = level
    }
}
