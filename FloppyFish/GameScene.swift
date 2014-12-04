//
//  GameScene.swift
//  RunJumpGame
//
//  Created by Lart Ace Ignacio on 11/27/14.
//  Copyright (c) 2014 Ace Ignacio. All rights reserved.
//

import SpriteKit

// Game States
enum FSGameState: Int {
    case FSGameStateStarting
    case FSGameStatePlaying
    case FSGameStateEnded
}

// Fish
var fish:SKSpriteNode                             = SKSpriteNode()

// Background
let background:SKNode                             = SKNode()
let defaultBackgroundSpeed: CGFloat               = 100.0
let defaultBackgroundSpeedIncrementValue: CGFloat = 3.0
var backround_speed: CGFloat                      = defaultBackgroundSpeed

// Time Values
var delta:NSTimeInterval                          = NSTimeInterval(0)
var last_update_time:NSTimeInterval               = NSTimeInterval(0)

// Score
var score:Int                                     = 0
var label_score:SKLabelNode                       = SKLabelNode()
var label_highScore:SKLabelNode                   = SKLabelNode()

// GameOver
var gameOverLabel                                 = SKLabelNode()

// Floor height
let floor_distance:CGFloat                        = 30.0

// Crabs Origin
let crab_origin_x:CGFloat                         = 682.0

// Whale Origin
let whale_origin_x:CGFloat                        = 600.0

// Boat Origin
let boat_origin_x:CGFloat                         = 625.0

// Ring Origin
let coin_origin_x:CGFloat                         = 600.0

// Instructions
var instructions:SKSpriteNode                     = SKSpriteNode()

// Physics Categories
let FSBoundaryCategory:UInt32                     = 1 //<< 0
let FSPlayerCategory:UInt32                       = 2 //<< 1
let FSCrabCategory:UInt32                         = 4 //<< 2
let FSWhaleCategory:UInt32                        = 8 //<< 3
let FSCoinCategory:UInt32                         = 16 //<< 4
let FSBoatCategory:UInt32                         = 32 //<< 5
let FSSharkCategory:UInt32                        = 64 //<< 6

// Touch Count
var touchCount: Int                               = 0
var isTouching: Bool                              = false

let screenSize: CGRect                            = UIScreen.mainScreen().bounds

var state:FSGameState                             = .FSGameStateStarting

let coinheight:CGFloat                            = 30
let coinWidth:CGFloat                             = 10
let bonusCoinCount                                = 8

// GameOver Message
let boatGameOverMessage                           = "You've been caught by the fisher man!"
let crabGameOverMessage                           = "You've been sipit by a crab!"
let whaleGameOverMessage                          = "You've been bump into a whale!"
let sharkGameOverMessage                          = "You've been hit and run by a shark!"
let defaultGameOverMessage                        = "Game Over!"

// Generators key
let crabGenerator                                 = "crabsGenerator"
let coinGenerator                                 = "coinsGenerator"
let bonusCoinGenerator                            = "bonusCoinsGenerator"
let whaleGenerator                                = "whalesGenerator"
let sharkGenerator                                = "sharksGenerator"
let bubbleGenerator                               = "bubblesGenerator"
let boatGenerator                                 = "boatsGenerator"

// Waiting Duration
let crabGeneratorWaitDuration                     = 5.0
let coinGeneratorWaitDuration                     = 3.0
let bonusGeneratorWaitDuration                    = 20.0
let whaleGeneratorWaitDuration                    = 10.0
let sharkGeneratorWaitDuration                    = 15.0
let bubbleGeneratorWaitDuration                   = 7.0
let boatGeneratorWaitDuration                     = 5.0

// Image Name
let fishImage                                     = "fish"
let boatImage                                     = "boat"
let crabImage                                     = "crab"
let bubbleImage                                   = "bubble"
let bgImage                                       = "bg.jpg"
let whaleImage                                    = "whale"
let coinImage                                     = "coin"
let startImage                                    = "start_image"
let sharkImage                                    = "shark"

// Font name
let fontName                                      = "MarkerFelt-Wide"
let gameOverFontName                              = "Chalkduster"

// NSUserDefaultsKey
let userDefaultsHighScoreKey                      = "highScore"

// Name
let bgName                                        = "bg"

