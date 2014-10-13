//
//  GameScene.swift
//  SwiftNinja
//
//  Created by Kenny Cason on 10/12/14.
//  Copyright (c) 2014 Kenny Cason. All rights reserved.
//
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let maxLife = 5
    let sound = Sound()
    let dice = Dice()
    let player = SKSpriteNode(imageNamed: "player")
    let killedLabel = SKLabelNode(fontNamed: "Chalkduster")
    let lifeLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var life = 5
    var monstersDestroyed = 0
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        addChild(player)
        
        killedLabel.text = "Killed " + String(monstersDestroyed)
        killedLabel.fontSize = 20
        killedLabel.fontColor = SKColor.blackColor()
        killedLabel.position = CGPoint(x: size.width - 75, y: size.height - 25)
        addChild(killedLabel)
        
        lifeLabel.text = buildLifeString()
        lifeLabel.fontSize = 20
        lifeLabel.fontColor = SKColor.greenColor()
        lifeLabel.position = CGPoint(x: 5, y: size.height - 25)
        lifeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        addChild(lifeLabel)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        sound.playBackgroundMusic("background-music-aac.caf")
    }
    
    func buildLifeString() -> String {
        var lifeString = "Life "
        if(life <= 0) {
            for _ in 1...maxLife {
                lifeString += "□ "
            }
            return lifeString
        }
        
        for _ in 1...life {
            lifeString += "■ "
        }
        var i: Int
        for i = 0; i < maxLife - life; i++ {
            lifeString += "□ "
        }
        return lifeString
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
    
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Player
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the Y axis
        let actualY = dice.random(min: monster.size.height / 2 , max: size.height - monster.size.height / 2 - 20)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = dice.random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        
        // monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        let hitPlayerAction = SKAction.runBlock() {
            self.hitPlayer()
        }
        monster.runAction(SKAction.sequence([actionMove, hitPlayerAction, actionMoveDone]))
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        killedLabel.text = "Killed " + String(monstersDestroyed)
        if (monstersDestroyed > 30) {
            monstersDestroyed = 0
            doWin()
        }
    }
    
    func doWin() {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func doGameOver() {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func hitPlayer() {
        life--
        lifeLabel.text = buildLifeString()
        if(life == 0) {
            doGameOver()
        }
    }
   
    // collisions come in in un-ordered sets, you need to observe their category bit mask
    func didBeginContact(contact: SKPhysicsContact) {
        let collisionMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch(collisionMask) {
        case (PhysicsCategory.Monster | PhysicsCategory.Projectile):
            println("projectile hit monster")
            var projectile = contact.bodyA.categoryBitMask == PhysicsCategory.Projectile ? contact.bodyA : contact.bodyB
            var monster = contact.bodyA.categoryBitMask == PhysicsCategory.Monster ? contact.bodyA : contact.bodyB
            projectileDidCollideWithMonster(projectile.node as SKSpriteNode, monster: monster.node as SKSpriteNode)
            break;
            
        case (PhysicsCategory.Monster | PhysicsCategory.Player):
            println("monster hit player!")
            hitPlayer()
            break;
            
        default:
            break;
            
        }

    }
    
}