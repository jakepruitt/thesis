var stream = require('stream');
var combine = require('stream-combiner');
var split = require('split');

module.exports = function asciiToXYZ(opts) {
    var asciiToXYZTransform = new stream.Transform();
    var y = 0;
    var start = false, stop = false;
    asciiToXYZTransform._transform = function(buf, enc, callback) {
        var line = buf.toString().trim();
        if (line == '# Start of Data:') {
            start = true;
            return callback();
        }
        if (start && !stop) {
            var data = line.split('\t');
            if (data.length === 1) {
                stop = true;
                return callback();
            } else {
                data.forEach(function(z,x) {
                    asciiToXYZTransform.push(x + ' ' + y + ' ' + z/100 + '\n');
                });
                y++;
            }
        }
        return callback();
    };
    return combine(split(), asciiToXYZTransform);
}

if (require.main === module) {
    var fs = require('fs');
    var rawStream = fs.createReadStream(process.argv[2]);
    rawStream.pipe(asciiToXYZ())
       .pipe(process.stdout);
}

