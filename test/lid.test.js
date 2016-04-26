var lid = require('../surface/lid');
var test = require('tape');

test('adds a lid to a clipped cube', function(assert) {
    var clippedCube = {
        faces: [
            { a: 8, b: 4, c: 9 },
            { a: 10, b: 11, c: 3 }, 
            { a: 0, b: 12, c: 3 },
            { a: 12, b: 0, c: 4 },
            { a: 0, b: 3, c: 4 },
            { a: 4, b: 3, c: 7 },
            { a: 3, b: 13, c: 7 },
            { a: 11, b: 13, c: 3 },
            { a: 4, b: 15, c: 9 },
            { a: 4, b: 7, c: 14 },
            { a: 3, b: 12, c: 10 },
            { a: 12, b: 4, c: 8 },
            { a: 7, b: 13, c: 14 },
            { a: 4, b: 14, c: 15 }
        ],
        vertices: [
            { x: 1, y: 1, z: 1 },
            { x: 1, y: 1, z: 2 },
            { x: 2, y: 1, z: 2 },
            { x: 2, y: 1, z: 1 },
            { x: 1, y: 2, z: 1 },
            { x: 1, y: 2, z: 2 },
            { x: 2, y: 2, z: 2 },
            { x: 2, y: 2, z: 1 },
            { x: 1, y: 1.5, z: 1.5 },
            { x: 1, y: 2, z: 1.5 },
            { x: 1.5, y: 1, z: 1.5 },
            { x: 2, y: 1, z: 1.5 },
            { x: 1, y: 1, z: 1.5 },
            { x: 2, y: 1.5, z: 1.5 },
            { x: 2, y: 2, z: 1.5 },
            { x: 1.5, y: 2, z: 1.5 }
        ]
    };

    var lidCube = {
        faces: [
            { a: 8, b: 4, c: 9 },
            { a: 10, b: 11, c: 3 },
            { a: 0, b: 12, c: 3 },
            { a: 12, b: 0, c: 4 },
            { a: 0, b: 3, c: 4 },
            { a: 4, b: 3, c: 7 },
            { a: 3, b: 13, c: 7 },
            { a: 11, b: 13, c: 3 },
            { a: 4, b: 15, c: 9 },
            { a: 4, b: 7, c: 14 },
            { a: 3, b: 12, c: 10 },
            { a: 12, b: 4, c: 8 },
            { a: 7, b: 13, c: 14 },
            { a: 4, b: 14, c: 15 },
            { a: 8, b: 9, c: 15 },
            { a: 10, b: 12, c: 8 },
            { a: 13, b: 11, c: 10 },
            { a: 15, b: 14, c: 13 },
            { a: 10, b: 8, c: 15 },
            { a: 15, b: 13, c: 10 }
        ],
        vertices: [
            { x: 1, y: 1, z: 1 },
            { x: 1, y: 1, z: 2 },
            { x: 2, y: 1, z: 2 },
            { x: 2, y: 1, z: 1 },
            { x: 1, y: 2, z: 1 },
            { x: 1, y: 2, z: 2 },
            { x: 2, y: 2, z: 2 },
            { x: 2, y: 2, z: 1 },
            { x: 1, y: 1.5, z: 1.5 },
            { x: 1, y: 2, z: 1.5 },
            { x: 1.5, y: 1, z: 1.5 },
            { x: 2, y: 1, z: 1.5 },
            { x: 1, y: 1, z: 1.5 },
            { x: 2, y: 1.5, z: 1.5 },
            { x: 2, y: 2, z: 1.5 },
            { x: 1.5, y: 2, z: 1.5 }
        ]
    };

    assert.deepEqual(lid(clippedCube, 1.5), lidCube, 'adds a lid to the cube');
    assert.end();
});
