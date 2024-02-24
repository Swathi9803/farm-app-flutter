import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDzaZ49qQSTz34CttbxOGtfXxNAKsfxBPQ",
      authDomain: "farmapp-a75d8.firebaseapp.com",
      projectId: "farmapp-a75d8",
      storageBucket: "farmapp-a75d8.appspot.com",
      messagingSenderId: "1045875336964",
      appId: "1:1045875336964:android:aecca313087e16b3481251",
    ),
  );


  runApp(MyApp());
}

class Product {
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  final String category;

  Product(this.name, this.price, this.quantity, this.imageUrl, this.category);
}

class Products {
  final String name;
  final double price;
  final double quantity;
  final String imagePath;
  final String category;

  Products(this.name, this.price, this.quantity, this.imagePath, this.category);
}

class Cart {
  List<Product> items = [];

  double getTotalAmount() {
    return items.fold(0.0, (sum, product) => sum + product.price);
  }
}

class User {
  final String username;
  final String email;
  final String address;
  final String mobile;
  final String paymentMethod;

  User(this.username, this.email, this.address, this.mobile, this.paymentMethod);
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmMart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        hintColor: Colors.green,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(products: [
          Product("Potato", 2.5, 100, 'potato.jpg', 'Vegetables'),
          Product("Carrot", 1.5, 150, 'assets/carrot.jpg', 'Vegetables'),
          Product("Tomato", 3.0, 120, 'tomato.jpg', 'Vegetables'),
          Product("Apple", 2.0, 80, 'assets/apple.jpg', 'Fruits'),
          Product("Banana", 1.0, 200, 'assets/banana.jpg', 'Fruits'),
          Product("Lettuce", 2.0, 50, 'assets/lettuce.jpg', 'Vegetables'),
          Product("Strawberry", 4.0, 70, 'assets/strawberry.jpg', 'Fruits'),
          Product("Cucumber", 1.5, 90, 'assets/cucumber.jpg', 'Vegetables'),
          Product("Grapes", 3.5, 120, 'assets/grapes.jpg', 'Fruits'),
          Product("Watermelon", 5.0, 30, 'assets/watermelon.jpg', 'Fruits'),
          // Add more products as needed
        ]),
        '/mycart': (context) => MyCartPage(Cart()),
        '/myorders': (context) => MyOrdersPage(),
        '/profile': (context) => ProfilePage(),
        '/categories': (context) => CategoriesPage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/farmerHome': (context) => FarmerHomePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating a 2-second splash screen delay
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Center(
          child: Image.asset(
            'assets/fmart.png', // Replace with the actual path to your logo image
            width: 500.0, // Set the desired width
            height: 500.0, // Set the desired height
          ),
        ),
      ),
    );
  }
}