// Fish 
var fishImpulse                                   = CGVectorMake(0, screenSize.height * 0.005)

// #pragma mark - Math functions
extension Float {
    static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if(value > max) {
            return max
        } else if(value < min) {
            return min
        } else {
            return value
        }
    }
    
    static func range(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        if screenSize.height >= 414.0 {
            fishImpulse = CGVectorMake(0, 350)
        }
        
        self.initWorld()
        self.initFish()
        self.initBackground()
        self.initScoreLabel()
        self.initHighScoreLabel()
        self.initInstructions()
    }
    
// MARK: - Initializers
    func initFish() {
        fish = SKSpriteNode(imageNamed: fishImage)
        fish.position = CGPointMake(100, CGRectGetMidY(self.frame))
        
        fish.physicsBody = SKPhysicsBody(texture: fish.texture, size: fish.size)
        
        fish.physicsBody?.categoryBitMask = FSPlayerCategory
        fish.physicsBody?.contactTestBitMask = FSCrabCategory | FSCoinCategory | FSBoundaryCategory | FSWhaleCategory | FSSharkCategory
        fish.physicsBody?.collisionBitMask = FSCrabCategory | FSBoundaryCategory | FSWhaleCategory | FSSharkCategory
        fish.physicsBody?.restitution = 0.0
        fish.physicsBody?.allowsRotation = false
        fish.zPosition = 100
        
        self.addChild(fish)
    }
    
    func initCoins() {
        var coin:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(coinWidth, coinheight))
        coin = SKSpriteNode(imageNamed: coinImage)
        coin.position = self.convertPoint(CGPointMake(Float.range(coin_origin_x, max: coin_origin_x + 100), floor_distance + Float.range(50, max: screenSize.height - coin.size.height)), toNode: background)
        
