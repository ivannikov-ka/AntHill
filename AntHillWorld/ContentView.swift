//
//  ContentView.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 27.06.2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.blue)
                .frame(width: UIScreen.width, height: UIScreen.height + 100)
                .opacity(0.5)
                .position(x: UIScreen.width / 2, y: UIScreen.height / 2)
            
            ForEach(viewModel.field.allSmallObjectList) { object in
                object.image
                    .foregroundColor(object.color)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.init(degrees: Double(object.rotationAngle)))
                    .position(object.position)
                    .opacity(object.opacity)
            }
            
            ForEach(viewModel.field.antMarksContainer.antMarks) { antMark in
                antMark.image
                    .foregroundColor(antMark.color)
                    .frame(width: 3, height: 3)
                    .scaleEffect(0.2)
                    .position(antMark.position)
            }
            
            ForEach(viewModel.field.antHill.antsContainer.ants) { ant in
                ZStack {
                    if ant.isSeek {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                            .opacity(0.3)
                    }

                    ant.image
                        .foregroundColor(ant.isSeek ? .red : .black)
                        .frame(width: 10, height: 10)
                        .scaleEffect(ant.antType == .mother ? 1.4 : 1)

                    if let backPlace = ant.backPlace {
                        backPlace.image
                            .foregroundColor(backPlace.color)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                    }
                }
                .opacity(ant.opacity)
                .rotationEffect(.init(degrees: Double(ant.moveAngle) + 90))
                .position(ant.position)
                .onTapGesture {
                    ant.seekTime = ant.seekTime == 0 ? 200 : 0
                }
            }
            
            UserInterface(viewModel: viewModel)
        }
    }
}

struct Vector {
    var x: CGFloat
    var y: CGFloat
    
    init() {
        x = 0
        y = 0
    }
    
    init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    init(_ start: CGPoint, _ end: CGPoint) {
        self.init(end.x - start.x, end.y - start.y)
    }
    
    static func +(first: Vector, second: Vector) -> Vector {
        return Vector(second.x + first.x, second.y + first.y)
    }
    
    static func -(first: Vector, second: Vector) -> Vector {
        return Vector(first.x - second.x, first.y - second.y)
    }
    
    static func *(vector: Vector, k: CGFloat) -> Vector {
        return Vector(vector.x * k, vector.y * k)
    }
    
    static func += (first: inout Vector, second: Vector) {
        first = first + second
    }
    
    static func -= (first: inout Vector, second: Vector) {
        first = first - second
    }
    
    var module: CGFloat {
        return sqrt(x * x + y * y)
    }
    
    var angle: CGFloat {
        if x == 0 {
            if y > 0 {
                return 90
            } else {
                return 270
            }
        }
        if y == 0 {
            if x > 0 {
                return 0
            } else {
                return 180
            }
        }
        
        let arctan = atan(abs(y) / abs(x)).radToDegrees
        
        if x > 0 {
            if y > 0 {
                return arctan
            } else {
                return 360 - arctan
            }
        } else {
            if y > 0 {
                return 180 - arctan
            } else {
                return 180 + arctan
            }
        }
    }
    
    func isNear(with vector: Vector, in degrees: CGFloat) -> Bool {
        if self.angle < vector.angle {
            return vector.angle - self.angle < degrees
        } else {
            return self.angle - vector.angle < degrees
        }
    }
}

extension UIScreen {
   static let width = UIScreen.main.bounds.size.width
   static let height = UIScreen.main.bounds.size.height
   static let size = UIScreen.main.bounds.size
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func random(in range: CGFloat) -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: (self.x - range)...(self.x + range)),
            y: CGFloat.random(in: (self.y - range)...(self.y + range))
        )
    }
    
    var isInBounds: Bool {
        return self.y > 0 && self.x > 0 && self.y < UIScreen.height && self.x < UIScreen.width
    }
}

extension CGFloat {
    var degreesToRad: CGFloat {
        return self * CGFloat.pi / 180
    }
    
    var radToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
    
    var angleValue: CGFloat {
        if self > 360 {
            return CGFloat(Int(self) % 360)
        }
        
        if self < 0 {
            return 360 + self
        }
        
        return self
    }
}

extension Int {
    mutating func countDownToZero() {
        self -= self > 0 ? 1 : 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
