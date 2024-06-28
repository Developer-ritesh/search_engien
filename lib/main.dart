import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:search_engien/api.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: 'assets/.env');
    runApp(SearchSuggestionApp());
  } catch (e) {
    print('Error loading .env file: $e');
  }
}

class SearchSuggestionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Suggestions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchSuggestionScreen(),
    );
  }
}

class SearchSuggestionScreen extends StatefulWidget {
  @override
  _SearchSuggestionScreenState createState() => _SearchSuggestionScreenState();
}

class _SearchSuggestionScreenState extends State<SearchSuggestionScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoading = false;

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$searchEngineId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        setState(() {
          _suggestions = items.map((item) => item['title'] as String).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                _fetchSuggestions(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () {
                            // Handle the selection
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
