
//with validation
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  firstName: {
  type: String,
  required: true,
  trim: true,
  minlength: [3, 'First name must be at least 3 characters'],
  validate: {
    validator: function (v) {
      return /^(?!.*(.)\1{2,})[A-Za-z][A-Za-z\s\-']{1,19}$/.test(v);

    },
    message: props => `${props.value} is not a valid first name`
  }
},

lastName: {
  type: String,
  required: true,
  trim: true,
  minlength: [3, 'Last name must be at least 3 characters'],
  validate: {
    validator: function (v) {
      return /^(?!.*(.)\1{2,})[A-Za-z][A-Za-z\s\-']{1,19}$/.test(v);
    },
    message: props => `${props.value} is not a valid last name`
  }
},

  email: {
  type: String,
  required: true,
  unique: true,
  lowercase: true,
  validate: {
    validator: function (v) {
      return  /^[a-zA-Z0-9](\.?[a-zA-Z0-9_-]){5,63}@gmail\.com$/.test(v); // Accepts only @gmail.com
    },
    message: props => `${props.value} is not a valid Gmail address!`
  }
},
  password: {
    type: String,
    required: true,
    minlength: [8, 'Password must be at least 8 characters long'],
  },
  phone: {
    type: String,
    unique: true,
    sparse: true,
    validate: {
      validator: function (v) {
        return /^(98|97)\d{8}$/.test(v); // only 10 digit number allowed
      },
      message: props => `${props.value} is not a valid 10-digit phone number.`
    }
  },
  address:   { type: String },   
  city: { type: String},
  district: { type: String},
  isAdmin: { type: Boolean, default: false }
});

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

module.exports = mongoose.model('User', userSchema);
