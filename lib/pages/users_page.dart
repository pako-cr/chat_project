import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/services/users_service.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final usersService = new UsersServices();
  List<User> users = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    this._onRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.name,
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.black,
          ),
          onPressed: () {
            socketService.disconnect();
            this.logout();
          },
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serviceStatus == ServiceStatus.Online
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.highlight_off, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        // header: WaterDropMaterialHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed! Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: _listViewUsers(),
      ),
    );
  }

  ListView _listViewUsers() {
    return ListView.separated(
      itemBuilder: (_, i) => _userListTitle(this.users[i]),
      separatorBuilder: (_, i) => Divider(),
      itemCount: users.length,
    );
  }

  ListTile _userListTitle(User user) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        child: Text(user.name.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: user.online ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(100)),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.userTo = user;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  void _onRefresh() async {
    this.users = await usersService.getUsers();
    // monitor network fetch
    if (mounted) {
      setState(() {});
    } else {
      _refreshController.refreshFailed();
    }

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void logout() {
    Navigator.pushReplacementNamed(context, 'login');
    AuthService.logout();
  }
}
