var http = require("http");

var light = {
    val: false
};

// ----------------------------------------------------------------

var WebSocketServer = require('ws').Server
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
    });

});

// ----------------------------------------------------------------

http.createServer(function(req, res) {

    if (req.url.match("^/light") && req.method == "GET") {
        res.writeHead(200, {
            'Content-Type': 'application/json'
        });
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
            res.writeHead(201, {
                'Content-Type': 'application/json'
            });
            res.end();
            wss.broadcast(JSON.stringify(light));
            console.log('Lights ' + (light.val == true ? 'on' : 'off'));
        });
    } 

    else {
        res.writeHead(200, {
            'Content-Type': 'text/plain'
        });
        res.end('MI-IOT semestral project');
    }

}).listen(8080)

// ----------------------------------------------------------------
