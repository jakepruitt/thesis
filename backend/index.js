#!/usr/bin/env node

var logger = require('fastlog')('api-styles');
var morgan = require('morgan');
var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var asciiToArray = require('../ascii-to-array');
var asciiToPLY = require('../ascii-to-ply');
var express = require('express');
var cors = require('cors');
var server = module.exports = express();
var port = process.env.PORT || 8889;

var normalize = path.resolve(__dirname, '../bin/normalize');
var poissonRecon = path.resolve(__dirname, '../bin/PoissonRecon');

server.use(morgan('dev'));

server.use('*',cors({origin:'*',maxAge:60e4}));

server.get('/', function(req, res, next) {
    return res.send('Everything\'s fine');
});

// server.post('/reconstruct');
// server.post('/volume');
server.post('/ascii-to-array', function(req, res, next) {
    req.pipe(asciiToArray()).pipe(res); 
});

server.post('/ascii-to-ply', function(req, res, next) {
    req.pipe(asciiToPLY()).pipe(res);
});

server.post('/add-normals', function(req, res, next) {
    var temp = 'temp.ply';
    var tempNorm = 'temp-normalized.ply';
    var tempstream = fs.createWriteStream(temp);

    req.pipe(tempstream);
    tempstream.on('finish', function() {
        exec(normalize + ' ' + temp + ' ' + tempNorm, function(err, stderr, stdout) {
            if (err) {
                console.error(stderr);
                return next(err);
            }
            var normstream = fs.createReadStream(tempNorm);
            normstream.pipe(res);
            res.on('finish', function() {
                fs.unlinkSync(temp);
                fs.unlinkSync(tempNorm);
            });
        });
    });
});

server.post('/poisson-reconstruction', function(req,res,next) {
    var temp = 'temp.ply';
    var tempRecon = 'temp-reconstructed.ply';
    var tempstream = fs.createWriteStream(temp);
    var poissonRecon = path.resolve(__dirname, '../bin/PoissonRecon');

    req.pipe(tempstream);
    tempstream.on('finish', function() {
        exec(poissonRecon + ' --in ' + temp + ' --out ' + tempRecon, function(err, stderr, stdout) {
            if (err) {
                console.error(stderr);
                console.error(stdout);
                return next(err);
            }
            var reconstream = fs.createReadStream(tempRecon);
            reconstream.pipe(res);
            res.on('finish', function() {
                fs.unlinkSync(temp);
                fs.unlinkSync(tempRecon);
            });
        });
    });
});

server.post('/ascii-to-surface', function(req,res,next) {
    console.log('hit the post endpoint?');
    var temp = 'temp.ply';
    var tempNormal = 'temp-normal.ply';
    var tempRecon = 'temp-reconstructed.ply';
    var tempstream = fs.createWriteStream(temp);

    // Convert ascii to ply
    req.pipe(asciiToPLY()).pipe(tempstream);
    tempstream.on('finish', function() {
        console.log('finished writing to temp');
        // Add normals to ply file
        exec(normalize + ' ' + temp + ' ' + tempNormal, function(err, stderr, stdout) {
            console.log('finished normalizing');
            if (err) {
                console.error(stderr);
                return next(err);
            }
            // Create surface with poisson reconstruction
            exec(poissonRecon + ' --in ' + tempNormal + ' --out ' + tempRecon, function(err, stderr, stdout) {
                console.log('finished reconstructing');
                if (err) {
                    console.error(stderr);
                    console.error(stdout);
                    return next(err);
                }
                var reconstream = fs.createReadStream(tempRecon);
                reconstream.pipe(res);
                res.on('finish', function() {
                    fs.unlinkSync(temp);
                    fs.unlinkSync(tempNormal);
                    fs.unlinkSync(tempRecon);
                });
            });
        });
    });
});

server.listen(port);
logger.info('Started asset localhost:%s', port);

process.on('uncaughtException', function(err) {
    logger.fatal(err);
    process.exit(1);
});
