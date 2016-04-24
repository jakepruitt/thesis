var test = require('tape');
var volume = require('../surface/volume');

test('should calculate voume of 1-by-1-by-1 cube', function(assert) {
    var cubeGeom = {
        vertices: [
            {x: 1,y: 1,z: 1},
            {x: 1,y: 1,z: 2},
            {x: 2,y: 1,z: 2},
            {x: 2,y: 1,z: 1},
            {x: 1,y: 2,z: 1},
            {x: 1,y: 2,z: 2},
            {x: 2,y: 2,z: 2},
            {x: 2,y: 2,z: 1}
        ],
        faces: [
            {a: 1,b: 4,c: 5},
            {a: 1,b: 2,c: 3},
            {a: 0,b: 1,c: 3},
            {a: 1,b: 0,c: 4},
            {a: 0,b: 3,c: 4},
            {a: 4,b: 3,c: 7},
            {a: 3,b: 6,c: 7},
            {a: 2,b: 6,c: 3},
            {a: 1,b: 6,c: 2},
            {a: 1,b: 5,c: 6},
            {a: 4,b: 6,c: 5},
            {a: 4,b: 7,c: 6}
        ]
    };
    assert.equal(volume(cubeGeom),1,'calculates volume of a 1x1x1 cube');
    assert.end();
});

test('should calculate voume of 3-by-3-by-3 cube', function(assert) {
    var cubeGeom = {
        vertices: [
            {x: 3,y: 3,z: 3},
            {x: 3,y: 3,z: 6},
            {x: 6,y: 3,z: 6},
            {x: 6,y: 3,z: 3},
            {x: 3,y: 6,z: 3},
            {x: 3,y: 6,z: 6},
            {x: 6,y: 6,z: 6},
            {x: 6,y: 6,z: 3}
        ],
        faces: [
            {a: 1,b: 4,c: 5},
            {a: 1,b: 2,c: 3},
            {a: 0,b: 1,c: 3},
            {a: 1,b: 0,c: 4},
            {a: 0,b: 3,c: 4},
            {a: 4,b: 3,c: 7},
            {a: 3,b: 6,c: 7},
            {a: 2,b: 6,c: 3},
            {a: 1,b: 6,c: 2},
            {a: 1,b: 5,c: 6},
            {a: 4,b: 6,c: 5},
            {a: 4,b: 7,c: 6}
        ]
    };
    assert.equal(volume(cubeGeom),27,'calculates volume of a 1x1x1 cube');
    assert.end();
});
