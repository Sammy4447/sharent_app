// controllers/locationController.js


const locations = require('../models/location');


exports.getCitiesAndDistricts = (req, res) => {
  res.json({ locations });
};


