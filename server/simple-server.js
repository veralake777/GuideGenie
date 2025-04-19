const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// Import API handler
const api = require('./api-handler');

const PORT = process.env.PORT || 5000;

// Function to parse JSON body from requests
function parseBody(req) {
  return new Promise((resolve, reject) => {
    if (req.method !== 'POST' && req.method !== 'PUT') {
      return resolve({});
    }
    
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const parsedBody = body ? JSON.parse(body) : {};
        resolve(parsedBody);
      } catch (error) {
        reject(error);
      }
    });
    
    req.on('error', (err) => {
      reject(err);
    });
  });
}

// Helper function to serve static files
function serveStaticFile(res, filePath, contentType) {
  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404);
        res.end('File not found');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
}

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  
  console.log(`Request received: ${pathname}`);
  
  // Set CORS headers for all responses
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  try {
    // API routes
    if (pathname === '/api/games') {
      const games = await api.getGames();
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(games));
    } 
    else if (pathname.match(/^\/api\/games\/\d+$/)) {
      const id = parseInt(pathname.split('/').pop());
      const game = await api.getGameById(id);
      
      if (game) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(game));
      } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Game not found' }));
      }
    }
    else if (pathname === '/api/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ 
        status: 'ok', 
        message: 'Server is running with in-memory database',
      }));
    }
    // Add new guide
    else if (pathname.match(/^\/api\/games\/\d+\/guides$/) && req.method === 'POST') {
      // Get the game ID from the URL
      const gameId = parseInt(pathname.split('/')[3]);
      
      // Parse the request body
      const body = await parseBody(req);
      
      // Validate the required fields
      if (!body.title || !body.author) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Title and author are required' }));
        return;
      }
      
      try {
        // Save to the in-memory API
        const newGuide = await api.addGuide(gameId, body);
        
        // Return the new guide
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newGuide));
      } catch (error) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
      }
    }
    // Add new tier list
    else if (pathname.match(/^\/api\/games\/\d+\/tierlists$/) && req.method === 'POST') {
      // Get the game ID from the URL
      const gameId = parseInt(pathname.split('/')[3]);
      
      // Parse the request body
      const body = await parseBody(req);
      
      // Validate the required fields
      if (!body.title || !body.author) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Title and author are required' }));
        return;
      }
      
      try {
        // Save to the in-memory API
        const newTierList = await api.addTierList(gameId, body);
        
        // Return the new tier list
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newTierList));
      } catch (error) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
      }
    }
    // Handle static files or default to test.html
    else {
      // Check if the request is for a specific file in the web directory
      const webFilePath = path.join(__dirname, '../web_demo/web', pathname);
      
      if (pathname === '/' || pathname === '/index.html') {
        serveStaticFile(res, path.join(__dirname, '../web_demo/web/test.html'), 'text/html');
      }
      else if (fs.existsSync(webFilePath) && fs.statSync(webFilePath).isFile()) {
        // Determine content type based on file extension
        const ext = path.extname(pathname).toLowerCase();
        let contentType = 'text/html';
        
        switch (ext) {
          case '.js':
            contentType = 'text/javascript';
            break;
          case '.css':
            contentType = 'text/css';
            break;
          case '.json':
            contentType = 'application/json';
            break;
          case '.png':
            contentType = 'image/png';
            break;
          case '.jpg':
            contentType = 'image/jpg';
            break;
          case '.svg':
            contentType = 'image/svg+xml';
            break;
        }
        
        serveStaticFile(res, webFilePath, contentType);
      } 
      else {
        // Default to serving the test.html for any other paths
        serveStaticFile(res, path.join(__dirname, '../web_demo/web/test.html'), 'text/html');
      }
    }
  } catch (error) {
    console.error('Error handling request:', error);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Internal server error' }));
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});