#!/usr/bin/env node

var logger = require('fastlog')('api-styles');
var morgan = require('morgan');
var asciiToArray = require('../ascii-to-array');
var express = require('express');
var server = module.exports = express();
var port = process.env.PORT || 8889;

server.use(morgan('dev'));

server.get('/', function(req, res, next) {
    return res.send('Everything\'s fine');
});

// server.post('/reconstruct');
// server.post('/volume');
server.post('/ascii-to-array', function(req, res, next) {
   req.pipe(asciiToArray()).pipe(res); 
});

server.listen(port);
logger.info('Started asset localhost:%s', port);

process.on('uncaughtException', function(err) {
    logger.fatal(err);
    process.exit(1);
});
