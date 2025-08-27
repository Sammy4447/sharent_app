const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();
const app = express();
app.use(express.json());
app.use(cors());


//Connect Routes in server.js or index.js
const adminRoutes = require('./routes/adminRoutes');
app.use('/api/admin', adminRoutes);

//Connect Rental Routes to Server
const rentalRoutes = require('./routes/rentalRoutes');
app.use('/api/rentals', rentalRoutes);

//Connect Search Routes to Server
const searchRoutes = require('./routes/searchRoutes');
app.use('/api/search', searchRoutes);

//Connect review Routes to Server
const reviewRoutes = require('./routes/reviewRoutes');
app.use('/api/reviews', reviewRoutes);

//Connect product Routes to Server
const productRoutes = require('./routes/productRoutes'); 
app.use('/api/products', productRoutes);

// Serve static files in Express
app.use('/uploads', express.static('uploads'));


// Connect cart routes to server
const cartRoutes = require('./routes/cartRoutes');
app.use('/api/cart', cartRoutes);


// Routes
app.use('/api/auth', require('./routes/authRoutes'));

//route for cities and districts
const locationRoutes = require('./routes/locationRoutes');
app.use('/api', locationRoutes); 

//route for Contact Us
const contactRoutes = require('./routes/contactRoutes');
app.use('/api', contactRoutes);


// MongoDB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => app.listen(process.env.PORT, () => console.log("Server running")))
  .catch(err => console.error(err));
