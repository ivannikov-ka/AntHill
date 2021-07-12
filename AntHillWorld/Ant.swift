//
//  Ant.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

enum AntType: CaseIterable {
    case mother
    case fighter
    case worker
}

class Ant: GameInstance, Identifiable {
    //GameINstance
    var id = UUID()
    var position: CGPoint
    var liveTime: Int = 5000
    var image: Image {
        if isInCapsule {
            return Image(systemName: "capsule.fill")
        } else {
            return Image(systemName: "ant.fill")
        }
    }
    
    func tick() {
        liveTime -= isSeek ? 8 : isHangry ? 2 : 1
    
        if isDead {
            return
        }
        
        seekTime.countDownToZero()
        imunitetTime.countDownToZero()
        timeToHangry.countDownToZero()
        
        let nearAnts = getNearAnt(inDistance: 15)
        if nearAnts.first(where: {$0.isSeek == true}) != nil {
            trySeek()
        }
        
        if antType == .mother {
            if AntHill.shared.isReadyForMother {
                mother()
            } else {
                move()
                leaveAntMark()
                collectObject()
                putObject()
            }
        } else {
            if !isInCapsule {
                move()
                leaveAntMark()
                eat()
                collectObject()
                putObject()
            }
        }
    }
    
    //Extensions
    var antType: AntType
    var backPlace: SmallObject?
    var moveAngle: CGFloat
    var needLeaveMarks: AntMarkType? = nil
    var needClearMarks: AntMarkType? = nil
    
    //Tick values
    var timeToHangry: Int = 230 + 400
    var seekTime: Int = 0
    var imunitetTime: Int = 0
    
    init(antType: AntType = .worker, position: CGPoint = CGPoint(x: 80, y: 80)) {
        self.position = position
        self.antType = antType
        
        moveAngle = CGFloat.random(in: 0..<360)
    }
    
    //Calculated values
    var speed: CGFloat {
        let realSpeed = CGFloat(sqrt(Double(liveTime)) / sqrt(Double(5000))) * 5
        return isSeek ? realSpeed * 1.3 : realSpeed
    }
    
    var isDead: Bool {
        return liveTime <= 0 && antType != .mother
    }
    
    var isSeek: Bool {
        seekTime > 0
    }
    
    var isHangry: Bool {
        timeToHangry == 0
    }
    
    var isInCapsule: Bool {
        if antType == .mother {
            return false
        }

        return liveTime > 5000 - 230
    }
    
    var opacity: Double {
        if isInCapsule {
            return 0.4
        }
        
        if liveTime > 0 || antType == .mother {
            return 1
        }
        
        return Double(100 + liveTime) / 100
    }
    
    //Methods
    func move() {
        calculateMoveAngle()
        position = getNextPosition(with: moveAngle)
    }
    
    func leaveAntMark() {
        let nearFoodMarks = getNearAntMarks(inDistance: 15, antMarkType: .food)
        
        if let antMarkType = needLeaveMarks {
            if AntHill.shared.position.distance(to: position) > AntHill.shared.radius && nearFoodMarks.count < 10 && speed > 1 {
                Field.shared.leaveAntMark(type: antMarkType, position: position)
            }
        } else if let antMarkType = needClearMarks {
            Field.shared.clearAntMark(type: antMarkType, position: position)
        }
    }
    
    func eat() {
        if isHangry {
            if backPlace?.type == .food {
                timeToHangry = 400
                backPlace = nil
                needLeaveMarks = nil
                needClearMarks = nil
            }
        }
    }
    
    func trySeek() {
        if imunitetTime == 0 {
            seekTime = 350
            imunitetTime = 900
            
            needClearMarks = nil
            needLeaveMarks = nil
            
            backPlace = nil
        }
    }
    
    func mother() {
        if Double.random(in: 0..<1) < 0.0015 * Double(AntHill.shared.sticksContainer.objects.count / 50 + AntHill.shared.smallFoodContainer.objects.count / 5 + 1) {
            Field.shared.antHill.birthAnts()
        }
    }
    
    func putObject() {
        guard let object = backPlace else {
            return
        }
        
        let distanceToAntHill = position.distance(to: AntHill.shared.position)
        if distanceToAntHill < AntHill.shared.radius {
            let putChanse = object.type == .food ? 0.2 : 0.8
            if Double.random(in: 0..<1) < putChanse {
                object.position = position
                object.isActive = false
                AntHill.shared.putSmallObject(object: object)
                backPlace = nil
                needLeaveMarks = nil
                needClearMarks = nil
            }
        }
    }
    
