<b> Sharent – Rent Smarter, Not Harder </b> 

Sharent is a B2C rental mobile application built with Flutter and powered by a Node.js + MongoDB backend.  
It provides a simple platform where users can browse, rent, and return products digitally — saving cost, time, and space.  

Instead of buying things you only need for a short time, Sharent makes it easy to rent when you need and return when done.  

---

Overview  

In today’s fast-paced world, many people prefer renting items instead of buying them permanently. Sharent was developed as a solution to this growing trend.  

The system follows a Business-to-Consumer (B2C) model where:  
- The Admin manages rental items (add, update, remove, approve rentals).  
- The Users browse, rent, and return items directly via the app.  

 Sharent enables:  
- Access to multiple categories (electronics, tools, books, clothes, seasonal items, etc.)  
- Cross-platform support (Android + iOS via Flutter)  
- Secure user authentication  
- End-to-end rental flow (browse → rent → return)  

---

Features  

 User Side  
- Login & Signup with JWT-based authentication  
- Cart Management – add items, adjust quantity, remove items  
- Product Browsing – view product details, availability, and rent price  
- Rental Flow – rent and return items easily  
- Rental History with search & re-rent option  
- Profile Management – edit profile, update address, change password  
- Privacy Policy, About Us, Contact Form, FAQs

 Admin Side  
- Add, update, or remove rental products  
- Approve or reject rental requests  
- Track rental status of items  

---

Tech Stack  

| Layer     | Technology            |
|-----------|-----------------------|
| Frontend  | Flutter (Dart)        |
| Backend   | Node.js + Express.js  |
| Database  | MongoDB               |
| UI Design | Figma + Canva         |
| Auth      | JWT (JSON Web Tokens) |


---

Installation & Setup  

 Backend Setup  
```bash
# Clone repo
git clone https://github.com/<your-repo>/sharent-backend.git
cd sharent-backend

# Install dependencies
npm install

# Configure environment (.env file)
MONGO_URI=<your-mongodb-uri>
JWT_SECRET=<your-secret-key>
PORT=5000

# Run server
npm start
```

 Frontend Setup  
```bash
# Clone repo
git clone https://github.com/<your-repo>/sharent-frontend.git
cd sharent-frontend

# Install Flutter packages
flutter pub get

# Run app
flutter run
```

---

Screenshots / Demo  
- Login and SignUp Pages
   <p float="left">
     <img width="108" height="240" alt="Screenshot_20250828_173726" src="https://github.com/user-attachments/assets/991987e0-1c6f-4344-8f5b-5c7edb905a3f" />
     <img width="108" height="240" alt="Screenshot_20250828_173733" src="https://github.com/user-attachments/assets/7280804c-f41e-4cbb-8e5a-3c8082c16cef" />
  </p>
- Home Page (offers, categories, popular rentals)
  <p float="left">
    <img width="108" height="240" alt="Screenshot_20250827_191552" src="https://github.com/user-attachments/assets/a0edf31f-65ae-4b91-aae9-e9ba92da5e6b" />
    <img width="108" height="240" alt="Screenshot_20250828_173535" src="https://github.com/user-attachments/assets/f233975f-b667-4276-b4ee-9ea2d2b732c4" />
    <img width="108" height="240" alt="Screenshot_20250828_174910" src="https://github.com/user-attachments/assets/82e4e4a1-0532-408f-aca2-207bf5d01f59" />
    <img width="108" height="240" alt="Screenshot_20250828_174859" src="https://github.com/user-attachments/assets/36a13c21-0b66-425b-84ab-159ee2e46d51" />
    <img width="108" height="240" alt="Screenshot_20250828_173559" src="https://github.com/user-attachments/assets/3b7f778e-dbc8-4172-bdca-2ddecbeeb515" />
  </p>
- Product Detail Page (rent price, description, add to cart)
  <p float="left">
    <img width="108" height="240" alt="Screenshot_20250828_173255" src="https://github.com/user-attachments/assets/5c7a090d-3f85-40a5-965e-2dabb9a9d88b" />
    <img width="108" height="240" alt="Screenshot_20250828_173316" src="https://github.com/user-attachments/assets/ddc70ead-eb02-41e7-8b55-2273cd8b2196" />
  </p>
- Cart Page (quantity selector, remove item)  
  <p float="left">
    <img width="108" height="240" alt="Screenshot_20250827_191946" src="https://github.com/user-attachments/assets/85112ed0-483a-4bef-988e-57b0738cc384" />
  </p>
- Checkout Flow (confirm → terms → payment)  
  <p float="left">
    <img width="108" height="240" alt="Screenshot_20250828_173336" src="https://github.com/user-attachments/assets/e9f683f3-5348-4c74-aa88-239e56221007" />
    <img width="108" height="240" alt="Screenshot_20250828_173354" src="https://github.com/user-attachments/assets/fa6e5fc7-b702-4f68-9618-7b09461645a2" />
    <img width="108" height="240" alt="Screenshot_20250828_173439" src="https://github.com/user-attachments/assets/83a2139f-9ef9-4346-970a-faaa93a7e8e1" />
  </p>
- Profile Page (edit profile, rental history, logout) , etc
  <p float="left">
    <img width="108" height="240" alt="Screenshot_20250827_191849" src="https://github.com/user-attachments/assets/8a2aa9e4-393d-4743-8282-124b01303fc3" />
    <img width="108" height="240" alt="Screenshot_20250828_173654" src="https://github.com/user-attachments/assets/dc5aac35-cf59-4653-9cd9-b4cbe9827698" />
    <img width="108" height="240" alt="Screenshot_20250828_173637" src="https://github.com/user-attachments/assets/02a07242-e1b4-49c1-9824-012ca88f4aee" />
    <img width="108" height="240" alt="Screenshot_20250828_173627" src="https://github.com/user-attachments/assets/e17d6049-083a-4848-84f9-ce2e76625c2f" />
  </p>
---

Testing  

The app was tested with unit tests and system tests.  

 Some Unit Tests  
- User registration with valid credentials → Pass  
- Fetching product details → Pass 
- Adding to cart after login → Pass  
- Profile update reflected immediately → Pass  

 Some System Tests  
- Search with exact/partial keywords → Pass  
- Renting out-of-stock item shows error → Pass  
- Rental history updates after order → Pass  

---

Contributors  

- Ravi Bhatt(Frontend Developer)  
- Menuka Paneru(Backend Developer)
- Sameer Bhatt(System Analyst)  
- Prabha Joshi(UI/UX Designer)

  

Future Improvements  

-  Real-time order tracking  
-  Review & rating system  
-  Push notifications  
-  Admin dashboard  
-  Payment gateway integration  

---

License  

This project was developed as a Major Project Report at Far Western University, Nepal.  
For academic and educational purposes only.  