class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();

                try {
                  // Sign in user with email and password using Firebase authentication
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // Fetch user type from Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
                  String userType = userDoc['userType'];

                  if (userType == 'Customer') {
                    // If user type is customer, navigate to the home page
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (userType == 'Farmer') {
                    // If user type is farmer, navigate to a farmer-specific page
                    Navigator.pushReplacementNamed(context, '/farmerHome');
                  }
                } catch (error) {
                  // Show error message for invalid credentials
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid email or password'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}



class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedUserType = 'Farmer'; // Default user type

  final List<String> _userTypes = ['Farmer', 'Customer'];

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store additional user information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': _selectedUserType,
        });

        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      } catch (error) {
        print("Error signing up: $error");
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing up. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  // You can add more email validation logic here if needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  // You can add more password validation logic here if needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUserType = newValue;
                    });
                  }
                },
                items: _userTypes.map((String userType) {
                  return DropdownMenuItem<String>(
                    value: userType,
                    child: Text(userType),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'User Type'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  final List<Product> products;

  HomePage({required this.products});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> displayedProducts = [];
  Cart cart = Cart();

  @override
  void initState() {
    super.initState();
    displayedProducts = widget.products;
  }

  @override
  Widget build(BuildContext context) {
    final Product? uploadedProduct = ModalRoute.of(context)!.settings.arguments as Product?;

    // Check if there are uploaded product details
    if (uploadedProduct != null) {
      // Add the uploaded product to the displayed products
      displayedProducts.insert(0, uploadedProduct);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FarmMart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(widget.products),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/user.jpg'),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '+1 555-1234',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                // Add logic to navigate to edit profile page
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Add logic to navigate to settings page
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment Method'),
              onTap: () {
                // Add logic to navigate to payment method page
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                // Add logic to navigate to notifications page
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Add logic to navigate to help page
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Add logic to perform logout
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, User!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Explore our latest products:',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      displayedProducts = widget.products
                          .where((product) =>
                          product.name.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search products',
                    prefixIcon: Icon(Icons.search, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: displayedProducts[index],
                      onAddToCart: () {
                        addToCart(displayedProducts[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category, size: 28),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 28),
            label: 'My Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, size: 28),
            label: 'My Orders',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              navigateToHome(context);
              break;
            case 1:
              Navigator.pushNamed(context, '/categories');
              break;
            case 2:
              navigateToMyCart(context);
              break;
            case 3:
              navigateToMyOrders(context);
              break;

          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
      ),
    );
  }

  void addToCart(Product product) {
    setState(() {
      cart.items.add(product);
    });

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToHome(BuildContext context) {
    // Implement navigation to home
  }

  void navigateToCategories(BuildContext context) {
    // Implement navigation to categories
  }

  void navigateToMyCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyCartPage(cart),
      ),
    );
  }

  void navigateToMyOrders(BuildContext context) {
    // Implement navigation to my orders
  }
}

class MyCartPage extends StatelessWidget {
  final Cart cart;

  MyCartPage(this.cart);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          return CartItemCard(product: cart.items[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'My Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Orders',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              navigateToHome(context);
              break;
            case 1:
              navigateToCategories(context);
              break;
            case 2:
              navigateToMyCart(context);
              break;
            case 3:
              navigateToMyOrders(context);
              break;
          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
      ),
    );
  }
}
class CartItemCard extends StatelessWidget {
  final Product product;

  CartItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    int selectedQuantity = 1; // Initial selected quantity

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '\$${product.price.toStringAsFixed(2)} per unit',
                    style: TextStyle(fontSize: 12.0, color: Colors.green),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dropdown for selecting quantity
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(color: Colors.green),
                        ),
                        child: DropdownButton<int>(
                          value: selectedQuantity,
                          onChanged: (value) {
                            // Update the selected quantity when the user selects a value
                            if (value != null) {
                              selectedQuantity = value;
                              // You can add additional logic here if needed
                            }
                          },
                          items: List.generate(10, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                        ),
                      ),
                      // Order Now button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        onPressed: () {
                          // Navigate to payment page with product details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                product: product,
                                quantity: selectedQuantity,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Order Now',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PaymentPage extends StatelessWidget {
  final Product product;
  final int quantity;

  PaymentPage({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Details:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Text('Quantity: $quantity'),
                          SizedBox(height: 4.0),
                          Text('Cost: \$${(product.price * quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Select Payment Method:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                PaymentMethods(),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to order details page with product details and quantity
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(
                          product: product,
                          quantity: quantity,
                        ),
                      ),
                    );
                  },
                  child: Text('Proceed to Pay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentMethods extends StatefulWidget {
  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String selectedMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('Cash on Delivery'),
          value: 'Cash on Delivery',
          groupValue: selectedMethod,
          onChanged: (value) {
            setState(() {
              selectedMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Credit Card'),
          value: 'Credit Card',
          groupValue: selectedMethod,
          onChanged: (value) {
            setState(() {
              selectedMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Debit Card'),
          value: 'Debit Card',
          groupValue: selectedMethod,
          onChanged: (value) {
            setState(() {
              selectedMethod = value!;
            });
          },
        ),
        // Add more payment methods as needed
      ],
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Product product;
  final int quantity;

  OrderDetailsPage({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    double totalCost = product.price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordered Item:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Text('Quantity: $quantity'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Delivering Address:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  '123 Main St, Cityville, Country',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Price Details:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                ListTile(
                  title: Text('Cost of the Product:'),
                  trailing: Text('\$${totalCost.toStringAsFixed(2)}'),
                ),
                ListTile(
                  title: Text('Offer Rate:'),
                  trailing: Text('\$0.00'), // Replace with the actual offer rate if applicable
                ),
                ListTile(
                  title: Text('Cash on Delivery Charge:'),
                  trailing: Text('\$0.00'), // Replace with the actual COD charge if applicable
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the OrderSuccessPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderSuccessPage(
                          product: product,
                          quantity: quantity,
                          totalCost: totalCost,
                        ),
                      ),
                    );
                  },
                  child: Text('Order Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderSuccessPage extends StatefulWidget {
  final Product product;
  final int quantity;
  final double totalCost;

  OrderSuccessPage({required this.product, required this.quantity, required this.totalCost});

  @override
  _OrderSuccessPageState createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  void initState() {
    super.initState();
    // After 5 seconds, navigate back to the home page
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Successful'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Order Successful!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              // Display ordered item details
              Container(
                width: 120.0,
                height: 120.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Ordered Item: ${widget.product.name}',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Quantity: ${widget.quantity}',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Expected Delivery: In 2 days',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Price: \$${widget.totalCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyOrdersPage extends StatelessWidget {
  final List<Product> myOrders = [
    Product("Watermelon", 5.0, 2, 'assets/watermelon.jpg', 'Fruits'),
    Product("Grapes", 3.5, 1, 'assets/grapes.jpg', 'Fruits'),
    Product("Apple", 2.0, 3, 'assets/apple.jpg', 'Fruits'),
    Product("Tomato", 3.0, 2, 'assets/tomato.jpg', 'Vegetables'),
    Product("Potato", 2.5, 4, 'potato.jpg', 'Vegetables'),
    Product("Carrot", 1.5, 2, 'assets/carrot.jpg', 'Vegetables'),
    Product("Banana", 1.0, 5, 'assets/banana.jpg', 'Fruits'),
    Product("Lettuce", 2.0, 1, 'assets/lettuce.jpg', 'Vegetables'),
    Product("Strawberry", 4.0, 3, 'assets/strawberry.jpg', 'Fruits'),
    Product("Cucumber", 1.5, 2, 'assets/cucumber.jpg', 'Vegetables'),
    // Add more orders as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListView.builder(
        itemCount: myOrders.length,
        itemBuilder: (context, index) {
          return OrderItemCard(product: myOrders[index]);
        },
      ),
      bottomNavigationBar: CustomAppBar(),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final Product product;

  OrderItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              product.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Price: \$${product.price}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quantity: ${product.quantity}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ProfilePage extends StatelessWidget {
  final User user = User('JohnDoe', 'john@example.com', '123 Main St', '+1 555-1234', 'Credit Card');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(height: 16.0),
            Text('Username: ${user.username}'),
            const SizedBox(height: 8.0),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8.0),
            Text('Address: ${user.address}'),
            const SizedBox(height: 8.0),
            Text('Mobile: ${user.mobile}'),
            const SizedBox(height: 8.0),
            Text('Payment Method: ${user.paymentMethod}'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomAppBar(),
    );
  }
}


class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          buildCategoryCard(context, 'Vegetables', 'assets/vegetables.jpg'),
          buildCategoryCard(context, 'Fruits', 'assets/fruits.jpg'),
          buildCategoryCard(context, 'Seeds', 'assets/seeds.jpg'),
          buildCategoryCard(context, 'Saplings', 'assets/saplings.jpg'),
          buildCategoryCard(context, 'Cereals', 'assets/cereals.jpg'),
          buildCategoryCard(context, 'Pulses', 'assets/pulses.jpg'),
          // Add more categories as needed
        ],
      ),
      bottomNavigationBar: CustomAppBar(),
    );
  }

  Widget buildCategoryCard(BuildContext context, String category, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Navigate to the page displaying items for the selected category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryItemsPage(category),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 28, color: Colors.green),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category, size: 28, color: Colors.green),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, size: 28, color: Colors.green),
          label: 'My Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag, size: 28, color: Colors.green),
          label: 'My Orders',
        ),
      ],
      onTap: (index) {
        // Handle navigation based on the tapped index
        switch (index) {
          case 0:
            navigateToHome(context);
            break;
          case 1:
            Navigator.pushNamed(context, '/categories');
            break;
          case 2:
            navigateToMyCart(context);
            break;
          case 3:
            navigateToMyOrders(context);
            break;
        }
      },
    );
  }
}

