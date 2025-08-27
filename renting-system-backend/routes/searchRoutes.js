const express = require('express');
const router = express.Router();
const { searchAndFilterProducts } = require('../controllers/searchController');

router.get('/', searchAndFilterProducts);

module.exports = router;