//        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody = SKPhysicsBody(texture: coin.texture, size: coin.size)
        coin.physicsBody?.categoryBitMask = FSCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.dynamic = false
        coin.zPosition = 10
        
        coin.runAction(self.spinAnimation())
        
        background.addChild(coin)
    }
    
    func initBonusCoins() {
        var bonusCoinY = floor_distance + 100
        
        for var i: Int = 0; i < bonusCoinCount; i++ {
            var coin:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
            coin = SKSpriteNode(imageNamed: coinImage)
            
            bonusCoinY = self.getNextYPosition(bonusCoinY)
            
            coin.position = self.convertPoint(CGPointMake(coin_origin_x + coin.frame.width * CGFloat(i), bonusCoinY), toNode: background)
            
            coin.physicsBody = SKPhysicsBody(texture: coin.texture, size: coin.size)
            coin.physicsBody?.categoryBitMask = FSCoinCategory
            coin.physicsBody?.contactTestBitMask = FSPlayerCategory
            coin.physicsBody?.collisionBitMask = 0
            coin.physicsBody?.dynamic = false
            coin.zPosition = 10
            
            coin.runAction(self.spinAnimation())
            
            background.addChild(coin)
        }
    }
    
    func initCrabs() {
        var crab:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
        crab = SKSpriteNode(imageNamed: crabImage)
        crab.position = self.convertPoint(CGPointMake(Float.range(crab_origin_x, max: crab_origin_x + 500), floor_distance + 20), toNode: background)
        
        crab.physicsBody = SKPhysicsBody(texture: crab.texture, size: crab.size)
        crab.physicsBody?.categoryBitMask = FSCrabCategory
        crab.physicsBody?.contactTestBitMask = FSPlayerCategory
        crab.physicsBody?.collisionBitMask = FSPlayerCategory
        crab.physicsBody?.dynamic = false
        crab.zPosition = 20
        
        crab.runAction(self.crabAnimation(crab.position))
        
        background.addChild(crab)
    }
    
    func initWhale() {
        var whale:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
        whale = SKSpriteNode(imageNamed: whaleImage)
        whale.position = self.convertPoint(CGPointMake(Float.range(whale_origin_x, max: whale_origin_x + 500), Float.range(floor_distance, max: floor_distance + 220)), toNode: background)
        
        whale.physicsBody = SKPhysicsBody(texture: whale.texture, size: whale.size)
        
        whale.physicsBody?.categoryBitMask = FSWhaleCategory
        whale.physicsBody?.contactTestBitMask = FSPlayerCategory
        whale.physicsBody?.collisionBitMask = FSPlayerCategory
        whale.physicsBody?.dynamic = false
        whale.zPosition = 21
        
        whale.runAction(self.whaleSwimAnimation())
        
        background.addChild(whale)
    }
    
    func initShark() {
        var shark:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
        shark = SKSpriteNode(imageNamed: sharkImage)
        shark.position = self.convertPoint(CGPointMake(Float.range(whale_origin_x, max: whale_origin_x + 500), Float.range(floor_distance, max: floor_distance + 220)), toNode: background)
        
        shark.physicsBody = SKPhysicsBody(texture: shark.texture, size: shark.size)
        
        shark.physicsBody?.categoryBitMask = FSSharkCategory
        shark.physicsBody?.contactTestBitMask = FSPlayerCategory
        shark.physicsBody?.collisionBitMask = FSPlayerCategory
        shark.physicsBody?.dynamic = false
        shark.zPosition = 21
        
        shark.runAction(self.moveToTheLeftAnimation(shark.position))
        
        background.addChild(shark)
    }

    
    func initBoat() {
        var boat:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(20, 20))
        boat = SKSpriteNode(imageNamed: boatImage)
        boat.position = self.convertPoint(CGPointMake(Float.range(boat_origin_x, max: boat_origin_x + 500), CGRectGetMaxY(screenSize) + boat.size.height / 3), toNode: background)
        
        boat.physicsBody = SKPhysicsBody(texture: boat.texture, size: boat.size)
        
        boat.physicsBody?.categoryBitMask = FSBoatCategory
        boat.physicsBody?.contactTestBitMask = FSPlayerCategory
        boat.physicsBody?.collisionBitMask = FSPlayerCategory
        boat.physicsBody?.dynamic = false
        boat.zPosition = 20
        
        background.addChild(boat)
    }
    
    func initWorld() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0, floor_distance, self.size.width, self.size.height - floor_distance))
        
        self.physicsBody?.categoryBitMask = FSBoundaryCategory
        self.physicsBody?.collisionBitMask = FSPlayerCategory
    }
    
    func initScoreLabel() {
        label_score = SKLabelNode(fontNamed: fontName)
        label_score.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 100)
        label_score.text = "0"
        label_score.fontColor = UIColor .blackColor()
        label_score.zPosition = 50
        
        self.addChild(label_score)
    }
    
    func initHighScoreLabel() {
        let topScore : Int = self.getTopScore()
        
        label_highScore = SKLabelNode(fontNamed: fontName)
        
        label_highScore.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 30)
        label_highScore.text = "Top Score : " + (topScore as NSNumber).stringValue
        label_highScore.fontColor = UIColor .whiteColor()
        label_highScore.fontSize = 10
        label_highScore.zPosition = 50
        
        self.addChild(label_highScore)
    }
    
    func initInstructions() {
        instructions = SKSpriteNode(imageNamed: startImage)
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 10)
        instructions.zPosition = 50
        self.addChild(instructions)
    }
    
    func initBackground() {
        self.addChild(background)
        
        for var i: Int = 0; i < 2; i++ {
            let tile = SKSpriteNode(imageNamed: bgImage)
            tile.setScale(2.0)
            tile.anchorPoint = CGPointZero
            tile.position = CGPointMake(CGFloat(i) * 710, 0)
            tile.name = bgName
            tile.zPosition = 10
            background.addChild(tile)
        }
    }
    
    func initBubble() {
        var bubble:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(5, 50))
        bubble = SKSpriteNode(imageNamed: bubbleImage)
        bubble.position = self.convertPoint(CGPointMake(700, floor_distance), toNode: background)
        
        bubble.zPosition = 30
        
        bubble.runAction(self.goingUpAnumation())
        
        background.addChild(bubble)
    }
    
    func initGameOver(message: NSString) {
        gameOverLabel = SKLabelNode(fontNamed:gameOverFontName)
        gameOverLabel.text = message
        gameOverLabel.fontSize = 25
        gameOverLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        gameOverLabel.zPosition = 101
        
        self.addChild(gameOverLabel)
    }

