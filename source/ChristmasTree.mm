//
//  IslandMesh.mm
//
// 

#import "CC3Scene.h"
#import "CC3Node.h"
#import "CC3MeshNode.h"
#import "CC3ParametricMeshNodes.h"
#import "ChristmasTree.h"
#import "ChristmasExplodedBranch.h"

@implementation ChristmasTree

@synthesize mesh;

#define TWIGLENGTH 0.12
#define GREENTWIGRADIUS 0.01
#define GROWFACTOR 1.05
#define GREENCHANGEFACTOR 1.45
#define BRANCHFACTOR 0.7
#define DIRECTBRANCHGROWFACTOR 0.90
#define DIRECTGROWFACTOR 0.95
#define SMALLVARIATION - 12.0 + rand()%100/6.0
#define MAXIMUMNODES 10000

- (void)dealloc {
    [mesh remove];
    [super dealloc];
}

- (void) create:(CC3Scene*) useScene {
    toScene = useScene;
    ballMesh = [CC3MeshNode nodeWithName:@"Christmasball" ];
    ballMesh.shouldUseLighting = YES;
    starInserted = NO;
    twistAdd = 0;
    twistTotal = 0;
    growingStarStep = 0;
  
    ballMesh.ambientColor = ccc4FFromccc4B(ccc4(80,20,20, 255));
    ballMesh.specularColor = ccc4FFromccc4B(ccc4(250,255,255, 255));
    ballMesh.diffuseColor = ccc4FFromccc4B(ccc4(160,30,30, 255));
    ballMesh.shininess = 255.0;
    [ballMesh  populateAsSphereWithRadius:0.1 andTessellation: CC3TessellationMake(6, 6)];
    
    ballMesh.visible = false;
    [toScene addChild:ballMesh];
    
    twigMesh = [CC3MeshNode nodeWithName:@"Basetwig" ];
    [twigMesh populateAsSolidBox:CC3BoxMake(-GREENTWIGRADIUS,0.0,-GREENTWIGRADIUS,GREENTWIGRADIUS,TWIGLENGTH,GREENTWIGRADIUS)];
    twigMesh.visible = false;
    twigMesh.shouldUseSmoothShading = YES;
    twigMesh.material.shouldUseLighting = YES;
    twigMesh.ambientColor = ccc4FFromccc4B(ccc4(20,55,20, 255));
    twigMesh.diffuseColor = ccc4FFromccc4B(ccc4(30,100,30, 255));
    [toScene addChild:twigMesh];
    
    nodeindex = 0;
    mesh = (CC3MeshNode*)[[toScene getNodeNamed:@"Basetwig" ]
                           copyWithName:[NSString stringWithFormat:@"maintwig%d" , nodeindex]];
    [toScene addChild:mesh];
    mesh.visible = YES;
    nodeindex++;
}

- (void) setWoodColor:(CC3MeshNode*) node {
    node.material.ambientColor = ccc4FFromccc4B(ccc4(10,8,8, 255));
    node.material.specularColor = ccc4FFromccc4B(ccc4(30,18,18, 255));
    node.material.diffuseColor = ccc4FFromccc4B(ccc4(20,15,15, 255));
}

- (void) setHalfGreen:(CC3MeshNode*) node {
    node.material.ambientColor = ccc4FFromccc4B(ccc4(20,35,15, 255));
    node.material.specularColor = ccc4FFromccc4B(ccc4(40,60,30, 255));
    node.material.diffuseColor = ccc4FFromccc4B(ccc4(30,60,20, 255));
}
- (void) setGreen:(CC3MeshNode*) node {
    node.material.ambientColor = ccc4FFromccc4B(ccc4(20,45,20, 255));
    node.material.diffuseColor = ccc4FFromccc4B(ccc4(60,180,60, 255));
}

- (void) setGold:(CC3MeshNode*) node {
    node.ambientColor = ccc4FFromccc4B(ccc4(120,100,0, 255));
    node.specularColor = ccc4FFromccc4B(ccc4(250,255,255, 255));
    node.diffuseColor = ccc4FFromccc4B(ccc4(200,170,0, 255));
    node.shininess = 128.0;
}
- (void) setSnow:(CC3MeshNode*) node {
    if ([node.name hasPrefix:@"c"] ) return; // Not balls. Or maybe they should be frosty...
    node.material.ambientColor = ccc4FFromccc4B(ccc4(65,65,90, 255));
    node.material.specularColor = ccc4FFromccc4B(ccc4(100,100,100, 255));
    node.material.diffuseColor = ccc4FFromccc4B(ccc4(80,80,80, 255));
    node.material.emissionColor = ccc4FFromccc4B(ccc4(0,0,0, 255));
    
    node.material.shininess = 0.0;
    if (node.children.count == 0) {
        node.scale = cc3v(2.0 , 1.1, 2.0);
    }
    
}

