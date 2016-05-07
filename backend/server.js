var http = require("http");

var light = {
    val: false
};

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
