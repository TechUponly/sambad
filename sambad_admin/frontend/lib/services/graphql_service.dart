import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink(
    'http://localhost:4000/graphql', // Update if deployed elsewhere
  );

  static ValueNotifier<GraphQLClient> initClient() {
    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