- (void) grow:(CC3MeshNode *) node {
    
    if ([node.name hasPrefix:@"c"] || [node.name hasPrefix:@"s"]) return; // Christmas balls and stars dont grow
    // Recursively grow and keep scale correct
    for (CC3MeshNode* object in node.children) {
        if ([object.name hasPrefix:@"c"]) {
            object.scale = cc3v(1 / object.globalScale.x, 1 / object.globalScale.y , 1 / object.globalScale.z);
        }  else if ([node.name hasPrefix:@"b"]) {
            object.scale = cc3v(BRANCHFACTOR  , BRANCHFACTOR , BRANCHFACTOR); // Side branches grow slower than direct
        } else if ([node.name hasPrefix:@"d"]) {
            object.scale = cc3v(DIRECTBRANCHGROWFACTOR  , DIRECTBRANCHGROWFACTOR , DIRECTBRANCHGROWFACTOR); // Direct branch
        } else {
            object.scale = cc3v(DIRECTGROWFACTOR, DIRECTGROWFACTOR , DIRECTGROWFACTOR); // Main tree grows fastes
        }
        if (object.globalScale.x >= 1.0) {
            [self grow:object]; // Twigs grow when they are big enough
        }
    }
     // Grow new stuff if branch is big enough
    if (node.children.count < 3 && node.globalScale.x > 1.0) {
        float firstangle = rand()%360;
        if ([node.name hasPrefix:@"m"]) {
            // Main branch. Four twigs and main branch to up. 2 branches from the middle and two from top
            [self addTwig:node rotation:cc3v(0.0,0.0,(SMALLVARIATION)/10.0) tolength:TWIGLENGTH nametag:@"m"];
            [self addTwig:node rotation:cc3v(0.0,firstangle,85.0) tolength:TWIGLENGTH nametag:@"b"];
            [self addTwig:node rotation:cc3v(0.0,firstangle + 70 + rand()%40,85.0) tolength:TWIGLENGTH/2 nametag:@"b"];
            [self addTwig:node rotation:cc3v(0.0,firstangle + 160 + rand()%40,85.0) tolength:TWIGLENGTH nametag:@"b"];
            [self addTwig:node rotation:cc3v(0.0,firstangle + 220 + rand()%40,85.0) tolength:TWIGLENGTH/2 nametag:@"b"];
        } else {
            // Side branches. One forward and two to sides. "+ 1.0" in z axis turn branches a little to upward direction
            [self addTwig:node rotation:cc3v(SMALLVARIATION,SMALLVARIATION,SMALLVARIATION + 1.0) tolength:TWIGLENGTH nametag:@"d"];
            [self addTwig:node rotation:cc3v(50.0,SMALLVARIATION,SMALLVARIATION + 1.0) tolength:TWIGLENGTH nametag:@"b"];
            [self addTwig:node rotation:cc3v(-50.0,SMALLVARIATION,SMALLVARIATION + 1.0) tolength:TWIGLENGTH nametag:@"b"];
            if (rand()%1000 < 25) {
                [self addChristmasBall:node]; // And the random christmas balls
            }
        }

    }
    // Now keep the color depending of how many levels of childs this branch has
    if (node.children.count > 0 ) {
        [self setColors:node];
    }
}
- (void) setColors:(CC3MeshNode*) node {
    if ([node.name hasPrefix:@"c"] || [node.name hasPrefix:@"s"]) return; // Ball / star
        
    if (((CC3MeshNode*) [node.children objectAtIndex:0]).children.count > 0) {
        CC3MeshNode* child = [ ((CC3MeshNode*) [node.children objectAtIndex:0]).children objectAtIndex:0];
        if (child.children.count == 0) {
            node.scale = cc3v(GREENCHANGEFACTOR, GREENCHANGEFACTOR , GREENCHANGEFACTOR); // Green twigs look bigger than others
            [self setHalfGreen:node]; // Between wood & green
        } else {
            [self setWoodColor:node]; // Wood
        }
    } else {
        [self setGreen:node]; // Green
    }
    
}

- (void) addTwig:(CC3MeshNode*) node rotation:(CC3Vector)rotation tolength:(float)length nametag:(NSString*)nametag {
    nodeindex++;
    CC3MeshNode* newnode = (CC3MeshNode*)[[toScene getNodeNamed:@"Basetwig" ]
                                          copyWithName:[NSString stringWithFormat:@"%@twig%d" ,nametag, nodeindex]];
    [node addChild:newnode];
    newnode.location = cc3v(0.0,length,0.0); // relative to parent node.
    newnode.visible = YES;
    newnode.rotation = rotation;
    
}

