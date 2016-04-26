var N = {x:0,y:0,z:-1};

function copy(obj) {
    var new_obj = {};
    for (var i in obj) {
        new_obj[i] = obj[i];
    }
    return new_obj;
}

function cachedIndexOrNew(point, reverseTable, V) {
    if (reverseTable[JSON.stringify(point)]) {
        return reverseTable[JSON.stringify(point)];
    } else {
        var index = V.length;
        reverseTable[JSON.stringify(point)] = index;
        point.visible = true;
        V.push(point);
        return index;
    }
}

function toGeometry(mesh) {
    var geometry = new THREE.Geometry();
    geometry.useColor = false;
    mesh.vertices.forEach(function(v) {
        geometry.vertices.push(new THREE.Vector3(v.x, v.y, v.z));
    });

    mesh.faces.forEach(function(f) {
        geometry.faces.push(new THREE.Face3(f.a, f.b, f.c));
    });

    geometry.computeBoundingSphere();
    return geometry;
}

function clipMesh(mesh, z) {
    var c_plane = -z;
    var V = mesh.vertices.map(function(v) {
        var new_v = copy(v);
        new_v.visible = true;
        return new_v;
    });
    var F = mesh.faces.map(function(f) {
        var new_f = copy(f);
        new_f.visible = true;
        return new_f;
    });
    var epsilon = 0.0000000000001;

    // process vertices
    var positive = 0, negative = 0;
    for (var i = 0; i < V.length; i++) {
        if (V[i].visible) {
            V[i].distance = dot(N, V[i]) - c_plane;
            if (V[i].distance >= epsilon) {
                positive++;
            } else if (V[i].distance <= -epsilon) {
                negative++;
                V[i].visible = false;
            } else {
                V[i].distance = 0;
            }
        }
    }

    // If all vertices are on the non-negative side
    if (negative === 0) {
        return mesh;
    }

    // If all vertices are on non-positive side
    if (positive === 0) {
        return;
    }

    var reverseTable = {};
    var clippedEdges = [];
    for (var i = 0; i < F.length; i++) {
        if (F[i].visible) {
            var a = V[F[i].a],
                b = V[F[i].b],
                c = V[F[i].c];
            if (a.visible && b.visible && c.visible) {
                continue;
            } else if (!a.visible && !b.visible && !c.visible) {
                F[i].visible = false;
                continue;
            } else if (a.visible && b.visible && !c.visible) {
                // Cut off c, create new c between b and c
                // also create d between a and c
                var ad = clipLine([a,c], z);
                var bc = clipLine([b,c], z);

                // If it's already been added, use that one
                F[i].c = cachedIndexOrNew(bc[1], reverseTable, V);

                // Add another face here with the same orientation
                var d = cachedIndexOrNew(ad[1], reverseTable, V);
                F.push({
                    a:F[i].a,
                    b:F[i].c,
                    c: d,
                    visible: true
                });
                // Add cd to set of clipped out edges
                clippedEdges.push([d, F[i].c]);
            } else if (a.visible && !b.visible && c.visible) {
                // Cut off b, create new b between a and b
                // also create d between b and c
                var ab = clipLine([a,b], z);
                var dc = clipLine([b,c], z);
                F[i].b = cachedIndexOrNew(ab[1], reverseTable, V);
                // Add another face for b,d,c
                var d =cachedIndexOrNew(dc[0],reverseTable, V); 
                F.push({
                    a:F[i].c,
                    b:F[i].b,
                    c:d,
                    visible: true
                });
                clippedEdges.push([d, F[i].b]);
            } else if (!a.visible && b.visible && c.visible) {
                // Cut off a, create new a between a and b
                // Create new d between c and a
                var ab = clipLine([a,b], z);
                var cd = clipLine([c,a], z);
                F[i].a = cachedIndexOrNew(ab[0], reverseTable, V);
                // Add another face for acd
                var d = cachedIndexOrNew(cd[1], reverseTable, V); 
                F.push({
                    a:F[i].a,
                    b:F[i].c,
                    c:d,
                    visible:true
                });
                clippedEdges.push([F[i].a, d]);
            } else if (a.visible && !b.visible && !c.visible) {
                var ab = clipLine([a,b],z);
                var ac = clipLine([a,c],z);
                F[i].b = cachedIndexOrNew(ab[1], reverseTable, V);
                F[i].c = cachedIndexOrNew(ac[1], reverseTable, V);
                clippedEdges.push([F[i].c, F[i].b]);
            } else if (!a.visible && b.visible && !c.visible) {
                var bc = clipLine([b,c],z);
                var ba = clipLine([b,a],z);
                F[i].a = cachedIndexOrNew(ba[1], reverseTable, V);
                F[i].c = cachedIndexOrNew(bc[1], reverseTable, V);
                clippedEdges.push([F[i].a, F[i].c]);
            } else if (!a.visible && !b.visible && c.visible) {
                var cb = clipLine([c,b],z);
                var ca = clipLine([c,a],z);
                F[i].a = cachedIndexOrNew(ca[1], reverseTable, V);
                F[i].b = cachedIndexOrNew(cb[1], reverseTable, V);
                clippedEdges.push([F[i].b, F[i].a]);
            }
        }
    }

    var filteredF = F.filter(function(f) { return f.visible; });
    var cleanedF = filteredF.map(function(f) {
        delete f.visible;
        return f;
    });
    var cleanedV = V.map(function(v) {
        delete v.visible;
        delete v.distance;
        return v;
    });

    return {faces:filteredF,vertices:V};
}

function clipLine(line, z) {
    var c = -z;

    if (clipPoint(line[0],z) && clipPoint(line[1],z)) return line;
    else if (!clipPoint(line[0],z) && !clipPoint(line[1],z)) return;

    var d0 = dot(N,line[0]) - c;
    var d1 = dot(N,line[1]) - c;

    var q = plus(line[0],scale(minus(line[1],line[0]),d0/(d0-d1)));

    if (clipPoint(line[0],z)) return [line[0],q];
    else return [q,line[1]];
}

function clipPoint(point, z) {
    var c = -z;
    if (dot(point,N) - c >= 0) return point;
}

function dot(v1, v2) {
    return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;
}

function minus(v1, v2) {
    return {
        x: v1.x-v2.x,
        y: v1.y-v2.y,
        z: v1.z-v2.z
    };
}

function plus(v1, v2) {
    return {
        x: v1.x+v2.x,
        y: v1.y+v2.y,
        z: v1.z+v2.z
    };
}

function scale(v,a) {
    return {
        x: a*v.x,
        y: a*v.y,
        z: a*v.z
    };
}


/*
if (module) {
    module.exports.clipMesh = clipMesh;
    module.exports.clipPoint = clipPoint;
    module.exports.clipLine = clipLine;
}
*/