// MARK: - Private Methods
    func getTopScore() -> Int {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        
        var topScore = userDefaults.objectForKey(userDefaultsHighScoreKey) as? Int
        
        if topScore == nil {
            topScore = 0
        }
        
        return topScore!
    }
    
    func setTopScore(newScore: Int) {
        var topScore = self.getTopScore()
        
        if (newScore > topScore) {
            NSUserDefaults.standardUserDefaults().setObject(newScore, forKey: userDefaultsHighScoreKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func getNextYPosition(posY: CGFloat) -> CGFloat {
        var isGoingUp = Int(arc4random_uniform(2))
        
        if posY + coinheight > screenSize.height {
            isGoingUp = 0
        }
        
        if posY - coinheight <= floor_distance {
            isGoingUp = 1
        }
    
        var newPosY:CGFloat = 0
        
        if isGoingUp == 1 {
            newPosY = posY + coinheight
        } else {
            newPosY = posY - coinheight
        }
    
        return newPosY
    }
    
    func getGameOverMessage(collisionType: UInt32) -> NSString {
        
        switch collisionType {
            
        case FSBoatCategory:
            return boatGameOverMessage

        case FSCrabCategory:
            return crabGameOverMessage
            
        case FSWhaleCategory:
            return whaleGameOverMessage
            
        case FSSharkCategory:
            return sharkGameOverMessage
            
            
        default:
            return defaultGameOverMessage
            
        }
    }
    
    func gameOver(collisionType: UInt32) {
        state = .FSGameStateEnded
        
        self.initGameOver(self.getGameOverMessage(collisionType))
        
        fish.physicsBody?.categoryBitMask = 0
        fish.physicsBody?.collisionBitMask = FSBoundaryCategory
        fish.yScale = fish.yScale * -1
        
        self.setTopScore(score)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("restartGame"), userInfo: nil, repeats: false)
    }
    
    func restartGame() {
        state = .FSGameStateStarting
        fish.removeFromParent()
        background.removeAllChildren()
        background.removeFromParent()
        
        instructions.hidden = false
        self.removeActionForKey(crabGenerator)
        self.removeActionForKey(coinGenerator)
        self.removeActionForKey(whaleGenerator)
        self.removeActionForKey(bonusCoinGenerator)
        self.removeActionForKey(boatGenerator)
        self.removeActionForKey(sharkGenerator)
        
        gameOverLabel.removeFromParent()
        
        let topScore : Int = self.getTopScore()
        label_highScore.text = "Top Score : " + (topScore as NSNumber).stringValue
        
        score = 0
        label_score.text = "0"
        backround_speed = defaultBackgroundSpeed
        
        self.initFish()
        self.initBackground()
    }
    
    func moveBackground() {
        let posX: CGFloat = -backround_speed * CGFloat(delta)
        background.position = CGPointMake(background.position.x + CGFloat(posX), 0)
        
        background.enumerateChildNodesWithName(bgName) { (node, stop) in
            let backround_screen_position: CGPoint = background.convertPoint(node.position, toNode: self)
            
            if backround_screen_position.x <= -node.frame.size.width {
                node.position = CGPointMake(node.position.x + (node.frame.size.width * 2.0), node.position.y)
            }
        }
    }
    
// MARK: - Collision Functions
    func didBeginContact(contact: SKPhysicsContact!) {
        let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        
        if collision == (FSPlayerCategory | FSCoinCategory) {
            score++
            label_score.text = "\(score)"
            backround_speed = backround_speed + defaultBackgroundSpeedIncrementValue
            
            if contact.bodyB.node == fish {
                
                var contactPoint = contact.bodyA.node?.position
                
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0
                contact.bodyA.node?.runAction(self.getCoinAnimation(contactPoint!))
                
                return
            }
            
            var contactPoint = contact.bodyB.node?.position
            
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
            contact.bodyB.node?.runAction(self.getCoinAnimation(contactPoint!))
        }
        
        if collision == (FSPlayerCategory | FSCrabCategory) {
            self.gameOver(FSCrabCategory)
        }
        
        if collision == (FSPlayerCategory | FSWhaleCategory) {
            self.gameOver(FSWhaleCategory)
        }
        
        if collision == (FSPlayerCategory | FSBoatCategory) {
            self.gameOver(FSBoatCategory)
        }
        
        if collision == (FSPlayerCategory | FSSharkCategory) {
            self.gameOver(FSSharkCategory)
        }
    }
    
// MARK: - Animation Functions
    func spinAnimation() -> SKAction {
        let spinIn = SKAction.scaleXTo(0.0, duration: 0.5)
        let spinOut = SKAction.scaleXTo(1.0, duration: 0.5)
        let sequence = SKAction.sequence([spinOut, spinIn])
        let spin = SKAction.repeatActionForever(sequence)
        
        return spin
    }
    
    func whaleSwimAnimation() -> SKAction {
        let rotR = SKAction.rotateByAngle(0.15, duration: 0.2)
        let rotL = SKAction.rotateByAngle(-0.15, duration: 0.2)
        let sequence = SKAction.sequence([rotR, rotL, rotL, rotR])
        let wiggle = SKAction.repeatActionForever(sequence)
        
        return wiggle
    }
    
    func goingUpAnumation() -> SKAction {
        let goingUp = SKAction .moveToY(CGRectGetMaxY(screenSize), duration: 10.0)
        
        return goingUp
    }
    
    func moveToTheLeftAnimation(position:CGPoint) -> SKAction {
        let goingLeft = SKAction.moveToX(position.x - 1000, duration: 5.0)
        
        return goingLeft
    }
    
    func crabAnimation(crabPosition:CGPoint) -> SKAction {
        let left = SKAction.moveToX(crabPosition.x - 40.0, duration: 2.5)
        let right = SKAction.moveToX(crabPosition.x + 40.0, duration: 2.5)
        
        let sequence = SKAction.sequence([left, right, left, right])
        
        let animation = SKAction.repeatAction(sequence, count: 10)
        
        return sequence
    }
    
    func getCoinAnimation(coinPosition:CGPoint) -> SKAction {
        let up = SKAction.moveToY(coinPosition.y + 50.0, duration: 0.2)
        let pop = SKAction.scaleBy(0.0, duration: 0.5)
        
        let sequence = SKAction.sequence([up, pop])
        
        return sequence;
    }
    
// MARK: - Touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if state == .FSGameStateStarting {
            state = .FSGameStatePlaying
            
            instructions.hidden = true
            
            fish.physicsBody?.affectedByGravity = true
            fish.physicsBody?.applyImpulse(CGVectorMake(0, 25))
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(crabGeneratorWaitDuration), SKAction.runBlock { self.initCrabs()}])), withKey: crabGenerator)
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(coinGeneratorWaitDuration), SKAction.runBlock { self.initCoins()}])), withKey: coinGenerator)
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(bonusGeneratorWaitDuration), SKAction.runBlock { self.initBonusCoins()}])), withKey: bonusCoinGenerator)
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(whaleGeneratorWaitDuration), SKAction.runBlock { self.initWhale()}])), withKey: whaleGenerator)
            
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(sharkGeneratorWaitDuration), SKAction.runBlock { self.initShark()}])), withKey: sharkGenerator)
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(bubbleGeneratorWaitDuration), SKAction.runBlock { self.initBubble()}])), withKey: bubbleGenerator)
            
              self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(boatGeneratorWaitDuration), SKAction.runBlock { self.initBoat()}])), withKey: boatGenerator)
        }
            
        else if state == .FSGameStatePlaying {
            isTouching = true
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        isTouching = false
    }
    
    
// MARK: - Time
    override func update(currentTime: CFTimeInterval) {
        if last_update_time == 0.0 {
            delta = 0
        } else {
            delta = currentTime - last_update_time
        }
        
        last_update_time = currentTime
        
        if state != .FSGameStateEnded {
            self.moveBackground()
            
            if isTouching {
                fish.physicsBody?.applyImpulse(fishImpulse)
            }
          
            let velocity_x = fish.physicsBody?.velocity.dx
            let velocity_y = fish.physicsBody?.velocity.dy
        
            fish.zRotation = Float.clamp(-1, max: 0.0, value: velocity_y! * (velocity_y < 0 ? 0.003 : 0.001))
        } else {
            fish.zRotation = CGFloat(M_PI)
            fish.removeAllActions()
            
        }
        
    }
}