void navigateToHome(BuildContext context) {
  Navigator.pushNamed(context, '/home');
}

void navigateToCategories(BuildContext context) {
  // No action needed as we're already on the Categories page
}

void navigateToMyCart(BuildContext context) {
  Navigator.pushNamed(context, '/mycart');
}

void navigateToMyOrders(BuildContext context) {
  Navigator.pushNamed(context, '/myorders');
}

class CategoryItemsPage extends StatelessWidget {
  final String category;

  CategoryItemsPage(this.category);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the actual number of items in the category
        itemBuilder: (context, index) {
          // Replace these placeholders with actual item details
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/placeholder_image.jpg'),
            ),
            title: Text('Item ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cost: \$10'), // Replace with actual cost
                Text('Available Quantity: 100'), // Replace with actual quantity
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                // Add item to cart
                // You can implement this functionality as needed
              },
            ),
          );
        },
      ),
    );
  }
}


class CustomSearchDelegate extends SearchDelegate<Product> {
  final List<Product> products;

  CustomSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, Product("", 0.0, 0, "", ""));
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Product> results = products
        .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          subtitle: Text(
              '\$${results[index].price} per unit - Quantity: ${results[index].quantity}'),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Product> suggestionList = query.isEmpty
        ? []
        : products
        .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].name),
          onTap: () {
            query = suggestionList[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  ProductCard({required this.product,  required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: Colors.green,
                  ),
                  onPressed: onAddToCart,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '\$${product.price} per unit',
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Available: ${product.quantity} units',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void addToCart(BuildContext context, Product product) {
  // Add your logic to add the product to the cart
  // For demonstration purposes, let's just show a snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Added ${product.name} to cart'),
      duration: Duration(seconds: 2),
    ),
  );
}