- (void) addChristmasBall:(CC3MeshNode*) node {
    nodeindex++;
    CC3MeshNode* newnode = (CC3MeshNode*)[[toScene getNodeNamed:@"Christmasball" ]
                                          copyWithName:[NSString stringWithFormat:@"chrb%d" , nodeindex]];

    [node addChild:newnode];
    newnode.visible = YES;
    newnode.shouldUseLighting = YES;
    newnode.location = cc3v(-0.1,TWIGLENGTH / 2,0.0); // relative to parent node.
    if (rand()%100 < 40) {
        [self setGold:newnode]; // Gold ball
    }
}

/* FInd the uppermost branch */

- (void) insertStarToTop:(CC3MeshNode *)node {
    bool topmost;
    topmost = true;
    for (CC3MeshNode* object in node.children) {
        if ([object.name hasPrefix:@"m"]) {
            topmost = false;
            [self insertStarToTop:object];
        }
    }
    if (topmost) [self addStar:node];

}

- (void) snowifyNode:(CC3MeshNode *)node percentage:(float)percentage{
    for (CC3MeshNode* object in node.children) {
        if (![object.name hasPrefix:@"s"]) {
            [self snowifyNode:object percentage:percentage];
        }
    }
    if (rand()%100 < percentage) {
        [self setSnow:node];
    }
}

- (void) snowify:(float)percentage {
    [self snowifyNode:mesh percentage:percentage];
}

- (void) resetColors:(CC3MeshNode *)node {
    for (CC3MeshNode* object in node.children) {
        [self setColors:object];
        [self resetColors:object];
    }
}
- (void) twistTree:(CC3MeshNode *)node level:(int)level {
    level++;
    for (CC3MeshNode* object in node.children) {
        if ([object.name hasPrefix:@"s"]) continue; // Star
            
        if (object.children.count == 0) {
            object.rotation = CC3VectorAdd(object.rotation,cc3v(0.0,0.0,- twistAdd * 25));
        } else {
            object.rotation = CC3VectorAdd(object.rotation,cc3v(0.0,0.0,- twistAdd * level / (1.5 * object.globalScale.x * object.globalScale.x)));
        }
        [self twistTree:object level:level];
    }
}

- (void) addStar:(CC3MeshNode*) node {
    lamp = [CC3Light nodeWithName: @"starLamp"];
    
    [node addChild:lamp];
    lamp.location = cc3v( 0.0, -0.2, 0.0 );
    
    lamp.isDirectionalOnly = NO;
    lamp.emissionColor = ccc4FFromccc4B(ccc4(230, 230, 100, 255));
    
    [self buildStar:node];
    growingStarStep = 1;
    [self growStar];

}

- (void) growStar {
    float starScale = 2 * (growingStarStep / 100.0 ) * (1.0 / starNode.parent.globalScale.y );
    starNode.scale = cc3v(starScale,starScale,starScale);
    growingStarStep++;
    float growPercent;
    growPercent = (100.0 / growingStarStep) * (  100.0 / growingStarStep) * (  100.0 / growingStarStep);
    if (lamp != nil) lamp.attenuation = CC3AttenuationCoefficientsMake(0.1 *  growPercent , 0.06  *  growPercent , 0.01  *  growPercent );

    starNode.location = cc3v(0, 0.0016 * growingStarStep + 0.07,0.0);
    

    if (growingStarStep > 100) growingStarStep = 0; // Ready
    
}
- (void) addStar {
    starInserted = YES;
    growingStarStep = 1;
    [self insertStarToTop:mesh];
}

- (void) updateStep {
    /* Add new stuff if not already too big*/
    
    if (exploded) {
        NSMutableArray*  secarray = [NSMutableArray arrayWithArray:explodedBranches];
        for (ChristmasExplodedBranch* object in secarray) {
            [object updateStep];
            // Remove if branch is below 0 level (this might not be true if this is used somewhere else )
            if (object.mesh.location.y < 0) {
                [toScene removeChild:object.mesh];
                [explodedBranches removeObject:object];
            }
        }
    }
//    if (starNode != nil) {
    
//        starNode.rotation = cc3v(starNode.rotation.x,starNode.rotation.y + 2.0,starNode.rotation.z);
//    }
    if (lightray != nil) {
        lightray.rotation = cc3v(lightray.rotation.x ,lightray.rotation.y,lightray.rotation.z + (rand()%3 - 1.0));
    }
    if (nodeindex > MAXIMUMNODES) {
        if (growingStarStep > 0) [self growStar];
   
        if (twistTotal > 1) {
            twistAdd = -0.06;
        } else if (twistTotal < -1) {
            twistAdd = 0.04;
        } else if (twistAdd == 0) {
            twistAdd = 0.04;
        }
        // Twist tree in wind
        twistTotal = twistAdd + twistTotal;
        [self twistTree:mesh level:0];
        return;
        
    }
    mesh.scale = cc3v(mesh.scale.x * GROWFACTOR, mesh.scale.y * GROWFACTOR  ,mesh.scale.z * GROWFACTOR);
    
    [self grow:mesh];
}

