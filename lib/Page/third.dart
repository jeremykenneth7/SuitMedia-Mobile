import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suitmedia1/API/api_data_source.dart';
import 'package:suitmedia1/API/model.dart';

class ThirdScreen extends StatefulWidget {
  final void Function(String)? onUserSelected;

  const ThirdScreen({Key? key, this.onUserSelected}) : super(key: key);

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;
  List<Data> _usersList = [];
  int _currentPage = 1;
  int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadUsers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    setState(() {
      if (!refresh) {
        _isLoading = true;
      }
    });

    if (refresh) {
      _currentPage = 1;
      _usersList.clear();
    }

    final Map<String, dynamic> response =
        await ApiDataSource.instance.loadUsers(
      page: _currentPage,
      perPage: _perPage,
    );

    setState(() {
      _isLoading = false;
      if (response.containsKey('data')) {
        UsersModel usersModel = UsersModel.fromJson(response);
        _usersList.addAll(usersModel.data!);
        _currentPage++;
      }
      _hasMore =
          response.containsKey('data') && response['data'].length == _perPage;
    });
  }

  Future<void> _refreshUsers() async {
    await _loadUsers(refresh: true);
  }

  void _scrollListener() {
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            "Third Screen",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _buildListUsersBody(),
    );
  }

  Widget _buildListUsersBody() {
    if (_usersList.isEmpty && _isLoading) {
      return _buildLoadingSection();
    } else if (_usersList.isEmpty && !_isLoading) {
      return _buildEmptyState();
    } else {
      return RefreshIndicator(
        onRefresh: _refreshUsers,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _usersList.length + (_hasMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index < _usersList.length) {
              return _buildItemUsers(_usersList[index]);
            } else {
              return _buildLoadingIndicator();
            }
          },
        ),
      );
    }
  }

  Widget _buildItemUsers(Data usersModel) {
    return InkWell(
      onTap: () {
        if (widget.onUserSelected != null) {
          widget.onUserSelected!(
            '${usersModel.firstName} ${usersModel.lastName}',
          );
          Navigator.pop(context); // Close ThirdScreen after selection
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 15.0, right: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(usersModel.avatar!),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      usersModel.firstName!,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      usersModel.lastName!,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  usersModel.email!,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('No users found'),
    );
  }

  Widget _buildLoadingSection() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
