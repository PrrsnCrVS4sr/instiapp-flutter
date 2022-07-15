import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';

class ShareURLMaker {
  static final String webHost = "https://insti.app/";

  static String getEventURL(Event event) {
    return webHost + "event/" + event.eventStrID!;
  }

  static String getBodyURL(Body body) {
    return webHost + "org/" + body.bodyStrID!;
  }

  static String getUserURL(User user) {
    return webHost + "user/" + (user.userLDAPId ?? '');
  }

  static String getCommunityURL(Community community) {
    return webHost + "community/" + community.strId!;
  }

  static String getCommunityPostURL(CommunityPost communityPost) {
    return webHost + "community/" + "post/" + communityPost.communityPostStrId!;
  }
}
