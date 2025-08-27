const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth'); // Import the auth middleware
const isAdmin = require('../middleware/isAdmin'); // Import the isAdmin middleware
const upload = require('../middleware/upload');
const multer = require('multer');
const { getMostBookedProducts } = require('../controllers/productController');
const { getNewlyAddedProducts } = require('../controllers/productController');
const productController = require('../controllers/productController');

const {
  createCategory,
  getCategories,
  createSubcategory,
  getSubcategoriesByCategory,
  createProduct,
  getProductsBySubcategory,
  getProductById,
  getAllProducts
} = require('../controllers/productController');

// Category
router.post('/categories', auth, isAdmin, createCategory); // ADMIN ONLY
router.get('/categories', getCategories);

// Subcategory
router.post('/subcategories', auth, isAdmin, createSubcategory); // ADMIN ONLY
router.get('/categories/:categoryId/subcategories', getSubcategoriesByCategory);

// Products
// router.post('/', auth, isAdmin, createProduct); // ADMIN ONLY
router.post('/', auth, isAdmin, upload.single('image'), createProduct);
router.get('/subcategory/:subcategoryId', getProductsBySubcategory);

//get all products 
// router.get('/', productController.getAllProducts); //productcontroller.getallproduct gare ni hunxa 
// or getallproduct mathi const{..}require ma rakhe sidhai getallproduct use garna milxa 
// to connect this path with its controller as below:
router.get('/', getAllProducts);

router.get('/category-name/:categoryName/products',  productController.getProductsByCategoryName);


router.delete('/category/:categoryId',auth, isAdmin, productController.deleteCategory);
router.delete('/subcategory/:subcategoryId',auth, isAdmin, productController.deleteSubcategory);
router.delete('/product/:productId',auth, isAdmin, productController.deleteProduct);

router.put('/category/:categoryId',auth, isAdmin, productController.updateCategory);
router.put('/subcategory/:subcategoryId',auth, isAdmin, productController.updateSubcategory);
router.put('/product/:productId',auth, isAdmin, upload.single('image'), productController.updateProduct);


// Place static routes BEFORE dynamic ones
router.get('/most-booked', getMostBookedProducts); // <-- this goes first
router.get('/newly-added', getNewlyAddedProducts); // for newly added products
router.get('/:id', getProductById);                // <-- dynamic route goes last


module.exports = router;
