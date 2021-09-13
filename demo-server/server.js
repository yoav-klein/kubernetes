
const http = require('http');

const server = http.createServer(function(req, resp) {
    if(req.url === '/') resp.write('This is Version 3\n');

    resp.end();
}); // returns http.Server instance

server.listen(3000);

console.log('Listening on port 3000');
