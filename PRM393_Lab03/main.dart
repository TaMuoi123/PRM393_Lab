import 'dart:async';
import 'dart:convert';


// Exercise 1: Product Model & Repository


class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}

class ProductRepository {
  final List<Product> _products = [
    Product(id: '1', name: 'Laptop', price: 999.99),
    Product(id: '2', name: 'Phone', price: 499.99),
  ];
  
  // Broadcast stream controller to emit new items
  final StreamController<Product> _controller = StreamController<Product>.broadcast();

  // Returns all products via a Future
  Future<List<Product>> getAll() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return _products;
  }

  // Stream for real-time updates
  Stream<Product> liveAdded() {
    return _controller.stream;
  }
  
  // Add a new product and emit to stream
  void addProduct(Product product) {
    _products.add(product);
    _controller.add(product);
  }
  
  void dispose() {
    _controller.close();
  }
}

Future<void> runExercise1() async {
  print('--- Exercise 1: Product Model & Repository ---');
  final repo = ProductRepository();
  
  // Listen to live updates
  repo.liveAdded().listen((product) {
    print('Stream emitted new product: $product');
  });
  
  print('Fetching all products...');
  final allProducts = await repo.getAll();
  print('All products: $allProducts');
  
  print('Adding new product...');
  repo.addProduct(Product(id: '3', name: 'Tablet', price: 299.99));
  
  // Wait a bit to ensure stream listener receives the event before disposing
  await Future.delayed(Duration(milliseconds: 100));
  repo.dispose();
  print('');
}


// Exercise 2: User Repository with JSON


class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
  
  @override
  String toString() => 'User(name: $name, email: $email)';
}

class UserRepository {
  // Simulate JSON list from an API
  final String _jsonResponse = '''
  [
    {"name": "Alice", "email": "alice@example.com"},
    {"name": "Bob", "email": "bob@example.com"}
  ]
  ''';

  Future<List<User>> fetchUsers() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    // Parse JSON
    List<dynamic> parsedList = jsonDecode(_jsonResponse);
    return parsedList.map((json) => User.fromJson(json)).toList();
  }
}

Future<void> runExercise2() async {
  print('--- Exercise 2: User Repository with JSON ---');
  final repo = UserRepository();
  print('Fetching users from simulated API...');
  final users = await repo.fetchUsers();
  users.forEach((user) => print(user));
  print('');
}


// Exercise 3: Async + Microtask Debugging

Future<void> runExercise3() async {
  print('--- Exercise 3: Async + Microtask Debugging ---');
  
  // Standard Future (Event Queue)
  Future(() {
    print('Future execution (Event Queue)');
  });
  
  // Microtask (Microtask Queue - higher priority than Event Queue)
  scheduleMicrotask(() {
    print('Microtask execution (Microtask Queue)');
  });
  
  print('Synchronous execution (Main Thread)');
  
  // Explanation: 
  // 1. Synchronous code runs first.
  // 2. The microtask queue is checked and processed before the event queue.
  // 3. The event queue (standard Futures) is processed last.
  
  // Wait for the event loop to finish executing the microtasks and futures
  await Future.delayed(Duration(milliseconds: 100));
  print('');
}


// Exercise 4: Stream Transformation


Future<void> runExercise4() async {
  print('--- Exercise 4: Stream Transformation ---');
  
  // Create a stream of numbers 1-5
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  
  // Transform values to their squares using map()
  // Filter even numbers with where()
  Stream<int> transformedStream = numbers
      .map((n) => n * n)
      .where((n) => n % 2 == 0); // Keep only even squares
      
  print('Listening to transformed stream (even squares):');
  await for (var value in transformedStream) {
    print('Value: $value');
  }
  print('');
}


// Exercise 5: Factory Constructors & Cache


class Settings {
  // Private singleton instance
  static final Settings _instance = Settings._internal();
  
  // Some setting properties
  String theme = "Light";

  // Factory constructor returning the singleton instance
  factory Settings() {
    return _instance;
  }

  // Private named constructor
  Settings._internal() {
    print("Settings initialized");
  }
}

void runExercise5() {
  print('--- Exercise 5: Factory Constructors & Cache ---');
  
  final s1 = Settings();
  final s2 = Settings();
  
  s1.theme = "Dark";
  
  print('s1 theme: ${s1.theme}');
  print('s2 theme: ${s2.theme}');
  
  // Verify two instances refer to the same object
  bool isSame = identical(s1, s2);
  print('Are both settings identical? $isSame (identical(s1, s2) -> $isSame)');
  print('');
}

// Main Execution


void main() async {
  print('Starting Lab 3 Exercises...\n');
  
  await runExercise1();
  await runExercise2();
  await runExercise3();
  await runExercise4();
  runExercise5();
  
  print('Lab 3 Exercises completed.');
}
