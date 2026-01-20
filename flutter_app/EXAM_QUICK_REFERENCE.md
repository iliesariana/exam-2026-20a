# Flutter Exam Quick Reference

## Quick Commands
```bash
flutter run              # Run the app (fastest for development)
flutter pub get          # Get dependencies
r                        # Hot reload (in terminal while app is running)
R                        # Hot restart (in terminal while app is running)
```

## Common Widget Templates

### 1. ListView with Items
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
      onTap: () {
        // Handle tap
      },
    );
  },
)
```

### 2. Form with TextField
```dart
final _formKey = GlobalKey<FormState>();
final _controller = TextEditingController();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _controller,
        decoration: InputDecoration(labelText: 'Enter text'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### 3. Navigation (Push/Pop)
```dart
// Navigate to new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondScreen()),
);

// Navigate back
Navigator.pop(context);

// Navigate with data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(data: myData),
  ),
);
```

### 4. Stateful Widget with Counter
```dart
int _counter = 0;

void _incrementCounter() {
  setState(() {
    _counter++;
  });
}
```

### 5. GridView
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      child: Center(child: Text(items[index])),
    );
  },
)
```

### 6. Alert Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Message'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // Handle action
          Navigator.pop(context);
        },
        child: Text('OK'),
      ),
    ],
  ),
);
```

### 7. Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    duration: Duration(seconds: 2),
  ),
);
```

### 8. Image Loading
```dart
// Network image
Image.network('https://example.com/image.jpg')

// Asset image (add to pubspec.yaml assets section first)
Image.asset('assets/images/image.png')
```

### 9. Row/Column Layout
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Left'),
    Text('Right'),
  ],
)

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Top'),
    Text('Bottom'),
  ],
)
```

### 10. Container with Styling
```dart
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text('Content'),
)
```

## Common Imports
```dart
import 'package:flutter/material.dart';
```

## Tips for Exam
1. **Use Hot Reload**: Press `r` in terminal after `flutter run` to see changes instantly
2. **Hot Restart**: Press `R` if hot reload doesn't work (resets state)
3. **Keep it Simple**: Start with basic widgets, add complexity later
4. **Test Often**: Run the app frequently to catch errors early
5. **Common Errors**: 
   - Missing `setState()` for state changes
   - Missing `const` keyword (can improve performance)
   - Forgetting to close widgets (use trailing comma for auto-format)

## Quick State Management Pattern
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // State variables here
  String _text = '';
  
  void _updateText() {
    setState(() {
      _text = 'Updated';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your UI here
    );
  }
}
```