    func collectObject() {
        if backPlace != nil || isSeek {
            return
        }
        
        let nearObjects = getNearSmallObjects(inDistance: 3)
        guard let object = nearObjects.first(where: {$0.isActive == true}) else {
            return
        }
        
        if object.type == .food {
            if Double.random(in: 0...1) < 0.005 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.trySeek()
                }
            }
        }
        
        backPlace = SmallObject(position: object.position, type: object.type)
        Field.shared.removeSmallObject(id: object.id)
        
        if object.type != .food {
            return
        }
        
        if getNearSmallObjects(inDistance: 30, objectType: .food).filter({$0.isActive == true}).count >= 2 {
            needLeaveMarks = .food
        } else {
            needClearMarks = .food
        }
    }
    
    //Environment getters
    func getNearAnt(inDistance: CGFloat) -> [Ant] {
        return Field.shared.allEntityList.filter({
            $0.id != id &&
            $0.liveTime > 0 &&
            type(of: $0) == type(of: Ant()) &&
            ($0 as! Ant).antType != .mother &&
            position.distance(to: $0.position) < inDistance
        }) as! [Ant]
    }
    
    func getNearSmallObjects(inDistance: CGFloat, objectType: SmallObjectType? = nil) -> [SmallObject] {
        return Field.shared.allSmallObjectListFieldContainered.filter({
            ($0.type == objectType || objectType == nil) && position.distance(to: $0.position) < inDistance
        }).sorted(by: {
            $0.position.distance(to: position) < $1.position.distance(to: position)
        })
    }
    
    func getNearAntMarks(inDistance: CGFloat, antMarkType: AntMarkType) -> [AntMark] {
        return Field.shared.allAntMarksList.filter({
            position.distance(to: $0.position) < inDistance && $0.type == antMarkType
        })
    }
    
    //Move calculating
    func calculateMoveAngle() {
        let nearAnts = getNearAnt(inDistance: 100)
        
        if isSeek {
            guard let nearestHealthyAnt = nearAnts
                    .filter({$0.isSeek == false && $0.imunitetTime == 0})
                    .sorted(by: {$0.position.distance(to: position) < $1.position.distance(to: position)})
                    .first
            else {
                calculateRandomMoveAngle()
                return
            }
            
            moveAngle = (Vector(position, nearestHealthyAnt.position).angle + CGFloat.random(in: -5...5)).angleValue
            return
        }
        
        let nearSeekAnts = nearAnts
            .filter({$0.position.distance(to: position) < 50 && $0.isSeek == true})
        
        if !nearSeekAnts.isEmpty {
            needLeaveMarks = nil
            needClearMarks = nil
            //вычисляем лучший вектор движения от всех больных муравьев рядом, находим угол движения
            var preferredVector = Vector()
            nearSeekAnts.forEach { ant in
                let vectorToAnt = Vector(ant.position, position)
                preferredVector += vectorToAnt * (50 / ant.position.distance(to: position))
            }
            let preferredAngle = preferredVector.angle
            
            if getNextPosition(with: preferredAngle).isInBounds {
                moveAngle = preferredVector.angle
                return
            }
            
            //если по этому вектору муравей упрется в края карты, то находим ближайший возможный
            var delta: CGFloat = 0
            repeat {
                delta += 1
                //тут идем по часовой
                if getNextPosition(with: (preferredAngle + delta).angleValue).isInBounds {
                    moveAngle = (preferredVector.angle + delta).angleValue
                    return
                }
                //тут идем против часовой
                if getNextPosition(with: (preferredAngle - delta).angleValue).isInBounds {
                    moveAngle = (preferredVector.angle - delta).angleValue
                    return
                }
            } while true
        }
        
        if imunitetTime > 200 {
            calculateRandomMoveAngle()
            return
        }
        
        if backPlace != nil {
            if backPlace?.type == .food {
                let vector = Vector(position, AntHill.shared.position)
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
            } else {
                let vector = Vector(position, AntHill.shared.position.random(in: AntHill.shared.radius / 2))
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
            }
            
            return
        }
        
        if !AntHill.shared.isReadyForMother {
            let nearSticks = getNearSmallObjects(inDistance: 140, objectType: .stick)
            if let stick = nearSticks.first(where: {$0.isActive == true}) {
                let vector = Vector(position, stick.position)
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
                return
            }
        } else {
            let nearSmallFoodOnSteps = getNearSmallObjects(inDistance: 40, objectType: .food)
            if let smallFood = nearSmallFoodOnSteps.first(where: {$0.isActive == true}) {
                let vector = Vector(position, smallFood.position)
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
                return
            }
            
            let nearFoodMarks = getNearAntMarks(inDistance: 30, antMarkType: .food)
            if let foodAntMark = nearFoodMarks.sorted(by: {$0.liveTime < $1.liveTime}).last(where: {
                Vector(position, $0.position).isNear(with: Vector(position, AntHill.shared.position), in: 90) == false
            }){
                let vector = Vector(position, foodAntMark.position)
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
                return
            }
            
            let nearSmallFood = getNearSmallObjects(inDistance: 180, objectType: .food)
            if let smallFood = nearSmallFood.first(where: {$0.isActive == true}) {
                let vector = Vector(position, smallFood.position)
                moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
                return
            }
            
            if !isHangry {
                let nearSticks = getNearSmallObjects(inDistance: 140, objectType: .stick)
                if let stick = nearSticks.first(where: {$0.isActive == true}) {
                    let vector = Vector(position, stick.position)
                    moveAngle = (vector.angle + CGFloat.random(in: -5..<5)).angleValue
                    return
                }
            }
        }
        
        calculateRandomMoveAngle()
    }
    
    func calculateRandomMoveAngle() {
        repeat {
            moveAngle = (moveAngle + CGFloat.random(in: -25..<25)).angleValue
        } while !getNextPosition(with: moveAngle).isInBounds
    }
    
    func getNextPosition(with angle: CGFloat) -> CGPoint {
        var resultPosition = position
        
        resultPosition.y += sin(angle.degreesToRad) * speed
        resultPosition.x += cos(angle.degreesToRad) * speed
        
        return resultPosition
    }
}

class AntsContiner {
    @Published var ants: [Ant] = []
    
    func tick() {
        ants.forEach { ant in
            ant.tick()
            
            if ant.liveTime < -100 && ant.antType != .mother {
                ants.removeAll(where: {$0.id == ant.id})
            }
        }
    }
}
