import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late List<dynamic> _posts;
  bool _filterByHighestRating = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await Dio().get('https://jsonplaceholder.typicode.com/posts');
      setState(() {
        _posts = response.data;
        for (var post in _posts) {
          post['rating'] = 0; // Agregar campo de calificación inicial
        }
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  void _ratePost(int index, int rating) {
    setState(() {
      _posts[index]['rating'] = rating;
    });
  }

  List<dynamic> get _filteredPosts {
    if (!_filterByHighestRating) {
      return _posts;
    }
    var highestRating = _posts.map<int>((post) => post['rating']).reduce((a, b) => a > b ? a : b);
    return _posts.where((post) => post['rating'] == highestRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _filterByHighestRating = !_filterByHighestRating;
              });
            },
          ),
        ],
      ),
      body: _posts != null
          ? ListView.builder(
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredPosts[index]['title']),
                  subtitle: Text(_filteredPosts[index]['body']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: i < _filteredPosts[index]['rating'] ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          _ratePost(index, i + 1);
                        },
                      );
                    }),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
