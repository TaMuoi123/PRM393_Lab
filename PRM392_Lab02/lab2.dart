import 'dart:async';

void main() async {
  print('--- Exercise 1: Basic Syntax & Data Types ---');
  exercise1();

  print('\n--- Exercise 2: Collections & Operators ---');
  exercise2();

  print('\n--- Exercise 3: Control Flow & Functions ---');
  exercise3();

  print('\n--- Exercise 4: Intro to OOP ---');
  exercise4();

  print('\n--- Exercise 5: Async, Future, Null Safety & Streams ---');
  await exercise5();
}

// ==========================================
// Exercise 1 - Basic Syntax & Data Types
// ==========================================
void exercise1() {
  // Declare variables using core types
  int age = 20;
  double height = 1.75;
  String name = 'Alice';
  bool isStudent = true;

  // Use print() and string interpolation ($var, ${expr})
  print('Name: $name');
  print('Age: $age');
  print('Height: $height meters');
  print('Is student: $isStudent');
  print('Next year age: ${age + 1}');
}

// ==========================================
// Exercise 2 - Collections & Operators
// ==========================================
void exercise2() {
  // Create a List of integers
  List<int> numbers = [10, 20, 30];
  print('Original list: $numbers');
  
  // Use arithmetic & comparison operators
  int sum = numbers[0] + numbers[1];
  bool isGreater = numbers[2] > sum;
  print('Sum of first two elements: $sum');
  print('Is 3rd element greater than sum? $isGreater');

  // Create a Set (unique values)
  Set<String> uniqueColors = {'red', 'green', 'blue', 'red'};
  print('Unique colors (Set ignores duplicates): $uniqueColors');

  // Create a Map (key-value)
  Map<String, int> scores = {'Alice': 90, 'Bob': 85};
  
  // Use indexing, add(), remove(), and map access
  numbers.add(40); // add to List
  numbers.remove(10); // remove from List
  print('Modified list (added 40, removed 10): $numbers');
  print('Accessing 2nd element of List: ${numbers[1]}'); // indexing
  
  scores['Charlie'] = 95; // map access/add
  scores.remove('Bob'); // remove from Map
  print('Modified map: $scores');
}

// ==========================================
// Exercise 3 - Control Flow & Functions
// ==========================================
void exercise3() {
  // if/else block to check score
  int score = 85;
  if (score >= 90) {
    print('Grade: A');
  } else if (score >= 80) {
    print('Grade: B');
  } else {
    print('Grade: C');
  }

  // switch case for day of week
  int day = 3;
  switch (day) {
    case 1:
      print('Monday');
      break;
    case 2:
      print('Tuesday');
      break;
    case 3:
      print('Wednesday');
      break;
    default:
      print('Other day');
  }

  // Loop through a collection using for, for-in, and forEach()
  List<String> fruits = ['Apple', 'Banana', 'Cherry'];
  
  print('Using for loop:');
  for (int i = 0; i < fruits.length; i++) {
    print(' - ${fruits[i]}');
  }

  print('Using for-in loop:');
  for (String fruit in fruits) {
    print(' - $fruit');
  }

  print('Using forEach():');
  fruits.forEach((fruit) => print(' - $fruit'));

  // Call function with normal and arrow syntax
  print('Normal function sum (5+7): ${addNormal(5, 7)}');
  print('Arrow function sum (10+15): ${addArrow(10, 15)}');
}

// Function using normal syntax
int addNormal(int a, int b) {
  return a + b;
}

// Function using arrow syntax
int addArrow(int a, int b) => a + b;

// ==========================================
// Exercise 4 - Intro to OOP
// ==========================================
// Create a class Car with one property and a method
class Car {
  String brand;

  // Constructor
  Car(this.brand);

  // Named constructor
  Car.unknown() : brand = 'Unknown';

  void drive() {
    print('$brand car is driving.');
  }
}

// Create a subclass ElectricCar that overrides a method
class ElectricCar extends Car {
  ElectricCar(String brand) : super(brand);

  @override
  void drive() {
    print('$brand electric car is driving silently.');
  }
}

void exercise4() {
  // Instantiate objects and print results
  Car myCar = Car('Toyota');
  myCar.drive();

  Car unknownCar = Car.unknown();
  unknownCar.drive();

  ElectricCar myTesla = ElectricCar('Tesla');
  myTesla.drive();
}

// ==========================================
// Exercise 5 - Async, Future, Null Safety & Streams
// ==========================================
Future<void> exercise5() async {
  // Practice null-safety operators (?, ??, !)
  String? nullableString;
  
  // Use ?? (if null then use default value)
  print('Null string with ??: ${nullableString ?? 'Default Value'}');
  
  nullableString = 'Now not null';
  // Use ?. (null-aware access)
  print('Length of string with ?.: ${nullableString?.length}');
  // Use ! (non-null assertion)
  print('Length of string with !: ${nullableString!.length}');

  // Async function using Future + await and Future.delayed()
  print('Fetching data... (simulating network request)');
  String data = await fetchData();
  print(data);

  // Create a simple Stream of integers and listen to values
  print('Listening to stream:');
  Stream<int> myStream = countStream(3);
  await for (int value in myStream) {
    print('Stream value: $value');
  }
}

Future<String> fetchData() async {
  // Simulate network delay
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded successfully!';
}

Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}
