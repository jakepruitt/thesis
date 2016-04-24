var clip = require('../surface/clip');
var test = require('tape');

test('clip points', function(assert) {
    var p1 = {x:0,y:0,z:-1};
    var p2 = {x:1,y:1,z:-2};
    var p3 = {x:0,y:0,z:1};
    assert.deepEqual(clip.clipPoint(p1,0), p1, 'returns point when it\'s lower than zero');
    assert.equal(clip.clipPoint(p1,-1.5), undefined, 'doesn\'t return point when it\'s above z');
    assert.deepEqual(clip.clipPoint(p2,-1.5), p2, 'returns point when it\'s lower than -1.5');
    assert.end();
});

test('clip line', function(assert) {
    var line1 = [
        {x:0,y:0,z:1},
        {x:0,y:0,z:-1}
    ];
    var line2 = [
        {x:1,y:0,z:1},
        {x:0,y:1,z:1}
    ];
    var line3 = [
        {x:1,y:0,z:-1},
        {x:0,y:1,z:-1}
    ];
    var line4 = [
        {x:1,y:0,z:1},
        {x:0,y:1,z:-1}
    ];
    assert.equal(clip.clipLine(line2,0), undefined, 'drops lines above 1');
    assert.equal(clip.clipLine(line1,-2), undefined, 'drops lines above -2');
    assert.deepEqual(clip.clipLine(line3,0), line3, 'drops lines above -2');
    assert.deepEqual(clip.clipLine(line1,0), [{x:0,y:0,z:0},{x:0,y:0,z:-1}], 'clips lines halfway');
    assert.deepEqual(clip.clipLine(line4,0), [{x:0.5,y:0.5,z:0},{x:0,y:1,z:-1}], 'clips lines halfway');
    assert.deepEqual(clip.clipLine(line4,-1), [{x:0,y:1,z:-1},{x:0,y:1,z:-1}], 'clips lines to one point');
    assert.end();
});

test('clipping a cube', function(assert) {
    var cube = {
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

    assert.equal(clip.clipMesh(cube, 0), undefined, 'drops cube above 0');
    assert.deepEqual(clip.clipMesh(cube, 3), cube, 'keeps cube below 3');
    assert.deepEqual(clip.clipMesh(cube, 1.5), cube, 'cuts cube in half');
    assert.end();
});
