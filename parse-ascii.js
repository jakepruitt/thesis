var stream = require('stream');
var combine = require('stream-combiner');
var split = require('split');

function parseAscii() {
    var parseTransform = new stream.Transform();
    var y = 0;
    var finalX = 0;
    var start = false, stop = false;
    parseTransform._transform = function(buf, enc, callback) {
        var line = buf.toString().trim();
        if (line == '# Start of Data:') {
            start = true;
            return callback();
        }
        if (start && !stop) {
            var data = line.split('\t');
            if (data.length === 1) {
                stop = true;
                console.log('cols:',finalX);
                console.log('rows:',y);
                return callback();
            }
            data.forEach(function(z, x) {
                var obj = {
                    type: 'Feature',
                    properties: {},
                    geometry: {
                        type:'Point',
                        coordinates: [4*x/752,4*y/960 + Number(z)/10000]
                    }
                };
                parseTransform.push(JSON.stringify(obj) + '\n');
                finalX = x;
            });
            y++;
        }
        return callback();
    };
    return combine(split(), parseTransform);
}

if (require.main) {
    var fs = require('fs');
    var rawStream = fs.createReadStream(process.argv[2]);
    rawStream.pipe(parseAscii())
       .pipe(process.stdout);
}
