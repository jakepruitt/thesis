var stream = require('stream');
var combine = require('stream-combiner');
var split = require('split');

module.exports = function asciiToArray() {
    var asciiToArrayTransform = new stream.Transform();
    var total = [];
    var start = false, stop = false;
    asciiToArrayTransform._transform = function(buf, enc, callback) {
        var line = buf.toString();
        if (line.indexOf('Start') > -1) {
            start = true;
            return callback();
        }
        if (start && !stop) {
            var data = line.split('\t');
            if (data.length === 1) {
                stop = true;
                asciiToArrayTransform.push(JSON.stringify(total) + '\n');
                return callback();
            } else {
                data.forEach(function(z) {
                    total.push(Math.round(Number(z)/40+2000));
                });
                return callback();
            }
        } else {
            return callback();
        }
    };
    return combine(split(), asciiToArrayTransform);
}

if (require.main === module) {
    var fs = require('fs');
    var rawStream = fs.createReadStream(process.argv[2]);
    rawStream.pipe(asciiToArray())
       .pipe(process.stdout);
}
