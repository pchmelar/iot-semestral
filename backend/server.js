var http = require('http');
var WebSocketServer = require('ws').Server;

var Gpio = require('onoff').Gpio;
var led = new Gpio(14, 'out');
led.writeSync(0);

var light = {
    val: false
};

// CORS headers
var headers = {};
headers["Access-Control-Allow-Origin"] = "*";
headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, DELETE, OPTIONS";
headers["Access-Control-Allow-Credentials"] = true;
headers["Access-Control-Max-Age"] = '86400'; // 24 hours
headers["Access-Control-Allow-Headers"] = "X-Requested-With, Access-Control-Allow-Origin, X-HTTP-Method-Override, Content-Type, Authorization, Accept";

// ----------------------------------------------------------------

var wss = new WebSocketServer({ port: 8888 });

wss.broadcast = function(data) {
  for (var i in this.clients) this.clients[i].send(data);
};

wss.on('connection', function connection(ws) {

    ws.send(JSON.stringify(light));

    ws.on('message', function incoming(message) {
        if (message == "true") light.val = true;
        else if (message == "false") light.val = false;
        wss.broadcast(JSON.stringify(light));

        console.log('Lights ' + (light.val == true ? 'on' : 'off'));
        led.writeSync(light.val == true ? 1 : 0);
    });

});

// ----------------------------------------------------------------

http.createServer(function(req, res) {

    if (req.url.match("^/light") && req.method == "GET") {
        res.writeHead(200, headers);
        res.end(JSON.stringify(light));
    } 

    else if (req.url.match("^/light") && req.method == "PUT") {

        var body = '';

        req.on('data', function(data) {
            body += data;
            if (body.length > 1e6) req.connection.destroy();
        });

        req.on('end', function() {
            var obj = JSON.parse(body);
            light.val = obj.val;
            res.writeHead(201, headers);
            res.end();
            wss.broadcast(JSON.stringify(light));

            console.log('Lights ' + (light.val == true ? 'on' : 'off'));
            led.writeSync(light.val == true ? 1 : 0);
        });
    } 

    else {
        res.writeHead(200, headers);
        res.end('MI-IOT semestral project');
    }

}).listen(8080)

// ----------------------------------------------------------------
