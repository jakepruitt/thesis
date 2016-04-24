function connected(faceIndex, geom) {
    var vertices = geom.vertices;
    var importantVertices = {};
    var faces = [];
    var added = true;

    var face = geom.faces.splice(faceIndex, 1)[0];
    faces.push(face);
    importantVertices[face.a] = true;
    importantVertices[face.b] = true;
    importantVertices[face.c] = true;

    while (added == true) {
        added = false;

        for (var i = 0; i < geom.faces.length; i++) {
            var f = geom.faces[i];
            if (importantVertices[f.a] ||
                importantVertices[f.b] ||
                importantVertices[f.c]) {

                added = true;
                var face = geom.faces.splice(i, 1)[0];
                faces.push(face);
                importantVertices[face.a] = true;
                importantVertices[face.b] = true;
                importantVertices[face.c] = true;
                i--;
            }
        }
    }

    return {vertices:vertices,faces:faces};
}
