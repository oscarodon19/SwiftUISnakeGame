//
//  ContentView.swift
//  SnakeGame
//
//  Created by Oscar Odon on 22/08/2020.
//  Copyright © 2020 Oscar Odon. All rights reserved.
//

import SwiftUI

struct SnakeView: View {
    @State var startPosition : CGPoint = .zero
    @State var isStarted = true
    @State var gameOver = false
    @State var nextDirection = direction.down
    @State var snakeArray = [CGPoint(x: 0, y: 0)]
    @State var foodPosition = CGPoint(x: 0, y: 0)
    let snakeSize : CGFloat = 10
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    func changeRectPos() -> CGPoint {
        let rows = Int(Screen.maxX/snakeSize)
        let cols = Int(Screen.maxY/snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func changeDirection () {
        if self.snakeArray[0].x < Screen.minX || self.snakeArray[0].x > Screen.maxX && !gameOver{
            gameOver.toggle()
        }
        else if self.snakeArray[0].y < Screen.minY || self.snakeArray[0].y > Screen.maxY  && !gameOver {
            gameOver.toggle()
        }
        var prev = snakeArray[0]
        if nextDirection == .down {
            self.snakeArray[0].y += snakeSize
        } else if nextDirection == .up {
            self.snakeArray[0].y -= snakeSize
        } else if nextDirection == .left {
            self.snakeArray[0].x += snakeSize
        } else {
            self.snakeArray[0].x -= snakeSize
        }
        
        for index in 1..<snakeArray.count {
            let current = snakeArray[index]
            snakeArray[index] = prev
            prev = current
        }
    }
    
    var body: some View {
        ZStack {
            Color.primary
            ZStack {
                ForEach (0..<snakeArray.count, id: \.self) { index in
                    Rectangle()
                        .fill(Color(UIColor.systemBlue))
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.snakeArray[index])
                }
                Rectangle()
                    .fill(Color(UIColor.systemRed))
                    .frame(width: snakeSize, height: snakeSize)
                    .position(foodPosition)
            }
            .onAppear() {
                self.foodPosition = self.changeRectPos()
                self.snakeArray[0] = self.changeRectPos()
            }
            
            if self.gameOver {
                Text("Game Over ☹️")
                    .foregroundColor(Color(UIColor.systemBlue))
                    .font(.system(size: 30, weight: .bold, design: .default))
            }
        }
        .gesture(DragGesture()
        .onChanged { gesture in
            if self.isStarted {
                self.startPosition = gesture.location
                self.isStarted.toggle()
            }
        }
        .onEnded {  gesture in
            let xDist =  abs(gesture.location.x - self.startPosition.x)
            let yDist =  abs(gesture.location.y - self.startPosition.y)
            if self.startPosition.y <  gesture.location.y && yDist > xDist {
                self.nextDirection = direction.down
            }
            else if self.startPosition.y >  gesture.location.y && yDist > xDist {
                self.nextDirection = direction.up
            }
            else if self.startPosition.x > gesture.location.x && yDist < xDist {
                self.nextDirection = direction.right
            }
            else if self.startPosition.x < gesture.location.x && yDist < xDist {
                self.nextDirection = direction.left
            }
            self.isStarted.toggle()
            }
        )
        .onReceive(timer) { (_) in
          if !self.gameOver {
               self.changeDirection()
               if self.snakeArray[0] == self.foodPosition {
                    self.snakeArray.append(self.snakeArray[0])
                     self.foodPosition = self.changeRectPos()
                }
          }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SnakeView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeView()
    }
}
