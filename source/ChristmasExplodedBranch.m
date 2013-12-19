//
//  IslandMesh.mm
//
// 

#import "CC3Scene.h"
#import "CC3Node.h"
#import "CC3MeshNode.h"
#import "CC3ParametricMeshNodes.h"
#import "ChristmasExplodedBranch.h"

@implementation ChristmasExplodedBranch

@synthesize mesh;
@synthesize speed;
@synthesize rotationSpeed;

- (void)dealloc {
    [mesh remove];
    [super dealloc];
}

- (void) updateStep {
    mesh.rotation = CC3VectorAdd(mesh.rotation ,rotationSpeed);
    mesh.location = CC3VectorAdd(mesh.location,speed);
    speed = cc3v(speed.x * 0.9, speed.y - 0.08, speed.z * 0.9);
    // Twist flying twig
    if (twistTotal > 10) {
        twistAdd = -1.0;
    } else if (twistTotal < -10) {
        twistAdd = 1.0;
    } else if (twistAdd == 0) {
        twistAdd = 1.0;
    }
    [self twistTree:mesh level:0];
    

}

- (void) twistTree:(CC3MeshNode *)node level:(int)level {
    level++;
    for (CC3MeshNode* object in node.children) {
        if (object.children.count == 0) {
            object.rotation = CC3VectorAdd(object.rotation,cc3v(twistAdd,twistAdd,twistAdd * 20));
        } else {
            object.rotation = CC3VectorAdd(object.rotation,cc3v(twistAdd,twistAdd,twistAdd * level / (2 * object.globalScale.x * object.globalScale.x)));
        }
        [self twistTree:object level:level];
    }
}

@end


