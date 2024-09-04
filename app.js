// app.js

const express = require('express');
const app = express();
const port = 8080;

// Define a simple route for the app
app.get('/', (req, res) => {
  res.send('Hello from Regtech App!');
});

// Start the server
app.listen(port, () => {
  console.log(`Regtech app is running at http://localhost:${port}`);
});