// Build star from 8 cones
- (void) buildStar:(CC3MeshNode*) node {
    nodeindex++;
    starNode = [CC3Node nodeWithName:[NSString stringWithFormat:@"starmain%d" , nodeindex]];
    [node addChild:starNode];
    starNode.location = cc3v(0, 0.07 ,0.0);

    for (int i = 0;i < 8 ; i++) {
        CC3MeshNode* star;
        star = [CC3MeshNode nodeWithName:[NSString stringWithFormat:@"star%d" , i]];
        star.material.shouldUseLighting = YES;
        star.ambientColor = ccc4FFromccc4B(ccc4(200,200,200, 255));
        star.diffuseColor = ccc4FFromccc4B(ccc4(255,255,255, 255));
        star.specularColor = ccc4FFromccc4B(ccc4(255,255,255, 255));

        float height;
        height = 0.15;
        if (i%2 == 1) height = 0.12;
        if (i == 0 || i == 4) height = 0.25;
        
        [star populateAsHollowConeWithRadius:0.03 height:height andTessellation:CC3TessellationMake(6, 6)];
        [starNode addChild:star];
        star.location = cc3v(0,0.0,0);
        star.rotation = cc3v(i * 45.0,20.0,0.0);
        star.visible = true;
    }
    [self createLightRay];

    
}
                    
- (void) createLightRay {
    lightray = [CC3MeshNode nodeWithName:@"Lightrays" ];
    lightray.material.shouldUseLighting = YES;
    [lightray populateAsCenteredRectangleWithSize: CGSizeMake(1.0,1.0)
                                   andTessellation: CC3TessellationMake(4,4)];
    
    lightray.ambientColor = CCC4FMake (1.0,1.0,1.0,1.0);
    lightray.diffuseColor = CCC4FMake (1.0,1.0,1.0,1.0);
    lightray.specularColor = CCC4FMake (1.0,1.0,1.0,1.0);
    lightray.emissionColor = CCC4FMake (1.0,1.0,1.0,1.0);
    lightray.material.shouldUseLighting = YES;
    lightray.shouldCullBackFaces = NO;
    lightray.visible = TRUE;
    lightray.isOpaque = NO;
    lightray.rotation = cc3v(0.0,90.0,90.0);
    
    [starNode  addChild:lightray];
    
    [lightray addTexture:[CC3Texture textureFromFile:@"lightrays.png"]];
    
    lightray.scale = cc3v(3,3,3);
    lightray.location = cc3v(-0.16,0.02,0.2);
}



- (void) explodeTree:(CC3MeshNode *)node level:(int)level {
    level++;
    growingStarStep = 0;
    starNode = nil;
    if (lamp != nil) {
        [lamp.parent removeChild:lamp];
    }
    CCArray* children = [CCArray arrayWithArray:node.children];
    for (CC3MeshNode* object in children) {
        if (object.children.count > 0 && level < 11) [self explodeTree:object level:level];
        bool explode;
        explode = NO;
        if (([object.name hasPrefix:@"m"] && level == 8)) {
            explode = true; // Always cut main branch from level seven
        } else if (level == 8) {
            explode = true; // Cut all branches
        } else if ([object.name hasPrefix:@"m"] && level <= 7) {
            explode = false; // Leave main branch
        } else if  (level == 1 && rand()%100 < 50) {
            explode = false;
        } else if ( rand()%100 < 80.0 / sqrt(level) ) {
            explode = true;
        }
        
        if (explode)  {
            ChristmasExplodedBranch* explb = [[ChristmasExplodedBranch alloc] init];
            explb.speed = cc3v(-2.5 + (rand()%100 )/ 20.0, (rand()%100) / 70.0,-2.5 + (rand()%100) / 20.0);
            explb.rotationSpeed = cc3v(-5.0 + (rand()%100 )/ 10.0, -5.0 + (rand()%100 )/ 10.0,-5.0 + (rand()%100) / 10.0);
            explb.mesh = object;
            // Move from tree to scene and maintain location and rotation
            CC3Vector loc = object.globalLocation;
            CC3Vector rot = object.globalRotation;
            CC3Vector sca = object.globalScale;
            
            [node removeChild:object];
            [toScene addChild:object];
            object.location = loc;
            object.rotation = rot;
            object.scale = sca;
            
            [explodedBranches addObject:explb];
        }
    }
}

- (void) explode {
    explodedBranches = [[NSMutableArray alloc] init];
    exploded = true;
    [self resetColors:mesh]; // No snow anymore
    
    [self explodeTree:mesh level:0];
}

@end


