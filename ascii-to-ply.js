/*
 * So the idea here is that we write to a tmp xyz file with the xyz stream
 * and then read it synchronously
 * or find some way to keep the vertex count in an asynchronous way
 * and then write out the header and delete the temp file
 */


var stream = require('stream');
var combine = require('stream-combiner');
var split = require('split');

function asciiToPLY() {
    var asciiToPLYTransform = new stream.Transform();
    var y = 0;
    var start = false, stop = false;
    var finalstring = '';
    var linecount = 0;
    asciiToPLYTransform._transform = function(buf, enc, callback) {
        var line = buf.toString().trim();
        if (line == '# Start of Data:') {
            start = true;
            return callback();
        }
        if (start && !stop) {
            var data = line.split('\t');
            if (data.length === 1) {
                stop = true;
                finalstring = 'ply\nformat ascii 1.0\nelement vertex '+linecount+'\nproperty float x\nproperty float y\nproperty float z\nend_header\n'+finalstring;
                asciiToPLYTransform.push(finalstring);
                return callback();
            } else {
                data.forEach(function(z,x) {
                    finalstring += x + ' ' + y + ' ' + z/100 + '\n';
                    linecount++;
                });
                y++;
            }
        }
        return callback();
    };
    return combine(split(), asciiToPLYTransform);
}

module.exports = asciiToPLY;

if (require.main === module) {
    var fs = require('fs');
    var rawStream = fs.createReadStream(process.argv[2]);
    rawStream.pipe(asciiToPLY())
       .pipe(process.stdout);
}