class CategoryCard extends StatelessWidget {
  final String category;
  final String imageUrl;

  CategoryCard({required this.category, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class FarmerHomePage extends StatelessWidget {
  final List<Products> recentlyUploadedItems = [
    Products('Apple', 2.99, 2, 'assets/apple.jpg', 'Fruits'),
    Products('Tomato', 1.49, 3, 'assets/tomato.jpg', 'Vegetables'),
    Products('Carrot', 0.99, 1, 'assets/carrot.jpg', 'Vegetables'),
    Products('Sunflower Seeds', 5.99, 0.5, 'assets/sunflower.jpg', 'Seeds'),
    Products('Rose Sapling', 8.99, 1, 'assets/rose.jpg', 'Saplings'),
    Products('Rice', 3.49, 5, 'assets/rice.jpg', 'Cereals'),
    Products('Strawberry', 2.0, 2, 'assets/strawberry.jpg', 'Fruits'),
    Products('Broccoli', 8.99, 1, 'assets/broccoli.jpg', 'Vegetables'),
    Products('Mushroom', 3.49, 5, 'assets/mushroom.jpg', 'Vegetables'),
    Products('Lentils', 2.0, 2, 'assets/Lentils.jpg', 'Pulses')
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/farmer.jpg'),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Farmer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Mobile: +1234567890',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () {
                // Implement action for 'Edit Profile'
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Implement action for 'Settings'
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Implement action for 'Help'
                Navigator.pop(context); // Close the drawer
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Implement action for 'Logout'
                Navigator.pushReplacementNamed(context, '/login'); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recently Uploaded Items',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            SizedBox(height: 8.0),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: recentlyUploadedItems
                  .take(10)
                  .map((products) {
                return _buildRecentlyUploadedItem(products);
              })
                  .toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.green),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.green),
            label: 'Add',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
            // Navigate to home page
              break;
            case 1:
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
              // Implement action for 'Add'
              break;
          }
        },
      ),
    );
  }

  Widget _buildRecentlyUploadedItem(Products product) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: ${product.quantity} kg',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                Text(
                  '\$${product.price.toString()}',
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Container(
              height: 400.0,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain, // Center the image and remove space on the sides
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '${Random().nextInt(24)} hrs ago',
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String selectedQuantity = '1'; // Initial selected quantity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Image:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.asset('asset/orange.jpg'), // Placeholder for the image
              ),
              SizedBox(height: 16.0),
              Text(
                'Product Name:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Product Price:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter product price',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Quantity (in kg):',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              DropdownButton<String>(
                value: selectedQuantity,
                onChanged: (value) {
                  setState(() {
                    selectedQuantity = value!;
                  });
                },
                items: List.generate(10, (index) => (index + 1).toString())
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement logic to save the product and navigate to customer home page
                  Product uploadedProduct = Product(
                    // Use the entered data to create a Product object
                    // Replace the placeholders with the actual data (e.g., image path, etc.)
                    "Uploaded Product",
                    double.parse("20.0"), // Replace with the actual price entered
                    int.parse(selectedQuantity), // Convert selected quantity to int
                    'assets/orange.jpg', // Replace with the actual image path
                    'Category', // Replace with the actual category
                  );

                  // Navigate to customer home page with the uploaded product details
                  Navigator.pushReplacementNamed(
                    context,
                    '/home', // Use the correct route name for the customer home page
                    arguments: uploadedProduct,
                  );
                },
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
