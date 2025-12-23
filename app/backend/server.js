const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/employees', require('./src/routes/employeeRoutes'));

app.get('/', (req, res) => {
  res.json({
    message: 'Employee Backend API is running!',
    timestamp: new Date().toISOString()
  });
});

app.use(require('./src/middlewares/errorHandler'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
});
